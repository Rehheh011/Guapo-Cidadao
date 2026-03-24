import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'map_picker_screen.dart';
import 'dart:io';

class ReportGcmScreen extends StatefulWidget {
  const ReportGcmScreen({super.key});

  @override
  State<ReportGcmScreen> createState() => _ReportGcmScreenState();
}

class _ReportGcmScreenState extends State<ReportGcmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  String _priority = 'medium';
  bool _isAnonymous = false;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    // Se usuário não estiver logado e não for anônimo, exigir login
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null && !_isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login ou envie de forma anônima.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final double? lat = _latController.text.isNotEmpty ? double.tryParse(_latController.text) : null;
      final double? lon = _lonController.text.isNotEmpty ? double.tryParse(_lonController.text) : null;

      final Map<String, dynamic> insertData = {
        'user_id': user?.id,
        'title': title,
        'description': description,
        'priority': _priority,
        'latitude': lat,
        'longitude': lon,
        'photos': <String>[],
        'is_anonymous': _isAnonymous,
        "incident_type": "Infraestrutura",
      };

      // Se há imagens selecionadas, e usuário autenticado, faça upload para o bucket
      if (_selectedImages.isNotEmpty) {
        if (user == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Para enviar fotos é necessário estar logado.')),
          );
          setState(() => _loading = false);
          return;
        }

        List<String> photosUrls = [];
        try {
          final storage = Supabase.instance.client.storage;
          const bucket = 'occurrence-photos';
          for (var img in _selectedImages) {
            final bytes = await File(img.path).readAsBytes();
            final filename = '${DateTime.now().millisecondsSinceEpoch}_${Uri.file(img.path).pathSegments.last}';
            final destPath = 'occurrences/${user.id}/$filename';
            try {
              await storage.from(bucket).upload(destPath, File(img.path));
            } catch (e) {
              try {
                await storage.from(bucket).uploadBinary(destPath, bytes);
              } catch (e2) {
                rethrow;
              }
            }
            try {
              final publicRes = storage.from(bucket).getPublicUrl(destPath);
              final publicUrl = publicRes.toString();
              photosUrls.add(publicUrl.isNotEmpty ? publicUrl : destPath);
            } catch (e) {
              photosUrls.add(destPath);
            }
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no upload das imagens: ${e.toString()}')),
          );
          // fallback: não bloquear, mantemos photos como lista vazia
        }

        if (photosUrls.isNotEmpty) {
          insertData['photos'] = photosUrls;
        }
      }

      final response = await Supabase.instance.client
          .from('reports')
          .insert([insertData])
          .select('id')
          .maybeSingle();

      // response pode ser Map com id
      final reportId = response != null && response['id'] != null ? response['id'] as String : null;

      if (reportId != null) {
        // Inserir histórico inicial
        await Supabase.instance.client.from('report_history').insert([
          {
            'report_id': reportId,
            'changed_by': user?.id,
            'old_status': null,
            'new_status': 'pending',
            'comment': 'Denúncia criada via app',
          }
        ]);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia enviada com sucesso.')),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Falha ao criar denúncia');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar denúncia: ${error.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _loading = true);
      final pos = await LocationService.getCurrentPosition();
      _latController.text = pos.latitude.toStringAsFixed(6);
      _lonController.text = pos.longitude.toStringAsFixed(6);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao obter localização: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  LatLng? _parseCurrentLatLng() {
    try {
      final lat = double.tryParse(_latController.text.trim());
      final lon = double.tryParse(_lonController.text.trim());
      if (lat != null && lon != null) {
        return LatLng(lat, lon);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _selectLocationOnMap() async {
    try {
      final current = _parseCurrentLatLng();
      final selected = await Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (_) => MapPickerScreen(
            initialLatitude: current?.latitude,
            initialLongitude: current?.longitude,
          ),
        ),
      );
      if (selected != null && mounted) {
        setState(() {
          _latController.text = selected.latitude.toStringAsFixed(6);
          _lonController.text = selected.longitude.toStringAsFixed(6);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao selecionar no mapa: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denunciar à GCM', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white) ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um título' : null,
              ),
              const SizedBox(height: 12),
              // Fotos (opcional)
              const Text('Fotos (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading
                        ? null
                        : () async {
                            final List<XFile>? images = await _picker.pickMultiImage(imageQuality: 80);
                            if (images != null && images.isNotEmpty) {
                              setState(() {
                                _selectedImages = images;
                              });
                            }
                          },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Adicionar fotos'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                  ),
                  const SizedBox(width: 12),
                  Text('${_selectedImages.length} selecionada(s)'),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final img = _selectedImages[i];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              width: 120,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(i);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe uma descrição' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar localização atual'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _selectLocationOnMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Selecionar no mapa'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Baixa')),
                  DropdownMenuItem(value: 'medium', child: Text('Média')),
                  DropdownMenuItem(value: 'high', child: Text('Alta')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 'medium'),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Prioridade'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enviar de forma anônima'),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                  child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Enviar denúncia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
