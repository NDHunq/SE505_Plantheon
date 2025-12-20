import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/scan_history_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/data/repository/scan_history_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_scan_history_by_id.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/create_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_all_scan_history.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/delete_scan_history_by_id.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/scan_history/scan_history_bloc.dart';

class ScanHistoryProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const ScanHistoryProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ScanHistoryRemoteDataSource>(
          create: (context) => ScanHistoryRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
            tokenStorage:
                (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                    .tokenStorage,
          ),
        ),
        RepositoryProvider<ScanHistoryRepositoryImpl>(
          create: (context) => ScanHistoryRepositoryImpl(
            remoteDataSource: context.read<ScanHistoryRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider<ScanHistoryBloc>(
        create: (context) => ScanHistoryBloc(
          getAllScanHistory: GetAllScanHistory(
            repository: context.read<ScanHistoryRepositoryImpl>(),
          ),
          getScanHistoryById: GetScanHistoryById(
            repository: context.read<ScanHistoryRepositoryImpl>(),
          ),
          createScanHistory: CreateScanHistory(
            repository: context.read<ScanHistoryRepositoryImpl>(),
          ),
          deleteAllScanHistory: DeleteAllScanHistory(
            repository: context.read<ScanHistoryRepositoryImpl>(),
          ),
          deleteScanHistoryById: DeleteScanHistoryById(
            repository: context.read<ScanHistoryRepositoryImpl>(),
          ),
        ),
        child: child,
      ),
    );
  }
}