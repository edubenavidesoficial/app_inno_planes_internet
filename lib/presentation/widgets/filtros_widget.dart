import 'package:flutter/material.dart';

class FiltrosWidget extends StatelessWidget {
  final bool isMobile;
  final List<Map<String, dynamic>> estados;
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;
  final int? selectedEstadoId;
  final ValueChanged<int?> onEstadoChanged;
  final TextEditingController rucController;
  final VoidCallback onBuscar;

  const FiltrosWidget({
    super.key,
    required this.isMobile,
    required this.estados,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.selectedEstadoId,
    required this.onEstadoChanged,
    required this.rucController,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    final itemsEstados = <DropdownMenuItem<int?>>[
      const DropdownMenuItem<int?>(value: null, child: Text('Todos')),
      ...estados.map((e) {
        final id = e['id'] ?? e['idCrmEstado'] ?? e['idEstado'];
        final nombre = (e['nombre'] ?? e['estado'] ?? 'Estado').toString();
        return DropdownMenuItem<int?>(value: id as int, child: Text(nombre));
      }),
    ];

    final ranges = ['Hoy', '7 días', '30 días', 'Todo'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedRange,
                        items: ranges
                            .map(
                              (r) => DropdownMenuItem(value: r, child: Text(r)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) onRangeChanged(val);
                        },
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int?>(
                        value: selectedEstadoId,
                        items: itemsEstados,
                        onChanged: onEstadoChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _rucField(),
                ],
              )
            : Row(
                children: [
                  DropdownButton<String>(
                    value: selectedRange,
                    items: ranges
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) onRangeChanged(val);
                    },
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int?>(
                    value: selectedEstadoId,
                    items: itemsEstados,
                    onChanged: onEstadoChanged,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _rucField()),
                ],
              ),
      ],
    );
  }

  Widget _rucField() {
    return TextField(
      controller: rucController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Buscar por RUC o nombre',
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: onBuscar,
        ),
      ),
      onSubmitted: (_) => onBuscar(),
    );
  }
}
