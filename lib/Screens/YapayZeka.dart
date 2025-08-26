import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

// Third party packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

// Local imports - Bu import'ları kendi projenizde güncelleyin
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/theme.dart';
import 'package:senseriduvarkagidi/theme_provider.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';

class WallpaperGeneration extends StatefulWidget {
  const WallpaperGeneration({super.key});

  @override
  State<WallpaperGeneration> createState() => _WallpaperGenerationState();
}

class _WallpaperGenerationState extends State<WallpaperGeneration>
    with TickerProviderStateMixin {

  // Controllers
  late TextEditingController _promptController;
  late AnimationController _generateAnimationController;
  late AnimationController _shimmerAnimationController;
  late Animation<double> _generateAnimation;
  late Animation<double> _shimmerAnimation;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // State variables
  bool _isGenerating = false;
  bool _hasGeneratedImage = false;
  String? _generatedImageBase64;
  List<String> _generationHistory = [];
  String _selectedStyle = 'Gerçekçi';

  // OpenRouter AI Configuration
  final String _openRouterApiKey = ayarlar.aiapikey; // Buraya OpenRouter API key'inizi ekleyin
  final String _openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  final String _geminiModel = 'google/gemini-2.5-flash-image-preview:free';

  // Style options - Türkçe stillerde
  final List<Map<String, dynamic>> _styleOptions = [
    {'name': 'Gerçekçi', 'icon': Icons.photo_camera, 'color': Colors.blue},
    {'name': 'Anime', 'icon': Icons.animation, 'color': Colors.purple},
    {'name': 'Soyut', 'icon': Icons.brush, 'color': Colors.orange},
    {'name': 'Fantastik', 'icon': Icons.auto_awesome, 'color': Colors.pink},
    {'name': 'Siberpunk', 'icon': Icons.computer, 'color': Colors.cyan},
    {'name': 'Doğa', 'icon': Icons.nature, 'color': Colors.green},
  ];

  // Türkçe prompt önerileri
  final List<String> _promptSuggestions = [
    "Dağların üzerinde muhteşem gün batımı",
    "Neon ışıklarla futuristik şehir manzarası",
    "Sabah sisinin sarmaladığı huzurlu orman",
    "Soyut geometrik desenler ve renkli şekiller",
    "Yıldızlı gece altında okyanus dalgaları",
    "Kiraz çiçekleri altında anime karakter",
    "Yağmurlu siberpunk sokak sahnesi",
    "Uçan ada üzerinde fantastik kale",
    "Türk bayraklı dağ manzarası",
    "İstanbul Boğaz köprüsü manzarası",
    "Kapadokya balon turu manzarası",
    "Pamukkale travertenleri ve havuzlar",
    "Anadolu çayırlarında koyun sürüsü",
    "Osmanlı saray bahçesi",
    "Modern İstanbul skyline",
    "Antik Türk motifli sanat",
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeBannerAd();
  }

  void _initializeControllers() {
    _promptController = TextEditingController();
    _generateAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shimmerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _generateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _generateAnimationController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _shimmerAnimationController, curve: Curves.linear),
    );
  }

  void _initializeBannerAd() {
    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd = BannerAd(
        adUnitId: _getBannerAdUnitId(),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );
      _bannerAd?.load();
    }
  }

  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return ayarlar.bannerReklamId;
    } else if (Platform.isIOS) {
      return ayarlar.bannerReklamId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _generateAnimationController.dispose();
    _shimmerAnimationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // OpenRouter AI API Methods
  Future<void> _generateWallpaper() async {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isGenerating = true;
      _hasGeneratedImage = false;
    });

    HapticFeedback.mediumImpact();

    try {
      final generatedImageBase64 = await _generateImageWithOpenRouter(_promptController.text.trim());

      if (generatedImageBase64 != null) {
        setState(() {
          _generatedImageBase64 = generatedImageBase64;
          _hasGeneratedImage = true;
          _generationHistory.insert(0, generatedImageBase64);
          if (_generationHistory.length > 10) {
            _generationHistory.removeLast();
          }
        });

        _generateAnimationController.forward().then((_) {
          _generateAnimationController.reset();
        });

        // Başarılı oluşturma için vibration
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 200);
        }

        _showSuccessAlert('Duvar kağıdınız başarıyla oluşturuldu!');
      } else {
        _showErrorAlert('Görsel oluşturulamadı. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      print('Error generating wallpaper: $e');
      _showErrorAlert('Bir hata oluştu: ${e.toString()}');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<String?> _generateImageWithOpenRouter(String prompt) async {
    try {
      final enhancedPrompt = _enhancePrompt(prompt);

      final dio = Dio();
      final response = await dio.post(
        '$_openRouterBaseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_openRouterApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _geminiModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': enhancedPrompt,
                }
              ]
            }
          ],
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Response'dan base64 resmini çıkar
        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null &&
            responseData['choices'][0]['message']['images'] != null) {

          final content = responseData['choices'][0]['message']['images'][0]['image_url']['url'];

          // Base64 string'i bul ve çıkar
          final base64Regex = RegExp(r'data:image\/[^;]+;base64,([A-Za-z0-9+/=]+)');
          final match = base64Regex.firstMatch(content);

          if (match != null) {
            return match.group(1); // Base64 kısmını döndür
          }

          // Alternatif olarak, sadece base64 string varsa
          final base64OnlyRegex = RegExp(r'^[A-Za-z0-9+/]+=*$');
          if (base64OnlyRegex.hasMatch(content.trim())) {
            return content.trim();
          }
        }

        throw Exception('Response\'da geçerli base64 resim bulunamadı');
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('OpenRouter AI API Error: $e');
      throw Exception('AI servisi ile bağlantı kurulamadı: $e');
    }
  }

  String _enhancePrompt(String basePrompt) {
    String enhanced =
        "Mobil cihazlar için yüksek kaliteli bir duvar kağıdı üret. "
        "Yalnızca görsel çıktıyı tek mesajda ver, açıklama ekleme. "
        "Çözünürlük: Genişlik=${Genel.genislik}, Yükseklik=${Genel.yukseklik}. "
        "Tema: $basePrompt ";
    // Stil ekleme
    switch (_selectedStyle.toLowerCase()) {
      case 'gerçekçi':
        enhanced += ', fotorealistik, yüksek kalite, detaylı, 8K çözünürlük';
        break;
      case 'anime':
        enhanced += ', anime tarzı, manga sanatı, canlı renkler';
        break;
      case 'soyut':
        enhanced += ', soyut sanat, geometrik şekiller, modern tasarım';
        break;
      case 'fantastik':
        enhanced += ', fantastik sanat, büyülü, mistik, büyüleyici';
        break;
      case 'siberpunk':
        enhanced += ', siberpunk tarzı, neon ışıklar, fütüristik, karanlık atmosfer';
        break;
      case 'doğa':
        enhanced += ', doğal manzara, organik, huzurlu, sakin, güzel';
        break;
    }

    enhanced += ', başyapıt, en iyi kalite, ultra detaylı, keskin odak, duvar kağıdı formatında';

    return enhanced;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Ad
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.only(bottom: 8),
                child: AdWidget(ad: _bannerAd!),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildPromptInputSection(),
                    const SizedBox(height: 20),
                    _buildStyleSelection(),
                    const SizedBox(height: 20),
                    _buildGenerateButton(),
                    const SizedBox(height: 20),
                    _buildResultSection(),
                    const SizedBox(height: 20),
                    _buildPromptSuggestions(),
                    if (_generationHistory.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildGenerationHistory(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).textTheme.titleLarge?.color,
            size: 20,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AI Duvar Kağıdı Oluştur',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gemini AI ile Oluştur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Telefonunuza hayalinizdeki duvar kağıdınızı oluşturun',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ne İstiyorsunuz?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Örnek: Güneşin battığı dağlar manzarası, renkli gökyüzü...',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.purple,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              setState(() {}); // Buton durumunu güncellemek için
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Stil Seçin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _styleOptions.map((style) => _buildStyleChip(style)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(Map<String, dynamic> style) {
    final isSelected = _selectedStyle == style['name'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedStyle = style['name'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? style['color'].withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? style['color'] : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style['icon'],
              color: isSelected ? style['color'] : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              style['name'],
              style: TextStyle(
                color: isSelected ? style['color'] : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = _promptController.text.trim().isNotEmpty && !_isGenerating;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: canGenerate
            ? const LinearGradient(
          colors: [Colors.purple, Colors.blue],
        )
            : null,
        color: !canGenerate ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: canGenerate ? [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canGenerate ? _generateWallpaper : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: _isGenerating
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Oluşturuyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: canGenerate ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duvar Kağıdı Oluştur',
                  style: TextStyle(
                    color: canGenerate ? Colors.white : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    if (!_isGenerating && !_hasGeneratedImage) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.image_rounded,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isGenerating ? 'Gemini AI ile Oluşturuluyor...' : 'Sonuç',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isGenerating)
            _buildGeneratingPlaceholder()
          else if (_hasGeneratedImage && _generatedImageBase64 != null)
            _buildGeneratedImage(),
        ],
      ),
    );
  }

  Widget _buildGeneratingPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Shimmer effect
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment(_shimmerAnimation.value - 1, 0),
                    end: Alignment(_shimmerAnimation.value, 0),
                    colors: [
                      Colors.grey[100]!,
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gemini AI duvar kağıdınızı oluşturuyor...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu işlem birkaç saniye sürebilir',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedImage() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(_generatedImageBase64!),
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[100],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Resim yüklenemedi', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.wallpaper_rounded,
                label: 'Duvar Kağıdı Yap',
                color: Colors.blue,
                onPressed: () => _setGeneratedWallpaper(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.download_rounded,
                label: 'İndir',
                color: Colors.green,
                onPressed: () => _downloadGeneratedImage(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptSuggestions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'İlham Alın',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _promptSuggestions.map((suggestion) =>
                _buildSuggestionChip(suggestion)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _promptController.text = suggestion;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: Colors.amber[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Colors.indigo,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Son AI Üretimleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _generationHistory.length,
              itemBuilder: (context, index) {
                final imageBase64 = _generationHistory[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(imageBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(Icons.error_outline, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  Future<void> _setGeneratedWallpaper() async {
    if (_generatedImageBase64 == null) return;
    _showWallpaperLocationDialog();
  }

  void _showWallpaperLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wallpaper_rounded,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "AI Duvar Kağıdı",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gemini AI ile oluşturulan duvar kağıdını nereye uygulamak istiyorsunuz?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _buildWallpaperOption(
                icon: Icons.lock_outline_rounded,
                title: "Kilit Ekranı",
                subtitle: "Sadece kilit ekranında görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performSetWallpaper(WallpaperManagerPlus.lockScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.home_outlined,
                title: "Ana Ekran",
                subtitle: "Sadece ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performSetWallpaper(WallpaperManagerPlus.homeScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.phone_android_rounded,
                title: "Her İki Ekran",
                subtitle: "Hem kilit hem ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performSetWallpaper(WallpaperManagerPlus.bothScreens);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "İptal",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWallpaperOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performSetWallpaper(int wallpaperLocation) async {
    if (_generatedImageBase64 == null) return;

    try {
      setState(() => _isGenerating = true);

      // Base64'ü geçici dosyaya kaydet
      final bytes = base64Decode(_generatedImageBase64!);
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/ai_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      var result = await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);

      if (result!.isEmpty) {
        // Log kaydı
        await Kullanici.IslemLog(
            context,
            Genel.CihazId,
            "AI Duvar Kagidi Yapma",
            0
        );

        String locationText = "";
        switch (wallpaperLocation) {
          case 1:
            locationText = "ana ekrana";
            break;
          case 2:
            locationText = "kilit ekranına";
            break;
          case 3:
            locationText = "her iki ekrana";
            break;
        }

        _showSuccessAlert("AI duvar kağıdı $locationText başarıyla ayarlandı!");

        // Geçici dosyayı sil
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        _showErrorAlert("Duvar kağıdı ayarlanamadı");
      }
    } catch (e) {
      _showErrorAlert("Bir hata oluştu: ${e.toString()}");
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _downloadGeneratedImage() async {
    if (_generatedImageBase64 == null) return;

    try {
      setState(() => _isGenerating = true);

      final DateTime now = DateTime.now();
      final Uint8List imageBytes = base64Decode(_generatedImageBase64!);

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showErrorAlert("Galeriyi kaydetmek için izin verilmedi.");
        return;
      }

      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename: "ai_wallpaper_${now.millisecondsSinceEpoch}",
        title: "ai_wallpaper_${now.millisecondsSinceEpoch}",
      );

      if (asset != null) {
        await Kullanici.IslemLog(
            context,
            Genel.CihazId,
            "AI Download",
            0
        );
        _showSuccessAlert("AI duvar kağıdı başarıyla indirildi!");
      } else {
        _showErrorAlert("Resim indirilemedi");
      }
    } catch (e) {
      _showErrorAlert("Bir hata oluştu: ${e.toString()}");
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showSuccessAlert(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Başarılı!",
      text: message,
      confirmBtnColor: Colors.teal,
    );
  }

  void _showErrorAlert(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Hata!",
      text: message,
      confirmBtnColor: Colors.red,
    );
  }
}