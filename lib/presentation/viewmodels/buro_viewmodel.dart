import 'package:flutter/foundation.dart';
import '../../../core/services/buro_service.dart';
import '../../../data/models/buro_model.dart';

class BuroViewModel extends ChangeNotifier {
  final BuroService _buroService = BuroService();
  BuroResponse? buroData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> getBuro(String tipoDoc, String ruc, String token) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      buroData = await _buroService.consultarBuro(tipoDoc, ruc, token);
    } catch (e) {
      errorMessage = "Error consultando buró: $e";
      print(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
