import 'package:se501_plantheon/domain/repository/user_repository.dart';

class DeleteAccount {
  final UserRepository repository;

  DeleteAccount({required this.repository});

  Future<void> call(String password) {
    return repository.deleteAccount(password);
  }
}
