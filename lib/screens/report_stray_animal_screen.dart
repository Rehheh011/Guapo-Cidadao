import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/location_service.dart';

class ReportStrayAnimalScreen extends StatefulWidget {
  const ReportStrayAnimalScreen({super.key});

  @override
  State<ReportStrayAnimalScreen> createState() => _ReportStrayAnimalScreenState();
}

class _ReportStrayAnimalScreenState extends State<ReportStrayAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _animalType;
  File? _imageFile;
  bool _isLoading = false;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      final pos = await LocationService.getCurrentPosition();
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não está logado');

      String? photoUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        
        await Supabase.instance.client.storage
            .from('stray-animals')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
              ),
            );

        photoUrl = Supabase.instance.client.storage
            .from('stray-animals')
            .getPublicUrl(fileName);
      }

      final Map<String, dynamic> insertData = {
        'description': _descriptionController.text,
        'location': _locationController.text,
        'animal_type': _animalType,
        'photo_url': photoUrl,
        'status': 'pending',
        'user_id': user.id,
      };

      // tenta extrair lat/lon do campo location (format: "lat, lon")
      try {
        final parts = _locationController.text.split(',');
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lon = double.tryParse(parts[1].trim());
          if (lat != null && lon != null) {
            insertData['latitude'] = lat;
            insertData['longitude'] = lon;
          }
        }
      } catch (_) {}

      await Supabase.instance.client.from('stray_animals').insert(insertData);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Denúncia enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar denúncia: ${error.toString()}'),
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
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denunciar Animais Soltos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _animalType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Animal',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'cachorro', child: Text('Cachorro')),
                  DropdownMenuItem(value: 'gato', child: Text('Gato')),
                  DropdownMenuItem(value: 'cavalo', child: Text('Cavalo')),
                  DropdownMenuItem(value: 'outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _animalType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(),
                  hintText: 'Digite o endereço onde o animal foi visto',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a localização';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container()),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _useCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar localização atual'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  hintText: 'Descreva o animal e a situação',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, forneça uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: Text(_imageFile != null ? 'Alterar Foto' : 'Adicionar Foto'),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Enviar Denúncia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}