import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/location_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterOccurrenceScreen extends StatefulWidget {
  const RegisterOccurrenceScreen({super.key});

  @override
  State<RegisterOccurrenceScreen> createState() => _RegisterOccurrenceScreenState();
}

class _RegisterOccurrenceScreenState extends State<RegisterOccurrenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      final pos = await LocationService.getCurrentPosition();
      // Preenche o campo localização com lat,lon (pode ser alterado para geocoding se desejar)
      _locationController.text = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao obter localização: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _registerOccurrence() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não está logado');

      // Tenta extrair lat/lon se o campo localização estiver no formato "lat, lon"
      double? lat;
      double? lon;
      try {
        final parts = _locationController.text.split(',');
        if (parts.length >= 2) {
          lat = double.tryParse(parts[0].trim());
          lon = double.tryParse(parts[1].trim());
        }
      } catch (_) {}

      // Se houver imagens selecionadas, faça upload para Supabase Storage e obtenha URLs públicas
      List<String> photosUrls = [];
      if (_selectedImages.isNotEmpty) {
        try {
          final storage = Supabase.instance.client.storage;
          const bucket = 'occurrence-photos';
          for (var img in _selectedImages) {
            final bytes = await File(img.path).readAsBytes();
            final filename = '${DateTime.now().millisecondsSinceEpoch}_${Uri.file(img.path).pathSegments.last}';
            final destPath = 'occurrences/${user.id}/$filename';

            // Tentativa de upload. Se a API aceitar File diretamente, use upload; caso contrário, use uploadBinary.
            try {
              await storage.from(bucket).upload(destPath, File(img.path));
            } catch (e) {
              // fallback para upload binary (algumas versões da lib usam uploadBinary)
              try {
                await storage.from(bucket).uploadBinary(destPath, bytes);
              } catch (e2) {
                // rethrow original para tratamento externo
                rethrow;
              }
            }

            // Obter URL pública (a API pode variar por versão; usamos toString como fallback)
            try {
              final publicRes = storage.from(bucket).getPublicUrl(destPath);
              final publicUrl = publicRes.toString();
              photosUrls.add(publicUrl.isNotEmpty ? publicUrl : destPath);
            } catch (e) {
              // se falhar, adiciona o destPath para não bloquear totalmente
              photosUrls.add(destPath);
            }
          }
        } catch (error) {
          // Se upload falhar, informar e continuar com paths locais como fallback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no upload das imagens: ${error.toString()}')),
          );
          photosUrls = _selectedImages.map((e) => e.path).toList();
        }
      }

      final Map<String, dynamic> insertData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'status': 'pending',
        'user_id': user.id,
        'photos': photosUrls,
      };
      if (lat != null && lon != null) {
        insertData['latitude'] = lat;
        insertData['longitude'] = lon;
      }

      // ignore: unused_local_variable
      final response = await Supabase.instance.client.from('occurrences').insert(insertData).select().single();

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorrência registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar ocorrência: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Ocorrência'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título da Ocorrência',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Fotos (opcional)
              const Text('Fotos (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // Permite selecionar múltiplas imagens
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Localização',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a localização';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('GPS'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerOccurrence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Registrar Ocorrência',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}