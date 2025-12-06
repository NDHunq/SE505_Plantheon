import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/plant_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/plant_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/plant/get_plants.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/plant/plant_event.dart';

class PlantProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const PlantProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PlantRemoteDataSource>(
          create: (_) => PlantRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
          ),
        ),
        RepositoryProvider<PlantRepositoryImpl>(
          create: (context) => PlantRepositoryImpl(
            remoteDataSource: context.read<PlantRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider<PlantBloc>(
        create: (context) => PlantBloc(
          getPlants: GetPlants(repository: context.read<PlantRepositoryImpl>()),
        )..add(FetchPlantsEvent()),
        child: child,
      ),
    );
  }
}
