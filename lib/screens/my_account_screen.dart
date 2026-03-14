import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../utils/notifications.dart';
import '../services/user_service.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;
  UserProfile? _original;
  late UserProfile _profile;

  bool get _isAdmin => _profile.type != null && _profile.type!.toLowerCase() == 'admin';

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final svc = UserService();
      final profile = await svc.fetchUserProfile();
      _original = profile.copy();
      _profile = profile;
      _populateControllers(_profile);
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao buscar perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar dados: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _populateControllers(UserProfile p) {
    _nameController.text = p.name ?? '';
    _cpfController.text = p.cpf ?? '';
    _emailController.text = p.email ?? '';
    _phoneController.text = p.phone ?? '';
    _birthController.text = p.birthDate ?? '';
    _streetController.text = p.street ?? '';
    _neighborhoodController.text = p.neighborhood ?? '';
    _cityController.text = p.city ?? '';
    _zipController.text = p.zip ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
    });

    final updated = _profile.copyWith(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      birthDate: _birthController.text.trim(),
      street: _streetController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      zip: _zipController.text.trim(),
    );

    try {
      final svc = UserService();
      final result = await svc.updateUserProfile(updated);
      setState(() {
        _profile = result;
        _original = result.copy();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados salvos com sucesso')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar dados: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _cancelEdits() {
    if (_original != null) {
      _profile = _original!.copy();
      _populateControllers(_profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edições canceladas')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _streetController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;

      setState(() {
        _uploadingAvatar = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final storage = Supabase.instance.client.storage;
      const bucket = 'avatars';
      final bytes = await File(picked.path).readAsBytes();
      final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}_${Uri.file(picked.path).pathSegments.last}';
      final destPath = 'avatars/${user.id}/$filename';

      try {
        await storage.from(bucket).upload(destPath, File(picked.path));
      } catch (e) {
        // fallback for different client versions
        await storage.from(bucket).uploadBinary(destPath, bytes);
      }

      final publicUrl = storage.from(bucket).getPublicUrl(destPath).toString();

      final svc = UserService();
      final updated = _profile.copyWith(avatarUrl: publicUrl);
      await svc.updateUserProfile(updated);

      if (!mounted) return;
      setState(() {
        _profile = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil atualizada'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar foto: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Conta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Cabeçalho com foto de perfil
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A8A),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                  ClipOval(
                                    child: _profile.avatarUrl != null && _profile.avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            _profile.avatarUrl!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', width: 120, height: 120, fit: BoxFit.cover),
                                          )
                                        : Image.asset(
                                            'assets/images/logo.png',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: -10,
                                    child: GestureDetector(
                                      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF047857),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: _uploadingAvatar
                                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                            : const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _nameController.text.isEmpty ? 'Usuário' : _nameController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cpfController.text.isEmpty ? 'CPF: -' : 'CPF: ${_cpfController.text}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    // Seções de informações
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Informações Pessoais'),
                          _buildInfoCard([
                            _buildEditableItem(Icons.person_outline, 'Nome', _nameController, 'Informe o nome', enabled: _isAdmin),
                            _buildEditableItem(Icons.credit_card, 'CPF', _cpfController, 'Informe o CPF', enabled: _isAdmin),
                            _buildEditableItem(Icons.email_outlined, 'Email', _emailController, 'Informe o email', inputType: TextInputType.emailAddress, enabled: _isAdmin),
                            _buildEditableItem(Icons.phone_outlined, 'Telefone', _phoneController, 'Informe o telefone', inputType: TextInputType.phone, enabled: _isAdmin),
                            _buildEditableItem(Icons.calendar_today_outlined, 'Data de Nascimento', _birthController, 'DD/MM/AAAA', enabled: _isAdmin),
                          ]),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Endereço'),
                          _buildInfoCard([
                            _buildEditableItem(Icons.location_on_outlined, 'Rua', _streetController, 'Rua, número', enabled: _isAdmin),
                            _buildEditableItem(Icons.business_outlined, 'Bairro', _neighborhoodController, 'Bairro', enabled: _isAdmin),
                            _buildEditableItem(Icons.location_city_outlined, 'Cidade', _cityController, 'Cidade - UF', enabled: _isAdmin),
                            _buildEditableItem(Icons.pin_outlined, 'CEP', _zipController, 'CEP', enabled: _isAdmin),
                          ]),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Segurança'),
                          _buildActionCard([
                            _buildActionButton(
                              Icons.lock_outline,
                              'Alterar Senha',
                              'Atualize sua senha periodicamente',
                              () => _showMessage(context, 'Alterar Senha'),
                            ),
                            _buildActionButton(
                              Icons.security_outlined,
                              'Autenticação em 2 Fatores',
                              'Adicione uma camada extra de segurança',
                              () => _showMessage(context, 'Autenticação em 2 Fatores'),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Preferências'),
                          _buildActionCard([
                            _buildActionButton(
                              Icons.notifications_outlined,
                              'Notificações',
                              'Gerencie suas notificações',
                              () => showNotificationsDialog(context),
                            ),
                            _buildActionButton(
                              Icons.language_outlined,
                              'Idioma',
                              'Altere o idioma do aplicativo',
                              () => _showMessage(context, 'Idioma'),
                            ),
                          ]),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: (!_isAdmin || _saving) ? null : _save,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                                    child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Salvar'),
                                  ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: OutlinedButton(
                                    onPressed: (!_isAdmin || _saving) ? null : _cancelEdits,
                                    child: const Text('Cancelar'),
                                  ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildEditableItem(IconData icon, String label, TextEditingController controller, String placeholder, {TextInputType? inputType, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF047857), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: inputType,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) {
                    // validação mínima: email deve conter @, outros campos apenas não vazios
                    if (label.toLowerCase().contains('email')) {
                      if (v == null || v.isEmpty) return 'Informe o email';
                      if (!v.contains('@')) return 'Email inválido';
                    } else {
                      // para campos opcionais, não forçar validação
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildActionCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF047857).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF047857),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade em desenvolvimento: $feature'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}