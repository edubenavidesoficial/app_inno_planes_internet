import 'package:dio/dio.dart';
import '../../core/id4face/id_service.dart';
import '../../domain/repositories/id_repository.dart';

/* class IdRepositoryImpl implements IdRepository {
  final IdService _idService;

  IdRepositoryImpl(this._idService);

  @override
  Future<String> authenticate(String username, String password) async {
    final response = await _idService.authenticate(username, password);
    return response.data['id_token'] as String;
  }

  @override
  Future<Response> validateFaceWithRCE(String photo) {
    return _idService.validateFaceWithRCE(photo);
  }

 @override
  Future<Response> validatePhotoWithoutRCE(String photo) {
    return _idService.validatePhotoWithoutRCE(photo);
  }

  @override
  Future<Response> validateFront(String frontPhoto) {
    return _idService.validateFront(frontPhoto);
  }

  @override
  Future<Response> validateBack(String backPhoto) {
    return _idService.validateBack(backPhoto);
  }

  @override
  Future<Response> validateSelfie(String selfiePhoto) {
    return _idService.validateSelfie(selfiePhoto);
  }

  @override
  Future<Response> generateEvidence(Map<String, dynamic> data) {
    return _idService.generateEvidence(data);
  }
}
*/
