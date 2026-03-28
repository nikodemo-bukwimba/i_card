import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../../config/theme/app_colors.dart';

/// Runtime-configurable branding value object.
/// All colour defaults mirror [AppColors.seed] — change the seed to re-brand.
class BrandConfig {
  final String appName;
  final String appBarTitle;
  final String badgeText;
  final String primaryColorHex;
  final String accentColorHex;
  final String goldColorHex;

  const BrandConfig({
    this.appName = AppConstants.appName,
    this.appBarTitle = AppConstants.defaultAppBarTitle,
    this.badgeText = AppConstants.defaultBadgeText,
    this.primaryColorHex = AppConstants.defaultPrimaryHex,
    this.accentColorHex = AppConstants.defaultAccentHex,
    this.goldColorHex = AppConstants.defaultGoldHex,
  });

  Color get primaryColor {
    try {
      return AppColors.fromHex(primaryColorHex);
    } catch (_) {
      return AppColors.seed;
    }
  }

  Color get accentColor {
    try {
      return AppColors.fromHex(accentColorHex);
    } catch (_) {
      return AppColors.seedAccent;
    }
  }

  Color get goldColor {
    try {
      return AppColors.fromHex(goldColorHex);
    } catch (_) {
      return AppColors.seedGold;
    }
  }

  BrandConfig copyWith({
    String? appName,
    String? appBarTitle,
    String? badgeText,
    String? primaryColorHex,
    String? accentColorHex,
    String? goldColorHex,
  }) =>
      BrandConfig(
        appName: appName ?? this.appName,
        appBarTitle: appBarTitle ?? this.appBarTitle,
        badgeText: badgeText ?? this.badgeText,
        primaryColorHex: primaryColorHex ?? this.primaryColorHex,
        accentColorHex: accentColorHex ?? this.accentColorHex,
        goldColorHex: goldColorHex ?? this.goldColorHex,
      );

  // ── Storage keys ──────────────────────────────────────────────────────────
  static const _kAppName = 'brand_appName';
  static const _kAppBarTitle = 'brand_appBarTitle';
  static const _kBadgeText = 'brand_badgeText';
  static const _kPrimary = 'brand_primaryColor';
  static const _kAccent = 'brand_accentColor';
  static const _kGold = 'brand_goldColor';

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> save(StorageService storage) => storage.setMap({
        _kAppName: appName,
        _kAppBarTitle: appBarTitle,
        _kBadgeText: badgeText,
        _kPrimary: primaryColorHex,
        _kAccent: accentColorHex,
        _kGold: goldColorHex,
      });

  static BrandConfig fromStorage(StorageService storage) {
    // Helper: validate stored hex, fall back to default if corrupt
    String safeHex(String? value, String fallback) {
      if (value == null) return fallback;
      final cleaned =
          value.replaceAll('#', '').replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
      return (cleaned.length == 6 || cleaned.length == 8) ? value : fallback;
    }

    return BrandConfig(
      appName: storage.getString(_kAppName) ?? AppConstants.appName,
      appBarTitle:
          storage.getString(_kAppBarTitle) ?? AppConstants.defaultAppBarTitle,
      badgeText:
          storage.getString(_kBadgeText) ?? AppConstants.defaultBadgeText,
      primaryColorHex:
          safeHex(storage.getString(_kPrimary), AppConstants.defaultPrimaryHex),
      accentColorHex:
          safeHex(storage.getString(_kAccent), AppConstants.defaultAccentHex),
      goldColorHex:
          safeHex(storage.getString(_kGold), AppConstants.defaultGoldHex),
    );
  }
}
