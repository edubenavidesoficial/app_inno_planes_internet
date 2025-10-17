import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:klaxcrm/presentation/widgets/ubicacion_modal.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:klaxcrm/presentation/widgets/free_map_picker.dart';

import '../../../core/services/ubicacion_service.dart';
import '../../../core/services/buro_service.dart';
import '../../../core/services/equifax_service.dart';
import '../../../data/models/barrio_model.dart';
import '../../../data/models/buro_model.dart';
import '../../../data/models/equifax_pdf_response.dart';
import '../../../data/models/formapago_model.dart';
import '../../../data/models/plan_model..dart';
import '../../viewmodels/solicitud_viewmodel.dart';
import '../../widgets/registro_tarjeta_dialog.dart';

class SolicitudPage extends StatefulWidget {
  final String token;
  final String ruc;

  const SolicitudPage({Key? key, required this.token, required this.ruc})
    : super(key: key);

  @override
  State<SolicitudPage> createState() => _SolicitudPageState();
}

class _SolicitudPageState extends State<SolicitudPage> {
  final TextEditingController direccionCtrl = TextEditingController();
  final TextEditingController costoCtrl = TextEditingController();
  final TextEditingController permanenciaCtrl = TextEditingController();
  final TextEditingController megasCtrl = TextEditingController();
  final TextEditingController totalSinIvaCtrl = TextEditingController();
  final TextEditingController ctaNumeroCtrl = TextEditingController();
  final TextEditingController valorDebitarCtrl = TextEditingController();
  final TextEditingController nuiCtrl = TextEditingController();
  final TextEditingController titularCtrl = TextEditingController();
  final TextEditingController gpsCtrl = TextEditingController();

  String? _lat;
  String? _lng;
  String? _gps;
  int? idCiuBarrioFK;
  String? nombreUbicacion;
  bool _isPdfLoading = false;
  bool? tarjeta = false;
  String? ruc;

  EquifaxPdfResponse? equifaxPdf;
  BuroResponse? buroResponse;

  static const String _MAPTILER_KEY = 'p39UpsxMfZlfsqbuHUpm';

  @override
  void initState() {
    super.initState();
    ruc = widget.ruc;

    cargarSolicitud();
    cargarPdfEquifax();

    //  Buró es independiente → consulta directo con el RUC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.ruc.isNotEmpty) {
        String rucParaConsulta = widget.ruc;
        if (rucParaConsulta.length > 10) {
          rucParaConsulta = rucParaConsulta.substring(0, 10);
        }
        consultarBuroConRuc(rucParaConsulta);
      }
    });
  }

  Future<void> cargarPdfEquifax() async {
    try {
      setState(() {
        _isPdfLoading = true;
      });
      final viewModel = Provider.of<SolicitudViewModel>(context, listen: false);
      String rucParaPdf = viewModel.solicitud.debitoRuc ?? '';
      if (rucParaPdf.isEmpty) return;

      if (rucParaPdf.length > 10) {
        rucParaPdf = rucParaPdf.substring(0, 10);
      }

      final pdfResponse = await EquifaxService().generarPdf(
        rucParaPdf,
        widget.token,
      );
      setState(() {
        equifaxPdf = pdfResponse.codigo == '0' ? pdfResponse : null;
        _isPdfLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar PDF Equifax: $e")),
      );
      setState(() {
        _isPdfLoading = false;
      });
    }
  }

  Future<void> consultarBuroConRuc(String ruc) async {
    try {
      String rucConsulta = ruc;
      if (rucConsulta.length > 10) {
        rucConsulta = rucConsulta.substring(0, 10);
      }
      final buro = await BuroService().consultarBuro(
        'C',
        rucConsulta,
        widget.token,
      );
      setState(() {
        buroResponse = buro;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buró consultado: ${buro.puntuacion}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al consultar Buró: $e')));
    }
  }

  Future<void> descargarPdfEquifax() async {
    if (equifaxPdf == null) return;
    setState(() => _isPdfLoading = true); // Iniciar la carga

    try {
      final bytes = base64Decode(equifaxPdf!.base64);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${equifaxPdf!.filename}');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al abrir PDF: $e")));
    } finally {
      setState(() => _isPdfLoading = false);
    }
  }

  Future<void> cargarSolicitud() async {
    final viewModel = Provider.of<SolicitudViewModel>(context, listen: false);
    final solicitud = viewModel.solicitud;

    direccionCtrl.text = solicitud.direccion ?? '';
    costoCtrl.text = solicitud.costoFacturar?.toString() ?? '';
    permanenciaCtrl.text = solicitud.permanenciaMinima?.toString() ?? '';
    megasCtrl.text = solicitud.numMega?.toString() ?? '';
    totalSinIvaCtrl.text = solicitud.valorPlan?.toString() ?? '';
    ctaNumeroCtrl.text = solicitud.ctaNumero ?? '';
    valorDebitarCtrl.text = solicitud.valorDebitar?.toString() ?? '';
    nuiCtrl.text = solicitud.debitoRuc ?? '';
    titularCtrl.text = solicitud.debitoNombre ?? '';
    if ((solicitud.latitud?.isNotEmpty ?? false) &&
        (solicitud.longitud?.isNotEmpty ?? false)) {
      _lat = solicitud.latitud ?? '0';
      _lng = solicitud.longitud ?? '0';
      gpsCtrl.text = '${solicitud.latitud},${solicitud.longitud}';
    }

    idCiuBarrioFK = solicitud.idCiuBarrioFk;
    if (idCiuBarrioFK != null) {
      final ubicacionService = UbicacionService();
      final barrio = await ubicacionService.getBarrioPorId(
        idCiuBarrioFK!,
        token: widget.token,
      );
      setState(() {
        nombreUbicacion = barrio?.nombre ?? 'Sin seleccionar';
      });
    }
    checkTarjeta();
  }

  Future<void> checkTarjeta() async {
    final viewModel = Provider.of<SolicitudViewModel>(context, listen: false);

    if (ruc != null && ruc!.isNotEmpty) {
      // lógica
    }

    final solicitud = viewModel.solicitud;

    if (solicitud.idCrmSolicitud != null &&
        solicitud.idCrmSolicitud! > 0 &&
        solicitud.debitoDni != null &&
        solicitud.debitoDni! > 0 &&
        solicitud.idConFormaPagoFk != null &&
        solicitud.idConFormaPagoFk == 3) {
      try {
        final respuesta = await viewModel.conectarTarjeta();
        if (respuesta.compareTo("0") == 0) {
          setState(() {
            tarjeta = true;
          });
        }
      } catch (e) {
        print('Error al conectar tarjeta: $e');
      }
    } else {
      print('Solicitud incompleta o no cumple condiciones');
    }
  }

  Future<void> consultarBuro() async {
    String rucConsulta = nuiCtrl.text.trim();
    if (rucConsulta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe ingresar un RUC válido')),
      );
      return;
    }

    if (rucConsulta.length > 10) {
      rucConsulta = rucConsulta.substring(0, 10);
    }

    try {
      final buro = await BuroService().consultarBuro(
        'C',
        rucConsulta,
        widget.token,
      );
      setState(() {
        buroResponse = buro;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buró consultado: ${buro.puntuacion}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al consultar Buró: $e')));
    }
  }

  @override
  void dispose() {
    direccionCtrl.dispose();
    costoCtrl.dispose();
    permanenciaCtrl.dispose();
    megasCtrl.dispose();
    totalSinIvaCtrl.dispose();
    ctaNumeroCtrl.dispose();
    valorDebitarCtrl.dispose();
    nuiCtrl.dispose();
    titularCtrl.dispose();
    gpsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SolicitudViewModel>(
      builder: (context, viewModel, _) {
        final solicitud = viewModel.solicitud;
        final plan = solicitud.planes.firstWhere(
          (p) => p.idConPlan == solicitud.idConPlanFk,
          orElse: () => PlanModel.empty(),
        );
        final formaPago = solicitud.formasPago.firstWhere(
          (f) => f.idConFormaPago == solicitud.idConFormaPagoFk,
          orElse: () => FormaPagoModel.empty(),
        );
        final formaPagoTipo = formaPago.tipo;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: "Plan"),
                value: solicitud.idConPlanFk,
                items: solicitud.planes
                    .where((plan) {
                      if (ruc != null && ruc!.length == 13) {
                        return plan.comportamiento == 'c';
                      } else {
                        return plan.comportamiento == 'h';
                      }
                    })
                    .map((plan) {
                      return DropdownMenuItem(
                        value: plan.idConPlan,
                        child: Text(plan.detalle),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  final selected = solicitud.planes.firstWhere(
                    (p) => p.idConPlan == value,
                    orElse: () => PlanModel.empty(),
                  );

                  if (selected.comportamiento == 'h') {
                    valorDebitarCtrl.text = selected.tarifaCompletaDes
                        .toString();
                    viewModel.updateSolicitud(
                      idConPlanFk: value,
                      valorDebitar: selected.tarifaCompletaDes,
                    );
                  } else if (selected.comportamiento == 'c') {
                    costoCtrl.text = selected.insCompleto.toString();
                    viewModel.updateSolicitud(
                      idConPlanFk: value,
                      costoFacturar: selected.insCompleto,
                    );
                  } else {
                    viewModel.updateSolicitud(idConPlanFk: value);
                  }
                },
              ),
              if (plan.comportamiento == 'c') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: megasCtrl,
                  decoration: const InputDecoration(
                    labelText: "Número de megas",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => viewModel.updateSolicitud(
                    numMega: double.tryParse(value),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: totalSinIvaCtrl,
                  decoration: const InputDecoration(
                    labelText: "Total (Sin IVA)",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    viewModel.updateSolicitud(valorPlan: parsed);
                    valorDebitarCtrl.text = parsed?.toString() ?? '';
                    viewModel.updateSolicitud(valorPlan: parsed);
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Casa propia"),
                value: solicitud.idConCasaFk,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Propia")),
                  DropdownMenuItem(value: 2, child: Text("Familiares")),
                  DropdownMenuItem(value: 3, child: Text("Arriendo + 36meses")),
                  DropdownMenuItem(value: 4, child: Text("Otro")),
                ],
                onChanged: (value) =>
                    viewModel.updateSolicitud(idConCasaFk: value),
              ),
              const SizedBox(height: 16),
              if (solicitud.conveniosDebito.isNotEmpty)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Convenio débito",
                  ),
                  value: solicitud.idConConvenioPagoFk,
                  items: solicitud.conveniosDebito.map((convenio) {
                    return DropdownMenuItem(
                      value: convenio.idConConvenioPago,
                      child: Text(convenio.convenio),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      viewModel.updateSolicitud(idConConvenioPagoFk: value),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                        text: buroResponse?.puntuacion.toString() ?? '',
                      ),
                      readOnly: true, //
                      decoration: const InputDecoration(
                        labelText: '000',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  ElevatedButton.icon(
                    onPressed: _isPdfLoading || equifaxPdf == null
                        ? null
                        : descargarPdfEquifax,
                    icon: _isPdfLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: const Text("Equifax"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Ubicación'),
                      child: Text(nombreUbicacion ?? 'Sin seleccionar'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map),
                    onPressed: () async {
                      final barrio = await showDialog<BarrioModel?>(
                        context: context,
                        builder: (_) => UbicacionModal(
                          token: widget.token,
                          id_seleccionado: idCiuBarrioFK,
                          nivel: NivelUbicacion.barrio,
                        ),
                      );
                      if (barrio != null) {
                        setState(() {
                          idCiuBarrioFK = barrio.id;
                          nombreUbicacion = barrio.nombre;
                          viewModel.updateSolicitud(idCiuBarrioFk: barrio.id);
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
                      controller: gpsCtrl,
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
                            ? ml.LatLng(
                                double.parse(_lat!),
                                double.parse(_lng!),
                              )
                            : null,
                        initialAddress: gpsCtrl.text.isNotEmpty
                            ? gpsCtrl.text
                            : null,
                        title: 'Seleccionar ubicación',
                      );
                      if (picked != null) {
                        setState(() {
                          _lat = picked.lat.toString();
                          _lng = picked.lng.toString();
                          _gps = '${picked.lat},${picked.lng}';
                          gpsCtrl.text = _gps!;
                          viewModel.updateSolicitud(latitud: _lat.toString());
                          viewModel.updateSolicitud(longitud: _lng.toString());
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: direccionCtrl,
                decoration: const InputDecoration(labelText: "Dirección"),
                onChanged: (value) =>
                    viewModel.updateSolicitud(direccion: value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costoCtrl,
                decoration: const InputDecoration(
                  labelText: "Costo instalación",
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => viewModel.updateSolicitud(
                  costoFacturar: double.tryParse(value),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Permanencia mínima (meses)",
                ),
                value: solicitud.permanenciaMinima,
                items: const [
                  DropdownMenuItem(value: 24, child: Text("24")),
                  DropdownMenuItem(value: 36, child: Text("36")),
                ],
                onChanged: (value) => viewModel.updateSolicitud(
                  permanenciaMinima: value,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Forma de pago"),
                value: solicitud.idConFormaPagoFk ?? 0,
                items: [
                  const DropdownMenuItem(value: 0, child: Text("Efectivo")),
                  ...solicitud.formasPago.map((f) {
                    return DropdownMenuItem(
                      value: f.idConFormaPago,
                      child: Text(f.institucion),
                    );
                  }),
                ],
                onChanged: (value) =>
                    viewModel.updateSolicitud(idConFormaPagoFk: value),
              ),
              if (formaPagoTipo == '0' || formaPagoTipo == '1') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nuiCtrl,
                        decoration: const InputDecoration(
                          labelText: "NUI del titular",
                        ),
                        onChanged: (value) {
                          String debitoRucValue = value;
                          if (debitoRucValue.length > 10) {
                            debitoRucValue = debitoRucValue.substring(0, 10);
                          }
                          viewModel.updateSolicitud(debitoRuc: debitoRucValue);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      icon: const Icon(Icons.search),
                      tooltip: 'Consultar Cliente',
                      onPressed: () async {
                        final msg = await viewModel.consultarTaxdni();
                        if (msg.compareTo("0") == 0) {
                          nuiCtrl.text = solicitud.debitoRuc.toString();
                          titularCtrl.text = solicitud.debitoNombre.toString();
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    tarjeta == true
                        ? IconButton.filled(
                            icon: const Icon(Icons.add_card),
                            tooltip: 'Conectar',
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (_) => RegistroTarjetaDialog(
                                  idTarjeta: solicitud.idTarjeta!,
                                ),
                              );
                            },
                          )
                        : SizedBox(height: 0),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titularCtrl,
                  decoration: const InputDecoration(
                    labelText: "Titular cuenta/tarjeta",
                  ),
                  onChanged: (value) =>
                      viewModel.updateSolicitud(debitoNombre: value),
                ),
              ],
              if (formaPagoTipo == '0') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Institucion"),
                  value: solicitud.idConFormaPagoSubFk ?? null,
                  items: [
                    ...solicitud.instituciones.map((f) {
                      return DropdownMenuItem(
                        value: f.idConFormaPagoSub,
                        child: Text(f.institucion),
                      );
                    }),
                  ],
                  onChanged: (value) =>
                      viewModel.updateSolicitud(idConFormaPagoSubFk: value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Tipo de cuenta",
                  ),
                  value: solicitud.ctaTipo,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Cta Ahorros")),
                    DropdownMenuItem(value: 1, child: Text("Cta Corriente")),
                  ],
                  onChanged: (value) =>
                      viewModel.updateSolicitud(ctaTipo: value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctaNumeroCtrl,
                  decoration: const InputDecoration(
                    labelText: "Número de cuenta",
                  ),
                  onChanged: (value) =>
                      viewModel.updateSolicitud(ctaNumero: value),
                ),
              ],
              if (formaPagoTipo == '0' || formaPagoTipo == '1') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: valorDebitarCtrl,
                  decoration: const InputDecoration(
                    labelText: "Valor a debitar",
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => viewModel.updateSolicitud(
                    valorDebitar: double.tryParse(value),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final msg = await viewModel.guardarSolicitud();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(msg)));
                        checkTarjeta();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar"),
                    ),
            ],
          ),
        );
      },
    );
  }
}
