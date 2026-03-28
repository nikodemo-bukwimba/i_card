abstract class AppConstants {
  // App meta
  static const String appName        = 'i card';
  static const String appVersion     = '1.0.0';
  static const String appBuildNumber = '1';

  // Default contact values
  static const String defaultName    = 'Jina Lako Hapa';
  static const String defaultTitle   = 'Founder & Life Skills Educator';
  static const String defaultOrg     = 'ISSUBI LIFE SYSTEM';
  static const String defaultPhone   = '+255700000000';
  static const String defaultEmail   = 'jina@issubi.com';
  static const String defaultWebsite = 'https://issubi.com';
  static const String defaultWa      = 'https://whatsapp.com/channel/issubi';
  static const String defaultLi      = 'https://linkedin.com/in/jinalako';
  static const String defaultAddress = 'Mbeya, Tanzania';
  static const String defaultTagline = 'Dhibiti akili yako. Jenga maisha yako.';

  // Default brand labels
  static const String defaultAppBarTitle = 'ISSUBI LIFE SYSTEM™';
  static const String defaultBadgeText   = 'ISSUBI LIFE SYSTEM™';

  // Default brand hex colours (mirrors AppColors.seed)
  static const String defaultPrimaryHex = '#3C3489';
  static const String defaultAccentHex  = '#1D9E75';
  static const String defaultGoldHex    = '#C9A84C';

  // Image picker limits
  static const double photoMaxWidth  = 400;
  static const double photoMaxHeight = 400;
  static const int    photoQuality   = 75;

  // QR
  static const int qrSize = 190;

  // Animation
  static const Duration fadeInDuration     = Duration(milliseconds: 600);
  static const Duration transitionDuration = Duration(milliseconds: 300);
}