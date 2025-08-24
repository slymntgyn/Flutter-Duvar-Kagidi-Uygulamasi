import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/Screens/Sayfalar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Loading extends StatefulWidget {
  @override
  Loading_State createState() => Loading_State();
}

class Loading_State extends State<Loading> with TickerProviderStateMixin {
  TextEditingController kullaniciAdiController = TextEditingController();
  TextEditingController sifreController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _currentStatus = "Başlatılıyor...";
  bool _hasError = false;
  String _errorMessage = "";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSetup();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  Future<void> _startSetup() async {
    try {
      await _checkInternetConnection();
      await Setup();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
// İnternet kontrolünü tamamen atlayın - sadece bu fonksiyonu değiştirin

  Future<void> _checkInternetConnection() async {
    setState(() {
      _currentStatus = "Bağlantı kontrol ediliyor...";
      _progress = 0.1;
    });

    // Kısa bir bekleme süresi
    await Future.delayed(const Duration(milliseconds: 500));

    // İnternet kontrolü yapmadan devam et
    // API istekleri sırasında zaten bağlantı hataları yakalanacak
  }
  Future<void> Setup() async {
    try {
      setState(() {
        _currentStatus = "Ayarlar yükleniyor...";
        _progress = 0.2;
      });

      String darkmode = await Yardimci.Veri_Getir_String("darkmode");

      if(darkmode == "") {
        darkmode = "false";
      }
      Genel.darkbutton = bool.parse(darkmode);
      Color a = Theme.of(context).primaryColorDark;

      if(a == Color(0xff1976d2)) {
        if(Genel.darkbutton) {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        }
      }

      setState(() {
        _currentStatus = "Sunucu ayarları alınıyor...";
        _progress = 0.4;
      });

      List<Ayarlar>? list = await Ayarlar.Ayarlari_Getir(context);
      if (list != null) {
        ayarlar.Ayarlari_Yukle(list);
      }

      print("ayarlar.bakimvarmi"+ayarlar.bakimvarmi);
      Genel.adUnitId = ayarlar.odulluReklamId;

      if(ayarlar.bakimvarmi == "1") {
        throw Exception("Sistemde bakım çalışması vardır.\nLütfen daha sonra tekrar deneyiniz.");
      }

      setState(() {
        _currentStatus = "Cihaz bilgileri alınıyor...";
        _progress = 0.5;
      });

      await Yardimci.Cihaz_Bilgi_Getir();

      setState(() {
        _currentStatus = "Kullanıcı bilgileri yükleniyor...";
        _progress = 0.6;
      });

      await Kullanici.Kullanici_Getir(context);

      setState(() {
        _currentStatus = "Resimler yükleniyor...";
        _progress = 0.8;
      });

      await ImageList.GetResimler(context);

      setState(() {
        _currentStatus = "Kategoriler yükleniyor...";
        _progress = 0.9;
      });

      await KategoriList.GetKategoriler(context);
      print("Genel.Kategoriler[0].kategori"+Genel.Kategoriler[0].kategorI_RESMI);

      setState(() {
        _currentStatus = "Reklamlar hazırlanıyor...";
        _progress = 0.95;
      });

      KategoriList.ReklamYukle(context);

      setState(() {
        _currentStatus = "Tamamlandı!";
        _progress = 1.0;
      });

      // Small delay before navigation
      await Future.delayed(const Duration(milliseconds: 500));

      Yardimci.Sayfa_Gecisi(context, Sayfalar());

    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    kullaniciAdiController.dispose();
    sifreController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Genel.genislik = MediaQuery.of(context).size.width;
    Genel.yukseklik = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Genel.darkbutton
                ? [
              const Color(0xFF1a1a1a),
              const Color(0xFF2d2d2d),
              const Color(0xFF1a1a1a),
            ]
                : [
              const Color(0xFFf8f9fa),
              const Color(0xFFe9ecef),
              const Color(0xFFf8f9fa),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _hasError ? _buildErrorView() : _buildLoadingView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      children: [
        const Spacer(),
        // Logo Section
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (Genel.darkbutton ? Colors.white : Colors.black).withOpacity(0.05),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              Genel.darkbutton ? "assets/images/4K-HDWHITE.png" : "assets/images/4K-HDBLACK.png",
              width: Genel.genislik * 0.5,
              height: Genel.genislik * 0.3,
            ),
          ),
        ),

        const SizedBox(height: 60),

        // App Title
        Text(
          "4K-HD",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "DUVAR KAĞITLARI",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
          ),
        ),

        const Spacer(),

        // Progress Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Loading Animation
              LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).primaryColor,
                size: 40,
              ),

              const SizedBox(height: 20),

              // Status Text
              Text(
                _currentStatus,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Progress Bar
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * _progress * 0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress Percentage
              Text(
                "${(_progress * 100).toInt()}%",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 24),

            // Error Title
            Text(
              "Bir Hata Oluştu",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Error Message
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = "";
                    _progress = 0.0;
                    _currentStatus = "Başlatılıyor...";
                  });

                  HapticFeedback.lightImpact();
                  _startSetup();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Tekrar Dene",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}