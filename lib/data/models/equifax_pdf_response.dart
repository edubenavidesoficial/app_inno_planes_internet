class EquifaxPdfResponse {
  final String codigo;
  final String filename;
  final String base64;

  EquifaxPdfResponse({
    required this.codigo,
    required this.filename,
    required this.base64,
  });

  factory EquifaxPdfResponse.fromJson(Map<String, dynamic> json) {
    return EquifaxPdfResponse(
      codigo: json['codigo'] ?? '',
      filename: json['filename'] ?? '',
      base64: json['base64'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"codigo": codigo, "filename": filename, "base64": base64};
  }
}
