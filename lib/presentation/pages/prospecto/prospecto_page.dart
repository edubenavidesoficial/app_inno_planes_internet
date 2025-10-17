import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/ticket_service.dart';
import '../../../data/models/prospecto_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../../presentation/widgets/documentacion_widget.dart';
import '../../../presentation/pages/serving/solicitud_page.dart' as page;
import '../../../presentation/viewmodels/solicitud_viewmodel.dart' as solVm;
import '../../viewmodels/checklist_viewmodel.dart' as chkVm;
import '../../widgets/prospecto_form_widget.dart';
import '../../../presentation/pages/prospecto/acciones_page.dart';
import '../../../presentation/viewmodels/acciones_viewmodel.dart';

class ProspectoPage extends StatefulWidget {
  final String token;
  final int id_ticket;

  const ProspectoPage({Key? key, required this.token, required this.id_ticket})
      : super(key: key);

  @override
  State<ProspectoPage> createState() => _ProspectoPageState();
}

class _ProspectoPageState extends State<ProspectoPage>
    with SingleTickerProviderStateMixin {
  final _ticketService = TicketService();
  late TabController _tabController;
  TicketModel? _ticket;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    cargarTicket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> cargarTicket() async {
    final loaded = await _ticketService.getTicketPorId(
      widget.id_ticket,
      token: widget.token,
    );
    if (mounted) {
      setState(() {
        _ticket = loaded;
        _cargando = false;
      });
    }
  }

  void actualizarProspecto(ProspectoModel prospecto) {
    if (_ticket == null) return;
    final index = _ticket!.prospectos.indexWhere(
          (p) => p.idCrmProspecto == prospecto.idCrmProspecto,
    );
    if (index != -1) {
      setState(() {
        _ticket!.prospectos[index] = prospecto;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_ticket == null) {
      return const Scaffold(
        body: Center(child: Text("No se pudo cargar el ticket")),
      );
    }

    // Aquí se crean los ViewModels con el ticket cargado
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<solVm.SolicitudViewModel>(
          create: (_) => solVm.SolicitudViewModel(_ticket!, token: widget.token),
        ),
        ChangeNotifierProvider<chkVm.ChecklistViewModel>(
          create: (_) => chkVm.ChecklistViewModel(_ticket!, token: widget.token),
        ),
        ChangeNotifierProvider<AccionesViewModel>(
          create: (_) => AccionesViewModel(widget.token, _ticket!.idCrmTicket),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Formulario Prospecto"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Prospecto"),
              Tab(text: "Servicio"),
              Tab(text: "Documentación"),
              Tab(text: "Acciones"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Prospecto
            _ticket!.prospectos.isNotEmpty
                ? ProspectoFormWidget(
              token: widget.token,
              prospecto: _ticket!.prospectos.first,
              onUpdate: actualizarProspecto,
            )
                : const Center(child: Text("No hay prospectos")),

            // Tab 2: Servicio
            _ticket!.prospectos.isNotEmpty
                ? Builder(
              builder: (context) {
                final ruc = _ticket!.prospectos.first.ruc;
                if (ruc == null || ruc.isEmpty) {
                  return const Center(
                      child: Text("RUC no disponible para este prospecto"));
                } else {
                  print('Tab 2: ruc que se pasa: $ruc');
                  return page.SolicitudPage(
                    token: widget.token,
                    ruc: ruc,
                  );
                }
              },
            )
                : const Center(child: Text("No hay prospectos")),

            // Tab 3: Documentación
            DocumentacionWidget(
              token: widget.token,
              idCrmTicketFk: _ticket!.idCrmTicket,
            ),

            // Tab 4: Acciones
            AccionesPage(
              token: widget.token,
              idCrmTicket: _ticket!.idCrmTicket,
            ),
          ],
        ),
      ),
    );
  }
}
