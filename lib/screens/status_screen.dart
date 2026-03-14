import 'package:flutter/material.dart';
import 'dart:io';

class StatusScreen extends StatefulWidget {
  final List<Occurrence> occurrences;
  final TextEditingController searchController;

  const StatusScreen({
    Key? key,
    required this.occurrences,
    required this.searchController,
  }) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<Occurrence> _filteredOccurrences = [];

  @override
  void initState() {
    super.initState();
    _filteredOccurrences = List.from(widget.occurrences);
    widget.searchController.addListener(_filterOccurrences);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterOccurrences);
    super.dispose();
  }

  void _filterOccurrences() {
    final query = widget.searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOccurrences = List.from(widget.occurrences);
      } else {
        _filteredOccurrences = widget.occurrences.where((occurrence) =>
          occurrence.title.toLowerCase().contains(query) ||
          occurrence.description.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    // Agrupar ocorrências por status
    final groupedOccurrences = <OccurrenceStatus, List<Occurrence>>{};
    for (var status in OccurrenceStatus.values) {
      groupedOccurrences[status] = _filteredOccurrences.where((occ) => occ.status == status).toList();
    }

    return Container(
      // Use theme's scaffoldBackgroundColor so dark mode shows proper background
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, statusIndex) {
                  final status = OccurrenceStatus.values[statusIndex];
                  final occurrences = groupedOccurrences[status] ?? [];

                  if (occurrences.isEmpty) {
                    return null;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(status.icon, color: status.color),
                            const SizedBox(width: 8),
                            Text(
                              status.label,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                occurrences.length.toString(),
                                style: TextStyle(
                                  color: status.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...occurrences.map((occ) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: status.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: status.color,
                            ),
                          ),
                          title: Text(
                            occ.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                occ.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (occ.photos.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 80,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: occ.photos.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      final p = occ.photos[idx];
                                      if (p.toLowerCase().startsWith('http')) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(p, width: 120, height: 80, fit: BoxFit.cover),
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(File(p), width: 120, height: 80, fit: BoxFit.cover),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(occ.dateTime),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(status.icon, color: status.color),
                                      const SizedBox(width: 8),
                                      const Text('Detalhes da Ocorrência', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          occ.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Descrição:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                          Text(occ.description),
                                          const SizedBox(height: 12),
                                          if (occ.photos.isNotEmpty)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Fotos:', style: TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 8),
                                                SizedBox(
                                                  height: 220,
                                                  child: ListView.separated(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: occ.photos.length,
                                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                                    itemBuilder: (context, i) {
                                                      final p = occ.photos[i];
                                                      if (p.toLowerCase().startsWith('http')) {
                                                        return ClipRRect(
                                                          borderRadius: BorderRadius.circular(12),
                                                          child: Image.network(p, width: 320, height: 220, fit: BoxFit.cover),
                                                        );
                                                      }
                                                      return ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Image.file(File(p), width: 320, height: 220, fit: BoxFit.cover),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Registrado em: ${_formatDate(occ.dateTime)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: status.color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(status.icon, color: status.color, size: 16),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Status: ${status.label}',
                                                style: TextStyle(
                                                  color: status.color,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Fechar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      )).toList(),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                childCount: OccurrenceStatus.values.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum OccurrenceStatus {
  pending(
    label: 'Pendente',
    color: Color(0xFFFFA726),
    icon: Icons.hourglass_empty,
  ),
  inAnalysis(
    label: 'Em Análise',
    color: Color(0xFF2196F3),
    icon: Icons.search,
  ),
  inProgress(
    label: 'Em Andamento',
    color: Color(0xFF9C27B0),
    icon: Icons.engineering,
  ),
  completed(
    label: 'Concluída',
    color: Color(0xFF4CAF50),
    icon: Icons.check_circle,
  ),
  cancelled(
    label: 'Cancelada',
    color: Color(0xFFF44336),
    icon: Icons.cancel,
  );

  final String label;
  final Color color;
  final IconData icon;

  const OccurrenceStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class Occurrence {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final OccurrenceStatus status;

  Occurrence({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.status = OccurrenceStatus.pending,
    this.photos = const [],
  });

  final List<String> photos;
}