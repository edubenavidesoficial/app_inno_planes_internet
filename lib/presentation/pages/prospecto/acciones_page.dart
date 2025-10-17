import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ticket_service.dart';
import '../../../data/models/prospecto_model.dart';
import '../../../data/models/solicitud_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../viewmodels/acciones_viewmodel.dart';

class AccionesPage extends StatefulWidget {
  final String token;
  final int idCrmTicket;

  const AccionesPage({Key? key, required this.token, required this.idCrmTicket})
    : super(key: key);

  @override
  State<AccionesPage> createState() => _AccionesPageState();
}

class _AccionesPageState extends State<AccionesPage> {
  final _ticketService = TicketService();
  TicketModel? ticket;
  ProspectoModel? prospecto;
  SolicitudModel? solicitud;
  bool? aprobar = false;
  bool? enviar = true;
  int? estado = 0;
  int? forma_pago = 0;
  bool? documento = false;

  @override
  void initState() {
    super.initState();
    cargarSolicitud();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccionesViewModel>(
      create: (_) => AccionesViewModel(widget.token, widget.idCrmTicket),
      child: Consumer<AccionesViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            body: Stack(
              children: [
                AbsorbPointer(
                  absorbing: vm.bloqueando,
                  // Bloquea todos los toques si está cargando
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 🔹 Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _accionButton(
                              icon: Icons.note_add,
                              label: "Observación",
                              color: Colors.orange,
                              onTap: () async {
                                final obs = await _showInputDialog(
                                  context,
                                  "Ingrese observación",
                                );
                                if (obs != null && obs.isNotEmpty) {
                                  try {
                                    await vm.agregarObservacion(
                                      idCrmDice: "4",
                                      observacion: obs,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Observación agregada"),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error al agregar observación: $e",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            enviar == true
                                ? _accionButton(
                                    icon: Icons.send,
                                    label: "Comprobar Informacion",
                                    color: Colors.green,
                                    onTap: () async {
                                      try {
                                        await vm.enviarSolicitud();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Solicitud enviada correctamente",
                                            ),
                                          ),
                                        );
                                        await cargarSolicitud();
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Error al enviar solicitud: $e",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : SizedBox(height: 0),
                            (documento == true && estado == 9)
                                ? _accionButton(
                                    icon: Icons.send,
                                    label: "Enviar Instalar",
                                    color: Colors.green,
                                    onTap: () async {
                                      await _runBloqueado(vm, () async {
                                        try {
                                          await setinstalarSolicitud();
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Error al aprobar solicitud: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                  )
                                : SizedBox(height: 0),
                          ],
                        ),
                        const SizedBox(height: 24),
                        aprobar == true
                            ? _accionButton(
                                icon: Icons.check,
                                label: "Validacio Correcta Aprobar",
                                color: Colors.red,
                                onTap: () async {
                                  await _runBloqueado(vm, () async {
                                    try {
                                      await aprobarContrato();
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error al aprobar solicitud: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                              )
                            : SizedBox(height: 0),
                        (estado == 9 && documento == false)
                            ? _accionButton(
                                icon: Icons.document_scanner,
                                label: "Enviar Firma Contrato",
                                color: Colors.red,
                                onTap: () async {
                                  await _runBloqueado(vm, () async {
                                    try {
                                      await solicitudFirma("c");
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error al aprobar solicitud: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                              )
                            : const SizedBox(height: 24),
                        (estado == 9 && forma_pago == 1 && documento == false)
                            ? _accionButton(
                                icon: Icons.add_card,
                                label: "Enviar Firma Debito",
                                color: Colors.red,
                                onTap: () async {
                                  await _runBloqueado(vm, () async {
                                    try {
                                      await solicitudFirma("dc");
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error al aprobar solicitud: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                              )
                            : const SizedBox(height: 24),
                        const SizedBox(height: 24),

                        // 🔹 Lista de logs como Cards
                        vm.cargando
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: vm.logs.length,
                                itemBuilder: (context, index) {
                                  final log = vm.logs[index];

                                  // Formatear fecha
                                  String fechaFormateada = "";
                                  if (log.fecha != null &&
                                      log.fecha!.isNotEmpty) {
                                    final fecha =
                                        DateTime.tryParse(log.fecha!) ??
                                        DateTime.now();
                                    fechaFormateada =
                                        "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
                                  }

                                  // Color según estado
                                  Color estadoColor = Colors.grey;
                                  if (log.estado != null) {
                                    switch (log.estado!.toLowerCase()) {
                                      case "nuevo":
                                        estadoColor = Colors.blue;
                                        break;
                                      case "pendiente":
                                        estadoColor = Colors.orange;
                                        break;
                                      case "cerrado":
                                        estadoColor = Colors.green;
                                        break;
                                      default:
                                        estadoColor = Colors.grey;
                                    }
                                  }

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      onTap: () {
                                        // Mostrar detalle completo al tocar
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                              "Detalle del Log",
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Fecha: $fechaFormateada"),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Estado: ${log.estado ?? "NUEVO"}",
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Usuario: ${log.usuario ?? ""}",
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Observación: ${log.observacion ?? ""}",
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cerrar"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      title: Text(
                                        fechaFormateada,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: estadoColor.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              log.estado ?? "NUEVO",
                                              style: TextStyle(
                                                color: estadoColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("Usuario: ${log.usuario ?? ""}"),
                                          if (log.observacion != null &&
                                              log.observacion!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                log.observacion!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
                if (vm.bloqueando) ...[
                  Container(
                    color: Colors.black.withOpacity(
                      0.09,
                    ), // Div semitransparente encima
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> cargarSolicitud() async {
    ticket = await _ticketService.getTicketPorId(
      widget.idCrmTicket,
      token: widget.token,
    );

    prospecto = ticket?.prospectos.first;
    solicitud = ticket?.solicitudes.first;
    estado = ticket!.idCrmEstadoFk;
    forma_pago = solicitud!.idConFormaPagoFk;
    if (ticket?.idCrmEstadoFk == 7 &&
        prospecto!.idCrmProspecto! > 0 &&
        prospecto?.ruc != '' &&
        prospecto?.nombre != '' &&
        prospecto?.movil != '' &&
        prospecto?.telefono != '' &&
        prospecto?.email != '' &&
        solicitud!.idCrmSolicitud! > 0 &&
        solicitud!.idConPlanFk! > 0 &&
        solicitud!.idConCasaFk! > 0 &&
        solicitud!.idConConvenioPagoFk! >= 0 &&
        solicitud!.idCiuBarrioFk! > 0 &&
        solicitud!.latitud! != '' &&
        solicitud!.direccion! != '' &&
        solicitud!.costoFacturar! > 0 &&
        solicitud!.permanenciaMinima! > 0 &&
        solicitud!.idConFormaPagoFk! >= 0 &&
        solicitud?.con == null &&
        solicitud!.valorDebitar! > 0) {
      setState(() {
        aprobar = true;
      });
    }
    if (ticket!.idCrmEstadoFk! > 7) {
      if (solicitud?.con != null) {
        if (solicitud!.con! > 0) {
          obtenerDocumentosSolicitud();
        }
      }
      setState(() {
        enviar = false;
      });
    }
  }

  Future<void> aprobarContrato() async {
    try {
      Map<String, String> contrato = {
        "mt": "post",
        "id": widget.idCrmTicket.toString(),
        "usu": ticket!.usuGen.toString(),
        "fn": "^",
      };
      final Map<String, dynamic> resp = await _ticketService.aprobarContrato(
        contrato,
      );
      final int codigo = resp['codigo'] is int ? resp['codigo'] as int : -1;
      final String mensaje = resp['mensaje'];
      if (codigo == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        await cargarSolicitud();
        setState(() async {
          aprobar = false;
          enviar = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
      }
    } catch (e) {
      print(e);
    } finally {}
  }

  Future<void> solicitudFirma(String tipo) async {
    try {
      Map<String, String> contrato = {
        "mt": "get",
        "id": solicitud!.con.toString(),
        "tipo": tipo.toString(),
        "fn": "^",
      };
      final Map<String, dynamic> resp = await _ticketService
          .enviarSolicitudFirma(contrato);
      final int codigo = resp['codigo'] is int ? resp['codigo'] as int : -1;
      final String mensaje = resp['mensaje'];
      if (codigo == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
      }
    } catch (e) {
      print(e);
    } finally {}
  }

  Future<void> obtenerDocumentosSolicitud() async {
    try {
      Map<String, String> contrato = {
        "mt": "get",
        "id": solicitud!.con.toString(),
        "op": "firmas",
        "fn": "^",
      };
      final Map<String, dynamic> resp = await _ticketService
          .accionesSolicitudFirma(contrato);
      int num_documento = resp['num_documento'];
      int num_documento_firmado = resp['num_documento_firmado'];
      if (num_documento == num_documento_firmado) {
        documento = true;
      }
      setState(() {});
    } catch (e) {
      print(e);
    } finally {}
  }

  Future<void> setinstalarSolicitud() async {
    try {
      Map<String, String> contrato = {
        "mt": "post",
        "id": solicitud!.con.toString(),
        "op": "aprobar",
        "usu": "1",
        "fn": "^",
      };
      final Map<String, dynamic> resp = await _ticketService
          .accionesSolicitudFirma(contrato);
      final int codigo = resp['codigo'] is int ? resp['codigo'] as int : -1;
      final String mensaje = resp['mensaje'];
      if (codigo == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        await cargarSolicitud();
        setState(() async {
          documento = false;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
      }
    } catch (e) {
      print(e);
    } finally {}
  }

  Future<void> _runBloqueado(
    AccionesViewModel vm,
    Future<void> Function() callback,
  ) async {
    if (vm.bloqueando) return;
    vm.setBloqueo(true);
    try {
      await callback();
    } finally {
      vm.setBloqueo(false);
    }
  }

  // Botón estilizado
  Widget _accionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Input para observación
  Future<String?> _showInputDialog(BuildContext context, String title) async {
    String input = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          onChanged: (value) => input = value,
          decoration: const InputDecoration(hintText: "Escriba aquí..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, input),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }
}
