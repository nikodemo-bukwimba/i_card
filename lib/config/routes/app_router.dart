import 'package:flutter/material.dart';

import '../../core/config/brand_config.dart';
import '../../features/brand/presentation/pages/edit_page.dart';
import '../../features/card/presentation/pages/card_home_page.dart';
import '../../features/contact/domain/entities/contact_entity.dart';

abstract class AppRouter {
  static const String home = '/';
  static const String edit = '/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(
          CardHomePage(
            brand: args?['brand'] as BrandConfig? ?? const BrandConfig(),
            onBrandUpdated:
                args?['onBrandUpdated'] as ValueChanged<BrandConfig>? ??
                    (_) {},
          ),
          settings,
        );

      case edit:
        final args = settings.arguments! as Map<String, dynamic>;
        return _slide(
          EditPage(
            contact: args['contact'] as ContactEntity,
            brand:   args['brand']   as BrandConfig,
          ),
          settings,
        );

      default:
        return _slide(
          const Scaffold(
              body: Center(child: Text('404 — Route not found'))),
          settings,
        );
    }
  }

  static PageRouteBuilder<T> _slide<T>(
          Widget page, RouteSettings settings) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}