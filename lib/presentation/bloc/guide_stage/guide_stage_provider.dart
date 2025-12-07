import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/guide_stage_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/guide_stage_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/guide_stage/get_guide_stages_by_plant.dart';
import 'package:se501_plantheon/presentation/bloc/guide_stage/guide_stage_bloc.dart';

class GuideStageProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const GuideStageProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GuideStageRemoteDataSource>(
          create: (_) => GuideStageRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
          ),
        ),
        RepositoryProvider<GuideStageRepositoryImpl>(
          create: (context) => GuideStageRepositoryImpl(
            remoteDataSource: context.read<GuideStageRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider<GuideStageBloc>(
        create: (context) => GuideStageBloc(
          getGuideStagesByPlant: GetGuideStagesByPlant(
            repository: context.read<GuideStageRepositoryImpl>(),
          ),
        ),
        child: child,
      ),
    );
  }
}
