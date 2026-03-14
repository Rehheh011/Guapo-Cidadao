import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<Map<String, dynamic>> _newsItems = []; // Will store our news items
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'all'; // all, occurrence, animal_report

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    try {
      // Buscar as últimas 15 ocorrências
      final occurrencesResponse = await Supabase.instance.client
          .from('occurrences')
          .select()
          .order('created_at', ascending: false)
          .limit(15);

      // Buscar as últimas 15 denúncias de animais
      final animalReportsResponse = await Supabase.instance.client
          .from('stray_animals')
          .select()
          .order('created_at', ascending: false)
          .limit(15);

      final List<Map<String, dynamic>> allNews = [];

      // Converter ocorrências para o formato de notícias
      for (final occurrence in occurrencesResponse) {
        allNews.add({
          'type': 'occurrence',
          'title': occurrence['title'] ?? 'Ocorrência',
          'description': occurrence['description'],
          'date': DateTime.parse(occurrence['created_at']),
          'status': occurrence['status'],
        });
      }

      // Converter denúncias de animais para o formato de notícias
      for (final report in animalReportsResponse) {
        allNews.add({
          'type': 'animal_report',
          'title': 'Denúncia de Animal',
          'description': report['description'],
          'date': DateTime.parse(report['created_at']),
          'status': report['status'],
        });
      }

      // Ordenar todas as notícias por data
      allNews.sort((a, b) => b['date'].compareTo(a['date']));

      // Pegar apenas as 15 mais recentes
      final latestNews = allNews.take(15).toList();

      setState(() {
        _newsItems.clear();
        _newsItems.addAll(latestNews);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar notícias: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimas Notícias'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar notícias',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: _filter == 'all',
                        onSelected: (_) => setState(() => _filter = 'all'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Ocorrências'),
                        selected: _filter == 'occurrence',
                        onSelected: (_) => setState(() => _filter = 'occurrence'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Animais'),
                        selected: _filter == 'animal_report',
                        onSelected: (_) => setState(() => _filter = 'animal_report'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadNews,
                      ),
                    ],
                  ),
                ),

                // News list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadNews,
                    child: _filteredNews.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.newspaper,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma notícia encontrada',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filteredNews.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final item = _filteredNews[index];
                              final status = (item['status'] ?? 'Pendente').toString();
                              final statusColor = _statusColor(status);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    // could navigate to detail
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Image / Icon
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Texts
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item['title'] ?? '',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _formatDate(item['date']),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item['description'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Chip(
                                                    label: Text(status),
                                                    backgroundColor: statusColor.withAlpha((0.15 * 255).round()),
                                                    labelStyle: TextStyle(
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: item['type'] == 'occurrence'
                                                          ? Color.fromRGBO(30, 58, 138, 0.08)
                                                          : Color.fromRGBO(4, 120, 87, 0.08),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          item['type'] == 'occurrence' ? Icons.notification_important : Icons.pets,
                                                          size: 14,
                                                          color: item['type'] == 'occurrence' ? const Color(0xFF1E3A8A) : const Color(0xFF047857),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          item['type'] == 'occurrence' ? 'Ocorrência' : 'Denúncia Animal',
                                                          style: const TextStyle(fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Map<String, dynamic>> get _filteredNews {
    return _newsItems.where((item) {
      final matchesFilter = _filter == 'all'
          ? true
          : (_filter == 'occurrence' ? item['type'] == 'occurrence' : item['type'] == 'animal_report');
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty
          ? true
          : (item['title']?.toString().toLowerCase().contains(q) ?? false) || (item['description']?.toString().toLowerCase().contains(q) ?? false);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('resol')) return Colors.green;
    if (s.contains('in_progress') || s.contains('progress')) return Colors.orange;
    if (s.contains('pend')) return Colors.red;
    return Colors.blueGrey;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year.toString()} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}