import 'package:flutter/foundation.dart';
import '../../../core/services/ticket_service.dart';

class TicketsViewModel extends ChangeNotifier {
  final TicketService _ticketService = TicketService();
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> tickets = [];

  Future<void> cargarTickets({required String token, required int usuGen}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      tickets = await _ticketService.getTicketsPorUsuario(
        token: token,
        usuGen: usuGen,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
