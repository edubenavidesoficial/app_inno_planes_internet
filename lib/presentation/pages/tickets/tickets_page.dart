import 'package:flutter/material.dart';
import '../../../core/services/ticket_service.dart';

class TicketsPage extends StatefulWidget {
  final String token;
  final int usuGen;
  final String userName;

  const TicketsPage({
    Key? key,
    required this.token,
    required this.usuGen,
    required this.userName,
  }) : super(key: key);

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  Future<List<Map<String, dynamic>>>? _ticketsFuture;
  List<Map<String, dynamic>> _estados = [];

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _ruc;
  int? _estadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarEstados();
  }

  Future<void> _cargarEstados() async {
    try {
      final estados = await TicketService().getEstadosCrm(token: widget.token);

      if (estados.isNotEmpty) {
         final prospectando = estados.firstWhere(
              (e) => (e['estado'] as String).toLowerCase() == 'prospectando',
          orElse: () => estados.first,
        );

        setState(() {
          _estados = estados;
          _estadoSeleccionado = prospectando['idCrmEstado'];
        });

        _fetchTicketsWithFilters();
      } else {
        setState(() {
          _estados = [];
          _estadoSeleccionado = null;
          _ticketsFuture = Future.value([]);
        });
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estados: $e')),
      );
    }
  }


  void _fetchTicketsWithFilters() {
    setState(() {
      _ticketsFuture = TicketService().getTicketsPorUsuario(
        token: widget.token,
        usuGen: widget.usuGen,
        idEstado: _estadoSeleccionado,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        ruc: _ruc,
      );
    });
  }

  void _mostrarFiltro() async {
    DateTime? tempInicio = _fechaInicio;
    DateTime? tempFin = _fechaFin;
    String? tempRuc = _ruc;
    int? tempEstado = _estadoSeleccionado;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: tempEstado,
                    decoration: const InputDecoration(labelText: "Estado"),
                    items: _estados.map((e) {
                      return DropdownMenuItem<int>(
                        value: e['idCrmEstado'],
                        child: Text(e['estado']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() => tempEstado = value);
                    },
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text:
                                tempInicio?.toIso8601String().substring(
                                  0,
                                  10,
                                ) ??
                                '',
                          ),
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Fecha Inicio",
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempInicio ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null)
                              setModalState(() => tempInicio = date);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(
                            text:
                                tempFin?.toIso8601String().substring(0, 10) ??
                                '',
                          ),
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Fecha Fin",
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempFin ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null)
                              setModalState(() => tempFin = date);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "DNI - NOMBRES - APELLIDOS",
                    ),
                    keyboardType: TextInputType.text,
                    controller: TextEditingController(text: tempRuc),
                    onChanged: (val) => tempRuc = val,
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text("Cancelar"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Aplicar Filtro"),
                        onPressed: () {
                          Navigator.pop(context, {
                            'fechaInicio': tempInicio,
                            'fechaFin': tempFin,
                            'ruc': tempRuc,
                            'estado': tempEstado,
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _fechaInicio = result['fechaInicio'];
        _fechaFin = result['fechaFin'];
        _ruc = result['ruc'];
        _estadoSeleccionado = result['estado'];
      });
      _fetchTicketsWithFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Tickets"),
        actions: [
          IconButton(
            onPressed: _mostrarFiltro,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/formulario',
          arguments: {
            'token': widget.token,
            'userName': widget.userName,
            'usuGen': widget.usuGen,
          },
        ),
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ticketsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: \${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No hay tickets"));
                  }

                  final tickets = snapshot.data!;
                  return ListView.separated(
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = tickets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/prospectos',
                              arguments: {
                                ...t,
                                'token': widget.token,
                                'id_ticket': t['idCrmTicket'],
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título: Ticket y estado
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.confirmation_number,
                                          size: 14,
                                          color: Colors.blueGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Ticket #${t['idCrmTicket'] ?? ''}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${t['estado'] ?? ''}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Nombre y RUC
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${t['nombre'] ?? ''} (${t['ruc'] ?? ''})",
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 2),

                                // Email y Teléfono en una sola línea
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${t['email'] ?? ''}",
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (t['telefono'] ?? '').toString().length >=
                                              7
                                          ? "${t['telefono']}"
                                          : "-",
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 2),

                                // Dirección
                                if ((t['direccion'] ?? '')
                                    .toString()
                                    .isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${t['direccion']}",
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
