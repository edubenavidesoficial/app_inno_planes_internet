import 'package:flutter/material.dart';

class KpiWidget extends StatelessWidget {
  final int abiertos;
  final int enProceso;
  final int cerrados;
  final bool isMobile;

  const KpiWidget({
    super.key,
    required this.abiertos,
    required this.enProceso,
    required this.cerrados,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _kpiCard('Abiertos', abiertos, Colors.orange),
      _kpiCard('En Proceso', enProceso, Colors.blue),
      _kpiCard('Cerrados', cerrados, Colors.green),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: card,
              ),
            )
            .toList(),
      );
    }

    return Row(
      children: cards
          .map(
            (card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: card,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _kpiCard(String title, int value, Color color) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              radius: 18,
              child: Text(
                '$value',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
