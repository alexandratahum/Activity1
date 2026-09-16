import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/routes/app_routes.dart';
import 'package:portfolio_app/screens/activity_one_screen.dart';
import 'package:portfolio_app/screens/activity_two_screen.dart';
import 'package:portfolio_app/screens/home_screen.dart';
import 'package:portfolio_app/screens/settings_screen.dart';
import 'package:portfolio_app/state/app_settings.dart';
import 'package:portfolio_app/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const PortfolioApp(),
    ),
  );
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return MaterialApp(
      title: 'Flutter Portfolio Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.activityOne: (_) => const ActivityOneScreen(),
        AppRoutes.activityTwo: (_) => const ActivityTwoScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
