class IdTokenModel {
  final String idToken;

  IdTokenModel({required this.idToken});

  factory IdTokenModel.fromJson(Map<String, dynamic> json) {
    return IdTokenModel(
      idToken: json['id_token'],
    );
  }
}