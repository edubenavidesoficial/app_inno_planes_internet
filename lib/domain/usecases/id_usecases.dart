import 'package:dio/dio.dart';
import '/domain/repositories/id_repository.dart';

class AuthenticateUserUseCase {
  final IdRepository repository;
  AuthenticateUserUseCase(this.repository);

  Future<String> call(String username, String password) {
    return repository.authenticate(username, password);
  }
}

class ValidateFaceUseCase {
  final IdRepository repository;
  ValidateFaceUseCase(this.repository);

  Future<Response> call({
    required bool useRce,
    required String photo,
  }) {
    if (useRce) {
      return repository.validateFaceWithRCE(photo);
    } else {
      return repository.validatePhotoWithoutRCE(photo);
    }
  }
}