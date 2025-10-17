import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:klaxcrm/data/models/checklist_model.dart';
import '../viewmodels/checklist_viewmodel.dart';

class DocumentacionWidget extends StatefulWidget {
  final String token;
  final int idCrmTicketFk;

  const DocumentacionWidget({
    super.key,
    required this.token,
    required this.idCrmTicketFk,
  });

  @override
  State<DocumentacionWidget> createState() => _DocumentacionWidgetState();
}

class _DocumentacionWidgetState extends State<DocumentacionWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarFuenteYSubir(
      BuildContext context, ChecklistModel item, int idTicket) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tomar foto"),
                onTap: () => Navigator.pop(context, 'camara'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Seleccionar desde galería"),
                onTap: () => Navigator.pop(context, 'galeria'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("Seleccionar PDF"),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancelar"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    if (opcion == null) return;

    File? archivo;

    if (opcion == 'camara') {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) archivo = File(picked.path);
    } else if (opcion == 'galeria') {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) archivo = File(picked.path);
    } else if (opcion == 'pdf') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        archivo = File(result.files.single.path!);
      }
    }

    if (archivo == null) return;

    final mimeType = lookupMimeType(archivo.path);
    final fileSize = await archivo.length();

    final esPdf = mimeType == 'application/pdf';
    final esImagen = mimeType?.startsWith('image/') ?? false;

    if (!esPdf && !esImagen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo se permite PDF o imagen')),
      );
      return;
    }

    if (fileSize > 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tamaño máximo permitido: 1MB')),
      );
      return;
    }

    final confirmarReemplazo = item.idCrmChecklistTicket != null;
    if (confirmarReemplazo) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("¿Reemplazar archivo?"),
          content: const Text("Este documento ya ha sido subido. ¿Deseas reemplazarlo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Reemplazar"),
            ),
          ],
        ),
      );
      if (confirmar != true) return;
    }

    final vm = context.read<ChecklistViewModel>();
    await vm.subirArchivo(item: item, archivo: archivo, idTicket: idTicket);

    final msg = vm.errorMessage == null
        ? 'Documento subido correctamente'
        : vm.errorMessage!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _descargarYAbrirArchivo(
      BuildContext context, ChecklistModel item) async {
    final vm = context.read<ChecklistViewModel>();
    final bytes = await vm.descargarArchivo(item.idCrmChecklistTicket);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'No se pudo descargar el documento'),
        ),
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${item.nombreDocumento ?? 'documento.pdf'}';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await OpenFilex.open(path);
  }

  Widget _buildCard(BuildContext context, ChecklistModel item, int idTicket) {
    final bool estaSubido = item.idCrmChecklistTicket != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _seleccionarFuenteYSubir(context, item, idTicket),
        onLongPress: estaSubido
            ? () => _descargarYAbrirArchivo(context, item)
            : null,
        child: SizedBox(
          height: 160,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                estaSubido ? Icons.file_present : Icons.upload_file,
                size: 50,
                color: estaSubido ? Colors.green : Colors.blueGrey,
              ),
              const SizedBox(height: 10),
              Text(
                item.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                estaSubido
                    ? "Archivo subido exitosamente"
                    : "Toca para seleccionar",
                style: TextStyle(
                  fontSize: 14,
                  color: estaSubido ? Colors.green : Colors.grey,
                ),
              ),
              if (estaSubido)
                const Text(
                  "(Mantén pulsado para descargar)",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChecklistViewModel>();
    final docs = vm.checklist;

    if (docs.isEmpty) {
      return const Center(child: Text('No hay checklist disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: docs
            .map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCard(context, e, widget.idCrmTicketFk),
          ),
        )
            .toList(),
      ),
    );
  }
}