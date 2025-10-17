import 'package:dio/dio.dart';

abstract class IdRepository {
  Future<String> authenticate(String username, String password);
  Future<Response> validateFaceWithRCE(String photo);
  Future<Response> validatePhotoWithoutRCE(String photo);
  Future<Response> validateFront(String frontPhoto);
  Future<Response> validateBack(String backPhoto);
  Future<Response> validateSelfie(String selfiePhoto);
  Future<Response> generateEvidence(Map<String, dynamic> data);
}