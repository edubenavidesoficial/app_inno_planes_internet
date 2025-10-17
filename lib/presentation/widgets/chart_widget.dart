import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  final int abiertos;
  final int enProceso;
  final int cerrados;

  const ChartWidget({
    super.key,
    required this.abiertos,
    required this.enProceso,
    required this.cerrados,
  });

  @override
  Widget build(BuildContext context) {
    final total = (abiertos + enProceso + cerrados).toDouble();
    final sections = <PieChartSectionData>[
      if (abiertos > 0)
        PieChartSectionData(
          value: abiertos.toDouble(),
          color: Colors.orange,
          title: 'Abiertos',
          radius: 42,
          titleStyle: const TextStyle(fontSize: 12),
        ),
      if (enProceso > 0)
        PieChartSectionData(
          value: enProceso.toDouble(),
          color: Colors.blue,
          title: 'Proceso',
          radius: 42,
          titleStyle: const TextStyle(fontSize: 12),
        ),
      if (cerrados > 0)
        PieChartSectionData(
          value: cerrados.toDouble(),
          color: Colors.green,
          title: 'Cerrados',
          radius: 42,
          titleStyle: const TextStyle(fontSize: 12),
        ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: SizedBox(
        height: 200,
        child: Center(
          child: total == 0
              ? const Text('Sin datos')
              : PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
