import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:se501_plantheon/presentation/screens/authentication/login.dart';
// import 'package:se501_plantheon/presentation/screens/authentication/login.dart';
import 'package:se501_plantheon/presentation/screens/push_notification_demo_screen.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase
  await SupabaseService.initialize();

  // Khởi tạo Firebase Cloud Messaging
  await FirebaseNotificationService().initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        375,
        812,
      ), // Kích thước thiết kế tham chiếu (thường là kích thước của thiết kế UI)
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            primaryColor: AppColors.primary_main,

            checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStateProperty.all(AppColors.primary_main),
            ),
            radioTheme: RadioThemeData(
              fillColor: MaterialStateProperty.all(AppColors.primary_main),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.all(AppColors.primary_main),
              trackColor: MaterialStateProperty.all(
                AppColors.primary_main.withOpacity(0.5),
              ),
            ),
          ),
          // Thay đổi home thành PushNotificationDemoScreen để test
          // home: SignInPage(),
          home: const ScanSolution(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
