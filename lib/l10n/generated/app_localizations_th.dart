// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get navExplore => 'สำรวจ';

  @override
  String get navCategories => 'หมวดหมู่';

  @override
  String get navFavorites => 'รายการโปรด';

  @override
  String get navSettings => 'การตั้งค่า';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get premiumSection => 'พรีเมียม';

  @override
  String get themeSection => 'ธีมการแสดงผล';

  @override
  String get aboutSection => 'เกี่ยวกับ';

  @override
  String get themeLight => 'ธีมสว่าง';

  @override
  String get themeDark => 'ธีมมืด';

  @override
  String get themeAmoled => 'AMOLED (ดำสนิท)';

  @override
  String themeActivated(String name) {
    return 'เปิดใช้งาน $name แล้ว';
  }

  @override
  String get appVersion => 'เวอร์ชันแอป';

  @override
  String get proUserTitle => 'ผู้ใช้ Pro';

  @override
  String get proUserSubtitle => 'ปลดล็อกทุกฟีเจอร์';

  @override
  String get freePlanTitle => 'แพ็กเกจฟรี';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return 'สร้างด้วย AI วันละ $remaining/$limit';
  }

  @override
  String get upgradeToPro => 'อัปเกรดเป็น Pro';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'ปลดล็อกการสร้างวอลเปเปอร์ด้วย AI';

  @override
  String get featureNvidiaTitle => 'สร้างด้วย AI ของ NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'สร้างวอลเปเปอร์ในฝันได้ในไม่กี่วินาทีด้วย AI ของ NVIDIA';

  @override
  String get featureStylesTitle => 'ทุกสไตล์งานศิลป์';

  @override
  String get featureStylesDesc =>
      'ปลดล็อกกว่า 10 สไตล์: สมจริง อนิเมะ ไซเบอร์พังก์ แฟนตาซี และอื่น ๆ';

  @override
  String get featureAdFreeTitle => 'ประสบการณ์ไร้โฆษณา';

  @override
  String get featureAdFreeDesc =>
      'ลบแบนเนอร์และโฆษณาทั้งหมดเพื่อการใช้งานที่ไม่สะดุด';

  @override
  String get featureApplyTitle => 'ใช้งานได้ในแตะเดียว';

  @override
  String get featureApplyDesc =>
      'ตั้งภาพที่สร้างเป็นวอลเปเปอร์หน้าจอหลัก/ล็อก ดาวน์โหลดหรือแชร์';

  @override
  String get aiLockedNotice =>
      'การสร้างด้วย AI ถูกล็อกอยู่ ปลดล็อกด้วย Pro ได้เลย';

  @override
  String get monthlyPro => 'Pro รายเดือน';

  @override
  String get monthlyProSubtitle => 'เรียกเก็บเดือนละครั้ง';

  @override
  String get yearlyPro => 'Pro รายปี';

  @override
  String get yearlyProSubtitle => 'คุ้มที่สุด - ประหยัด 40%';

  @override
  String get restorePurchase => 'กู้คืนการซื้อ';

  @override
  String get subscriptionAutoRenew =>
      'การสมัครสมาชิกต่ออายุอัตโนมัติ ยกเลิกได้ทุกเมื่อ';

  @override
  String get productsLoadError =>
      'โหลดสินค้าไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get purchaseInProgress => 'กำลังดำเนินการซื้อ...';

  @override
  String get upgradedToProMessage => 'อัปเกรดเป็น Pro แล้ว! ขอบคุณค่ะ';

  @override
  String get restoringPurchases => 'กำลังกู้คืนการซื้อ...';
}
