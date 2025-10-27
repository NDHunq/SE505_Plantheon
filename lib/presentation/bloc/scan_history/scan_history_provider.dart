import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/scan_history_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/scan_history_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/scan_history/get_all_scan_history.dart';
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
        ),
        child: child,
      ),
    );
  }
}
