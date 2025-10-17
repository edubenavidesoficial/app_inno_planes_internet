import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/services/solicitud_service.dart';
import '../viewmodels/solicitud_viewmodel.dart';

class RegistroTarjetaDialog extends StatefulWidget {
  final int idTarjeta;

  const RegistroTarjetaDialog({Key? key, required this.idTarjeta})
    : super(key: key);

  @override
  State<RegistroTarjetaDialog> createState() => _RegistroTarjetaDialogState();
}

class _RegistroTarjetaDialogState extends State<RegistroTarjetaDialog> {
  bool _mostrarWebView = false;
  bool _cargando = true;
  late WebViewController _webController;
  final SolicitudService _solicitudService = SolicitudService();
  Map<String, dynamic>? tarjeta;
  Map<String, dynamic>? tarjetas;
  bool _cargandoTarjeta = true;

  @override
  void initState() {
    super.initState();
    cargarTarjeta();
  }

  Future<void> cargarTarjeta() async {
    try {
      final data = {
        "op": "tarjeta",
        "id": widget.idTarjeta.toString(),
        "fn": "^",
      };
      tarjeta = await _solicitudService.conectarTarjeta(data);
    } catch (e) {
      debugPrint('❌ Error cargando tarjeta: $e');
    } finally {
      setState(() => _cargandoTarjeta = false);
    }
    cargarTarjetas();
  }

  Future<void> cargarTarjetas() async {
    try {
      final data = {
        "op": "tarjetas",
        "id": tarjeta!['ruc'].toString(),
        "idt": widget.idTarjeta.toString(),
        "fn": "^",
      };
      tarjetas = await _solicitudService.conectarTarjeta(data);
      setState(() {});
    } catch (e) {
      debugPrint('❌ Error cargando tarjeta: $e');
    } finally {
      setState(() => _cargandoTarjeta = false);
    }
  }

  Future<void> enviarTarjeta() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("se ha enviado la informacion")));
      final data = {
        "op": "enviar",
        "id": widget.idTarjeta.toString(),
        "fn": "^",
      };
      await _solicitudService.conectarTarjeta(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enviado correctamente la informacion")),
      );
    } catch (e) {
      debugPrint('❌ Error cargando tarjeta: $e');
    } finally {
      setState(() => _cargandoTarjeta = false);
    }
  }

  Future<void> abrirUrlTarjeta() async {
    try {
      if (tarjeta != null &&
          tarjeta!['id_con_contrato_tarjeta'] > 0 &&
          tarjeta!['url'] != null) {
        final uri = Uri.parse(tarjeta!['url']);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'No se pudo abrir ';
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando tarjeta: $e');
    } finally {
      setState(() => _cargandoTarjeta = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 360,
        height: _mostrarWebView ? 480 : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF78A1CB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registro de Tarjeta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const CircleAvatar(
                      radius: 12,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            _cargandoTarjeta
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  enviarTarjeta();
                                },
                                child: const Text('Enviar link de registro'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  abrirUrlTarjeta();
                                },
                                child: const Text('Registrar en Sistema'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        buildTarjetasList(),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildTarjetasList() {
    if (tarjetas == null || tarjetas!['data'] == null) return SizedBox();

    List<Widget> cardWidgets = [];

    for (var persona in tarjetas!['data']) {
      final nombre = persona['name'];
      final document = persona['document'];
      final cards = persona['cards'] as List<dynamic>;

      for (var card in cards) {
        final createdAt =
            DateTime.tryParse(card['created_at'] ?? '') ?? DateTime.now();
        final fecha =
            "${createdAt.day.toString().padLeft(2, '0')}/"
            "${createdAt.month.toString().padLeft(2, '0')}/"
            "${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:"
            "${createdAt.minute.toString().padLeft(2, '0')}";

        final marca = card['card_brand']?.toUpperCase() ?? "TARJETA";
        final numero = card['number'] ?? "****";

        cardWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fecha,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NUEVO',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Usuario: $nombre",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Documento: $document",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$marca $numero",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(children: cardWidgets);
  }
}
