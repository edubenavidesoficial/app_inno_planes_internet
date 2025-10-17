import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/prospecto_service.dart';
import '../../../core/services/equifax_service.dart';
import '../../../core/services/registro_civil_service.dart';
import '../../../core/services/ubicacion_service.dart';
import '../../../data/models/parroquia_model.dart';
import '../../../data/models/equifax_pdf_response.dart';
import '../../widgets/ubicacion_modal.dart';

class FormularioPage extends StatefulWidget {
  final String token;

  const FormularioPage({Key? key, required this.token}) : super(key: key);

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _registroCivilService = RegistroCivilService();
  final _prospectoService = ProspectoService();
  final _equifaxService = EquifaxService();
  final _formKey = GlobalKey<FormState>();


  final TextEditingController rucController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  int? idCiuParroquiaFK;
  String? nombreUbicacion;
  ParroquiaModel? parroquiaSeleccionada;
  bool camposHabilitados = false;
  bool _isLoadingPdf = false;
  bool _isLoadingConsulta = false;

  EquifaxPdfResponse? equifaxPdf; // PDF si existe

  @override
  void dispose() {
    rucController.dispose();
    nombresController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  /// -------------------- Validaciones --------------------
  String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es obligatorio';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) return 'Formato de correo inválido';
    return null;
  }

  String? validarTelefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es obligatorio';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Debe contener solo números';
    if (value.length < 7 || value.length > 10) {
      return 'Debe tener entre 7 y 10 dígitos';
    }
    return null;
  }

  /// -------------------- Widgets reutilizables --------------------
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: _getIconForLabel(label),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
      keyboardType: keyboardType,
      enabled: camposHabilitados,
      inputFormatters: formatters ?? [LengthLimitingTextInputFormatter(100)],
    );
  }

  Icon _getIconForLabel(String label) {
    switch (label) {
      case "Nombres":
        return const Icon(Icons.person);
      case "Teléfono":
        return const Icon(Icons.phone);
      case "Email":
        return const Icon(Icons.email);
      case "Dirección":
        return const Icon(Icons.location_on);
      default:
        return const Icon(Icons.text_fields);
    }
  }

  /// -------------------- Lógica --------------------
  void limpiarExceptoRuc() {
    nombresController.clear();
    telefonoController.clear();
    emailController.clear();
    direccionController.clear();
    idCiuParroquiaFK = null;
    nombreUbicacion = null;
    parroquiaSeleccionada = null;
    equifaxPdf = null;
  }

  Future<void> buscarProspecto() async {
    setState(() => _isLoadingConsulta = true);
    final ruc = rucController.text.trim();
    if (ruc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un RUC para buscar')),
      );
      return;
    }

    try {
      // -------------------- 1. CONSULTAR EN BASE LOCAL --------------------
      final result = await _prospectoService.buscarProspecto(widget.token, ruc);

      if (result.isNotEmpty) {
        final idCrmTicket = result["idCrmTicket"] ?? 0;

        if (idCrmTicket > 0) {
          // Existe con ticket abierto → abre prospectos
          Navigator.pushNamed(
            context,
            '/prospectos',
            arguments: {'token': widget.token, 'id_ticket': idCrmTicket},
          );
          return;
        } else {
          // Existe sin ticket → autocompletar datos
          setState(() {
            camposHabilitados = true;
            nombresController.text = result["nombre"] ?? "";
            telefonoController.text = result["telefono"] ?? "";
            emailController.text = result["email"] ?? "";
            direccionController.text = result["direccion"] ?? "";
            idCiuParroquiaFK = result["idCiuParroquiaFk"];
          });

          if (idCiuParroquiaFK != null) {
            final ubicacionService = UbicacionService();
            final parroquia = await ubicacionService.getParroquiaPorId(
              idCiuParroquiaFK!,
              token: widget.token,
            );
            setState(() => nombreUbicacion = parroquia?.nombre);
          }
        }
      } else {
        // -------------------- 2. CONSULTAR EN REGISTRO CIVIL --------------------
        final registroCivilService = RegistroCivilService();
        final datosCivil =
        await registroCivilService.consultarClientePorRuc(widget.token, ruc);

        if (datosCivil != null) {
          setState(() {
            camposHabilitados = true;
            nombresController.text = datosCivil.nombre ?? "";
            telefonoController.text = datosCivil.telefono ?? "";
            emailController.text = datosCivil.email ?? "";
            direccionController.text = datosCivil.direccion ?? "";
            idCiuParroquiaFK = datosCivil.idCiuParroquiaFk;
          });

          if (idCiuParroquiaFK != null) {
            final ubicacionService = UbicacionService();
            final parroquia = await ubicacionService.getParroquiaPorId(
              idCiuParroquiaFK!,
              token: widget.token,
            );
            setState(() => nombreUbicacion = parroquia?.nombre);
          }
        } else {
          // No se encontró en ningún lado
          setState(() {
            camposHabilitados = true;
            limpiarExceptoRuc();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontraron datos del RUC')),
          );
        }
      }

      // -------------------- 3. CONSULTAR SIEMPRE EN BURÓ (EQUIFAX) --------------------
      final equifax = await _equifaxService.consultarEquifax(ruc, widget.token);
      if (equifax > 0) {
        final pdfResponse = await _equifaxService.generarPdf(ruc, widget.token);
        setState(() {
          equifaxPdf = pdfResponse.codigo == '0' ? pdfResponse : null;
        });
      } else {
        setState(() => equifaxPdf = null);
      }
    } catch (e) {
      setState(() => equifaxPdf = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error en la búsqueda: $e')),
      );
    }
    finally {
      setState(() => _isLoadingConsulta = false);
    }
  }

  Future<void> descargarPdfEquifax() async {
    if (equifaxPdf == null) return;
    setState(() => _isLoadingPdf = true);

    try {
      final bytes = base64Decode(equifaxPdf!.base64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${equifaxPdf!.filename}');

      // Simular carga de 3 segundos
      for (int i = 3; i > 0; i--) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cargando PDF en $i...')),
        );
        await Future.delayed(const Duration(seconds: 1));
      }

      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al abrir PDF: $e")));
    } finally {
      setState(() => _isLoadingPdf = false);
    }
  }

  Future<void> guardarProspecto() async {
    if (!_formKey.currentState!.validate()) return;
    final ruc = rucController.text.trim();
    final idticket = await _prospectoService.existeProspecto(widget.token, ruc);
    if (idticket > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El prospecto ya está registrado')),
      );
      return;
    }

    final data = {
      "idCrmProspecto": null,
      "idCliente": null,
      "idCrmTicket": null,
      "ruc": ruc,
      "nombre": nombresController.text.trim(),
      "telefono": telefonoController.text.trim(),
      "email": emailController.text.trim(),
      "direccion": direccionController.text.trim(),
      "idCiuParroquiaFk": idCiuParroquiaFK,
    };

    final result = await _prospectoService.guardarProspecto(widget.token, data);
    if (result.isNotEmpty && result['codigo'] == 0) {
      Navigator.pushNamed(
        context,
        '/prospectos',
        arguments: {'token': widget.token, 'id_ticket': result['idCrmTicket']},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['mensaje'] ?? 'Error inesperado')),
      );
    }
  }

  /// -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Prospecto')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// RUC + botón buscar
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: rucController,
                              decoration: InputDecoration(
                                labelText: 'RUC',
                                prefixIcon: const Icon(Icons.badge),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: buscarProspecto,
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Mostrar botón solo si existe PDF
                      if (equifaxPdf != null) // Solo muestra el botón si hay un PDF
                        _isLoadingPdf
                            ? const CircularProgressIndicator() // Muestra el loader si está cargando
                            : ElevatedButton.icon(
                          onPressed: descargarPdfEquifax, // Llama a la función de descarga
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Descargar Equifax PDF"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 18,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      buildTextField(
                        controller: nombresController,
                        label: 'Nombres',
                        validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      buildTextField(
                        controller: telefonoController,
                        label: 'Teléfono',
                        validator: validarTelefono,
                        keyboardType: TextInputType.phone,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox(height: 16),

                      buildTextField(
                        controller: emailController,
                        label: 'Email',
                        validator: validarEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      /// Ubicación
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Ubicación',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(nombreUbicacion ?? 'Sin seleccionar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: camposHabilitados
                                ? () async {
                              final parroquia =
                              await showDialog<ParroquiaModel?>(
                                context: context,
                                builder: (_) => UbicacionModal(
                                  token: widget.token,
                                  id_seleccionado: idCiuParroquiaFK,
                                  nivel: NivelUbicacion.parroquia,
                                ),
                              );

                              if (parroquia != null) {
                                setState(() {
                                  parroquiaSeleccionada = parroquia;
                                  idCiuParroquiaFK = parroquia.id;
                                  nombreUbicacion = parroquia.nombre;
                                });
                              }
                            }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      buildTextField(
                        controller: direccionController,
                        label: 'Dirección',
                        validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'La dirección es obligatoria'
                            : null,
                        formatters: [LengthLimitingTextInputFormatter(255)],
                      ),
                      const SizedBox(height: 24),

                      /// Botones
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: camposHabilitados ? guardarProspecto : null,
                              icon: const Icon(Icons.save),
                              label: const Text('Generar Ticket'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  limpiarExceptoRuc();
                                  camposHabilitados = false;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpiar'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          if (_isLoadingConsulta)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
