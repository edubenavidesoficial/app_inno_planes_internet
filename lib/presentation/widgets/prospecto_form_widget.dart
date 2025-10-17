import 'package:flutter/material.dart';
import 'package:klaxcrm/presentation/widgets/ubicacion_modal.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:klaxcrm/presentation/widgets/free_map_picker.dart';
import '../../core/services/prospecto_service.dart';
import '../../core/services/ubicacion_service.dart';
import '../../data/models/parroquia_model.dart';
import '../../data/models/prospecto_model.dart';

class ProspectoFormWidget extends StatefulWidget {
  final String token;
  final ProspectoModel prospecto;
  final void Function(ProspectoModel) onUpdate;

  const ProspectoFormWidget({
    Key? key,
    required this.token,
    required this.prospecto,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<ProspectoFormWidget> createState() => _ProspectoFormWidgetState();
}

class _ProspectoFormWidgetState extends State<ProspectoFormWidget> {
  late TextEditingController dniController;
  late TextEditingController nombreController;
  late TextEditingController telefonoController;
  late TextEditingController movilController;
  late TextEditingController emailController;
  late TextEditingController direccionController;
  late TextEditingController nacimientoController;
  late TextEditingController conadisController;
  late TextEditingController _mapAddressCtrl;

  int? idCiuParroquiaFK;
  String? nombreUbicacion;
  ParroquiaModel? parroquiaSeleccionado;
  final _formKey = GlobalKey<FormState>();
  final _prospectoService = ProspectoService();
  double? _lat;
  double? _lng;
  String? _gps;
  static const String _MAPTILER_KEY = 'p39UpsxMfZlfsqbuHUpm';

  @override
  void initState() {
    super.initState();
    cargarProspecto();
  }

  Future<void> cargarProspecto() async {
    // Inicialización segura de los TextEditingController
    dniController = TextEditingController(text: widget.prospecto.ruc ?? '');
    nombreController = TextEditingController(
      text: widget.prospecto.nombre ?? '',
    );
    telefonoController = TextEditingController(
      text: widget.prospecto.telefono ?? '',
    );
    movilController = TextEditingController(text: widget.prospecto.movil ?? '');
    emailController = TextEditingController(text: widget.prospecto.email ?? '');
    direccionController = TextEditingController(
      text: widget.prospecto.direccion ?? '',
    );
    nacimientoController = TextEditingController(
      text: widget.prospecto.fecNacimiento != null
          ? widget.prospecto.fecNacimiento!.toIso8601String().split("T")[0]
          : '',
    );
    conadisController = TextEditingController(
      text: widget.prospecto.carnetConadis ?? '',
    );

    // GPS seguro
    _gps = widget.prospecto.gps;
    if (_gps != null && _gps!.contains(',')) {
      final parts = _gps!.split(',');
      _lat = double.tryParse(parts[0].trim());
      _lng = double.tryParse(parts[1].trim());
    } else {
      _lat = null;
      _lng = null;
      _gps = '';
    }
    _mapAddressCtrl = TextEditingController(text: _gps ?? '');

    // Ubicación
    idCiuParroquiaFK = widget.prospecto.idCiuParroquiaFk;
    if (idCiuParroquiaFK != null) {
      final ubicacionService = UbicacionService();
      final parroquia = await ubicacionService.getParroquiaPorId(
        idCiuParroquiaFK!,
        token: widget.token,
      );
      setState(() {
        nombreUbicacion = parroquia?.nombre ?? 'Sin nombre';
      });
    }

    setState(() {}); // refrescar UI
  }

  Future<void> actualizarProspecto() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "idCrmProspecto": widget.prospecto.idCrmProspecto,
      "dni": widget.prospecto.dni ?? '',
      "idCrmTicket": widget.prospecto.idCrmTicketFk,
      "ruc": dniController.text.trim(),
      "nombre": nombreController.text.trim(),
      "telefono": telefonoController.text.trim(),
      "movil": movilController.text.trim(),
      "email": emailController.text.trim(),
      "direccion": direccionController.text.trim(),
      "idCiuParroquiaFk": idCiuParroquiaFK,
      "fecNacimiento": nacimientoController.text.trim(),
      "carnetConadis": conadisController.text.trim(),
      "gps": _gps,
    };

    final result = await _prospectoService.guardarProspecto(widget.token, data);
    if (result.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['mensaje'] ?? 'Error desconocido')),
      );
      if (result['codigo'] == 0) {
        sincronizarProspecto();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se ha producido un error contacte con el administrador',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    dniController.dispose();
    nombreController.dispose();
    telefonoController.dispose();
    movilController.dispose();
    emailController.dispose();
    direccionController.dispose();
    nacimientoController.dispose();
    conadisController.dispose();
    _mapAddressCtrl.dispose();
    super.dispose();
  }

  void sincronizarProspecto() {
    final actualizado = widget.prospecto.copyWith(
      dni: dniController.text,
      nombre: nombreController.text,
      telefono: telefonoController.text,
      movil: movilController.text,
      email: emailController.text,
      direccion: direccionController.text,
      carnetConadis: conadisController.text,
      fecNacimiento:
          DateTime.tryParse(nacimientoController.text) ??
          widget.prospecto.fecNacimiento,
      gps: _gps ?? widget.prospecto.gps,
    );
    widget.onUpdate(actualizado);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextField(
              controller: dniController,
              decoration: const InputDecoration(labelText: "NUI"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombres *"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: movilController,
              decoration: const InputDecoration(labelText: "Celular *"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),

            // Ubicación
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(nombreUbicacion ?? 'Sin seleccionar'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.map),
                  tooltip: 'Seleccionar parroquia',
                  onPressed: () async {
                    final parroquia = await showDialog<ParroquiaModel?>(
                      context: context,
                      builder: (_) => UbicacionModal(
                        token: widget.token,
                        id_seleccionado: idCiuParroquiaFK,
                        nivel: NivelUbicacion.parroquia,
                      ),
                    );

                    if (parroquia != null) {
                      setState(() {
                        parroquiaSeleccionado = parroquia;
                        idCiuParroquiaFK = parroquia.id;
                        nombreUbicacion = parroquia.nombre;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mapAddressCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Dirección (mapa)',
                      border: OutlineInputBorder(),
                      hintText: 'Selecciona en el mapa…',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.location_on),
                  tooltip: 'Seleccionar en el mapa',
                  onPressed: () async {
                    final picked = await FreeMapPicker.show(
                      context,
                      maptilerApiKey: _MAPTILER_KEY,
                      initial: (_lat != null && _lng != null)
                          ? ml.LatLng(_lat!, _lng!)
                          : null,
                      initialAddress: _mapAddressCtrl.text.isNotEmpty
                          ? _mapAddressCtrl.text
                          : null,
                      title: 'Seleccionar ubicación',
                    );
                    if (picked != null) {
                      setState(() {
                        _lat = picked.lat;
                        _lng = picked.lng;
                        _gps = '${picked.lat},${picked.lng}';
                        _mapAddressCtrl.text = _gps!;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: direccionController,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: nacimientoController,
              decoration: const InputDecoration(labelText: "Fecha Nacimiento"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(nacimientoController.text) ?? DateTime.now(),
                  firstDate: DateTime(1900), // Fecha mínima seleccionable
                  lastDate: DateTime.now(), // Fecha máxima seleccionable
                );

                if (pickedDate != null) {
                  // Formatear la fecha como YYYY-MM-DD
                  String formattedDate =
                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  setState(() {
                    nacimientoController.text = formattedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              ],
              controller: conadisController,
              decoration: const InputDecoration(labelText: "Carnet Conadis"),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: actualizarProspecto,
              child: const Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
