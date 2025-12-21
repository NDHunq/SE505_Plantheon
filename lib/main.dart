import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_provider.dart';
import 'package:se501_plantheon/core/services/deep_link_service.dart';
import 'package:se501_plantheon/presentation/screens/authentication/signin.dart';
import 'package:se501_plantheon/presentation/screens/on_boarding/on_boarding.dart';
import 'package:se501_plantheon/presentation/screens/on_boarding/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:se501_plantheon/presentation/screens/navigator/navigator.dart';

import 'package:toastification/toastification.dart';
import 'package:se501_plantheon/core/services/camera_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await FirebaseNotificationService().initialize();

  // Initialize Deep Link Service
  await DeepLinkService().initialize(navigatorKey: navigatorKey);

  // Prefetch camera descriptions to speed up scan screen initialization
  await CameraService.prefetch();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              locale: const Locale('vi'),
              supportedLocales: const [Locale('vi'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                primaryColor: AppColors.primary_main,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary_main,
                  primary: AppColors.primary_main,
                  secondary: AppColors.primary_main,
                  onPrimary: Colors.white,
                  background: Colors.white,
                  surface: Colors.white,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppColors.white,

                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary_main),
                  ),
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: AppColors.primary_main,
                  foregroundColor: Colors.white,
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: AppColors.primary_main,
                  foregroundColor: Colors.white,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary_main,
                    foregroundColor: Colors.white,
                  ),
                ),
                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.all(AppColors.primary_main),
                ),
                radioTheme: RadioThemeData(
                  fillColor: WidgetStateProperty.all(AppColors.primary_main),
                ),
                switchTheme: SwitchThemeData(
                  thumbColor: WidgetStateProperty.all(AppColors.primary_main),
                  trackColor: WidgetStateProperty.all(
                    AppColors.primary_main.withOpacity(0.5),
                  ),
                ),
              ),
              home: const StartupRouter(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

class StartupRouter extends StatefulWidget {
  const StartupRouter({super.key});

  @override
  State<StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<StartupRouter> {
  @override
  void initState() {
    super.initState();
    _decideInitialRoute();
  }

  Future<void> _decideInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // If first time opening app, show onboarding
    if (!hasSeenOnboarding) {
      Navigator.of(navigatorKey.currentContext!).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    // Check if token is valid (exists and not expired)
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      try {
        final isExpired = Jwt.isExpired(token);
        if (!isExpired) {
          // Token is valid, go to main navigator
          Navigator.of(navigatorKey.currentContext!).pushReplacement(
            MaterialPageRoute(builder: (_) => const CustomNavigator()),
          );
          return;
        } else {
          // Token expired, clear it
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
        }
      } catch (e) {
        // Invalid token format, clear it
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
      }
    }

    // Otherwise show sign in
    Navigator.of(
      navigatorKey.currentContext!,
    ).pushReplacement(MaterialPageRoute(builder: (_) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
