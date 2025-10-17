import 'package:flutter/material.dart';

class TicketListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tickets;
  final String token;

  const TicketListWidget({
    super.key,
    required this.tickets,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final last = tickets.take(12).toList();

    if (last.isEmpty) return const Text('No hay tickets recientes');

    return Column(
      children: last.map((t) {
        final estado = (t['estado'] ?? '').toString();
        final cliente = (t['nombre'] ?? '').toString();
        final ruc = (t['ruc'] ?? '').toString();
        final color = _estadoColor(estado);

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: CircleAvatar(backgroundColor: color, radius: 8),
            title: Text(
              '$ruc - $cliente',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Estado: $estado',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/prospectos',
                arguments: {
                  ...t,
                  'token': token,
                  'id_ticket': t['idCrmTicket'],
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('nuevo') || e.contains('abierto')) return Colors.orange;
    if (e.contains('proceso')) return Colors.blue;
    if (e.contains('cerrado')) return Colors.green;
    return Colors.grey;
  }
}
