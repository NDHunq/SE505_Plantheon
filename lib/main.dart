import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/presentation/screens/authentication/login.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/services/firebase_notification_service.dart';
import 'package:se501_plantheon/presentation/screens/scan/scan_solution.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';

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
          // home: SignInPage(),
          home: BlocProvider<DiseaseBloc>(
            create: (context) => DiseaseBloc(
              getDisease: GetDisease(
                repository: DiseaseRepositoryImpl(
                  remoteDataSource: DiseaseRemoteDataSourceImpl(
                    client: http.Client(),
                    baseUrl: ApiConstants.diseaseApiUrl,
                  ),
                ),
              ),
            ),
            // child: const ScanSolution(diseaseLabel: 'Sugarcane_Healthy_Leaves'),
            child: const SignInPage(),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
