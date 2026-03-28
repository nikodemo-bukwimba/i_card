import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/di/injection_container.dart';
import 'config/theme/app_colors.dart';
import 'config/theme/app_theme.dart';
import 'core/config/brand_config.dart';
import 'features/brand/presentation/bloc/brand_bloc.dart';
import 'features/brand/presentation/bloc/brand_event.dart';
import 'features/brand/presentation/bloc/brand_state.dart';
import 'features/card/presentation/pages/card_home_page.dart';
import 'features/contact/presentation/bloc/contact_bloc.dart';

class IssubiApp extends StatelessWidget {
  const IssubiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<BrandBloc>()..add(const BrandLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<ContactBloc>(),
        ),
      ],
      child: BlocBuilder<BrandBloc, BrandState>(
        builder: (context, brandState) {
          final brand = switch (brandState) {
            BrandLoaded(:final brand) => brand,
            BrandSaved(:final brand)  => brand,
            _                         => const BrandConfig(),
          };

          return MaterialApp(
            title: brand.appName,
            debugShowCheckedModeBanner: false,

            // ── Respond to phone system theme automatically ────────────────
            theme:     AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system, // follows OS light/dark setting

            home: (brandState is BrandInitial || brandState is BrandLoading)
                ? const _SplashScreen()
                : CardHomePage(
                    brand: brand,
                    onBrandUpdated: (updatedBrand) {
                      context
                          .read<BrandBloc>()
                          .add(BrandSaveRequested(updatedBrand));
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.purpleMid),
      ),
    );
  }
}