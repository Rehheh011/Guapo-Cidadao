import 'package:flutter/material.dart';

/// Mostra um diálogo simples com a lista de notificações.
/// Se nenhuma lista for fornecida, mostra notificações de exemplo.
Future<void> showNotificationsDialog(BuildContext context, {List<String>? notifications}) {
  final items = notifications ?? [
    'Nenhuma notificação nova',
    'Atualização do status da sua solicitação #1234',
    'Lembrete: Reunião agendada para amanhã às 10:00',
  ];

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Notificações'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: items.isEmpty
            ? const Center(child: Text('Sem notificações'))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final text = items[index];
                  return ListTile(
                    leading: const Icon(Icons.notifications, color: Colors.blue),
                    title: Text(text),
                    onTap: () {
                      // Exemplo: fechar o diálogo ao tocar numa notificação.
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Abrindo: $text')),
                      );
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );
}
