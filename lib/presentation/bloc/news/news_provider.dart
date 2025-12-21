import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/news_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/data/repository/news_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news.dart';
import 'package:se501_plantheon/domain/usecases/news/get_news_tags.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news/news_event.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/news_tag/news_tag_event.dart';

class NewsProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;
  final int? size;

  const NewsProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.baseUrl,
    this.size = 5,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NewsRemoteDataSource>(
          create: (context) => NewsRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
            tokenStorage:
                (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                    .tokenStorage,
          ),
        ),
        RepositoryProvider<NewsRepositoryImpl>(
          create: (context) => NewsRepositoryImpl(
            remoteDataSource: context.read<NewsRemoteDataSource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<NewsBloc>(
            create: (context) => NewsBloc(
              getNews: GetNews(repository: context.read<NewsRepositoryImpl>()),
            )..add(FetchNewsEvent(size: size)),
          ),
          BlocProvider<NewsTagBloc>(
            create: (context) => NewsTagBloc(
              getNewsTags: GetNewsTags(
                repository: context.read<NewsRepositoryImpl>(),
              ),
            )..add(FetchNewsTagsEvent()),
          ),
        ],
        child: child,
      ),
    );
  }
}
