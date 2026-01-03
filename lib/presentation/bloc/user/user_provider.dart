import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';
import 'package:se501_plantheon/data/datasources/user_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/auth_repository_impl.dart';
import 'package:se501_plantheon/data/repository/user_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/user/get_profile.dart';
import 'package:se501_plantheon/domain/usecases/user/update_profile.dart';
import 'package:se501_plantheon/domain/usecases/user/delete_account.dart';
import 'package:se501_plantheon/presentation/bloc/auth/auth_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_bloc.dart';
import 'package:se501_plantheon/presentation/bloc/user/user_event.dart';

class UserProvider extends StatelessWidget {
  final Widget child;
  final String baseUrl;

  const UserProvider({
    super.key,
    required this.child,
    this.baseUrl = ApiConstants.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRemoteDataSource>(
          create: (context) => UserRemoteDataSourceImpl(
            client: http.Client(),
            baseUrl: baseUrl,
            tokenStorage:
                (context.read<AuthBloc>().authRepository as AuthRepositoryImpl)
                    .tokenStorage,
          ),
        ),
        RepositoryProvider<UserRepositoryImpl>(
          create: (context) => UserRepositoryImpl(
            remoteDataSource: context.read<UserRemoteDataSource>(),
          ),
        ),
      ],
      child: BlocProvider<UserBloc>(
        create: (context) => UserBloc(
          getProfile: GetProfile(
            repository: context.read<UserRepositoryImpl>(),
          ),
          updateProfile: UpdateProfile(
            repository: context.read<UserRepositoryImpl>(),
          ),
          deleteAccount: DeleteAccount(
            repository: context.read<UserRepositoryImpl>(),
          ),
        )..add(FetchProfileEvent()),
        child: child,
      ),
    );
  }
}