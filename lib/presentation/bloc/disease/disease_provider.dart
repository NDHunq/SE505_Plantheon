import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/get_disease.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';

class DiseaseProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const DiseaseProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.diseaseApiUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DiseaseRemoteDataSource>(
          create: (context) => DiseaseRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
          ),
        ),
        RepositoryProvider<DiseaseRepositoryImpl>(
          create: (context) => DiseaseRepositoryImpl(
            remoteDataSource: context.read<DiseaseRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider<DiseaseBloc>(
        create: (context) => DiseaseBloc(
          getDisease: GetDisease(
            repository: context.read<DiseaseRepositoryImpl>(),
          ),
        ),
        child: child,
      ),
    );
  }
}
