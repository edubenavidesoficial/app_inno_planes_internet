import 'dart:io';
import 'package:klaxcrm/data/models/checklist_model.dart';

class ChecklistItemViewModel {
  final ChecklistModel base;
  File? archivoLocal;
  bool uploading = false;
  double progress = 0.0;
  String? error;
  ChecklistItemViewModel({required this.base});
  bool get estaSubido => base.idCrmChecklistTicket != null;
  String get nombre => base.nombre;
  String? get nombreDocumento => base.nombreDocumento;
}
