import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_provider.dart';
import 'package:se501_plantheon/core/services/deep_link_service.dart';
import 'package:se501_plantheon/presentation/screens/on_boarding/on_boarding.dart';

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
              home: const OnboardingScreen(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
