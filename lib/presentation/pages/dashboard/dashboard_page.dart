// Archivo: dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../presentation/widgets/sidebar_widget.dart';
import '../../../core/services/ticket_service.dart';
import '../../widgets/chart_widget.dart';
import '../../widgets/filtros_widget.dart';
import '../../widgets/kpi_widget.dart';
import '../../widgets/ticket_list_widget.dart';

class DashboardPage extends StatefulWidget {
  final String token;
  final String userName;
  final int usuGen;

  const DashboardPage({
    super.key,
    required this.token,
    required this.userName,
    required this.usuGen,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _ticketService = TicketService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _estados = [];

  String _selectedRange = '7 días';
  int? _selectedEstadoId;
  final TextEditingController _rucCtrl = TextEditingController();

  int _kpiAbiertos = 0;
  int _kpiProceso = 0;
  int _kpiCerrados = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadEstados();
    await _loadTickets();
  }

  Future<void> _loadEstados() async {
    try {
      final res = await _ticketService.getEstadosCrm(token: widget.token);
      setState(() => _estados = res);
    } catch (_) {
      debugPrint('Error cargando estados');
    }
  }

  ({DateTime? ini, DateTime? fin}) _rangeDates() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'Hoy':
        return (
        ini: DateTime(now.year, now.month, now.day),
        fin: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case '7 días':
        return (ini: now.subtract(const Duration(days: 7)), fin: now);
      case '30 días':
        return (ini: now.subtract(const Duration(days: 30)), fin: now);
      case 'Todo':
      default:
        return (ini: null, fin: null);
    }
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dates = _rangeDates();
      final ruc = _rucCtrl.text.trim();
      final res = await _ticketService.getTicketsPorUsuario(
        token: widget.token,
        usuGen: widget.usuGen,
        idEstado: _selectedEstadoId,
        fechaInicio: dates.ini,
        fechaFin: dates.fin,
        ruc: ruc.isEmpty ? null : ruc,
      );

      int abiertos = 0, proceso = 0, cerrados = 0;
      for (final t in res) {
        final est = (t['estado'] ?? '').toString().toLowerCase();
        if (est.contains('nuevo') || est.contains('abierto'))
          abiertos++;
        else if (est.contains('proceso'))
          proceso++;
        else if (est.contains('cerrado'))
          cerrados++;
      }

      setState(() {
        _tickets = res;
        _kpiAbiertos = abiertos;
        _kpiProceso = proceso;
        _kpiCerrados = cerrados;
      });
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar los tickets: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _rucCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final theme = Theme.of(context);

    return Scaffold(
      drawer: isMobile
          ? Drawer(
        child: SidebarWidget(
          token: widget.token,
          userName: widget.userName,
          usuGen: widget.usuGen,
        ),
      )
          : null,
      appBar: isMobile
          ? AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF199ED6), Color(0xFF0784D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "KLAX CRM",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadTickets,
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            tooltip: "Actualizar",
          ),
        ],
      )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF199ED6),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/formulario',
            arguments: {
              'token': widget.token,
              'userName': widget.userName,
              'usuGen': widget.usuGen,
            },
          );
        },
        label: const Text(
          "Nueva Prospección",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(
              width: 240,
              child: SidebarWidget(
                token: widget.token,
                userName: widget.userName,
                usuGen: widget.usuGen,
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTickets,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xF20795EA), Color(0xFF199ED6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "KLAX CRM",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _loadTickets,
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              tooltip: "Actualizar",
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    //  Filtros
                    FiltrosWidget(
                      isMobile: isMobile,
                      estados: _estados,
                      selectedRange: _selectedRange,
                      onRangeChanged: (v) {
                        setState(() => _selectedRange = v);
                        _loadTickets();
                      },
                      selectedEstadoId: _selectedEstadoId,
                      onEstadoChanged: (v) {
                        setState(() => _selectedEstadoId = v);
                        _loadTickets();
                      },
                      rucController: _rucCtrl,
                      onBuscar: _loadTickets,
                    ),

                    const SizedBox(height: 20),

                    //  KPIs
                    KpiWidget(
                      abiertos: _kpiAbiertos,
                      enProceso: _kpiProceso,
                      cerrados: _kpiCerrados,
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 24),

                    //  Chart en tarjeta
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Resumen por estado",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 16),
                            ChartWidget(
                              abiertos: _kpiAbiertos,
                              enProceso: _kpiProceso,
                              cerrados: _kpiCerrados,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    //  Lista de tickets en tarjeta
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Últimos tickets",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            else if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            else
                              TicketListWidget(
                                tickets: _tickets,
                                token: widget.token,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
