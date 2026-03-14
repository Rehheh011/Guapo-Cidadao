import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'terms_of_use_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estados para os switches
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;
  bool _biometricAuth = true;
  bool _locationServices = true;
  bool _autoUpdate = true;
  bool _dataSync = true;

  @override
  void initState() {
    super.initState();
    // inicializa estado do switch a partir do ThemeService
    _darkMode = ThemeService.themeMode.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Container(
              width: double.infinity,
              color: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.all(16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personalize seu aplicativo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajuste as configurações de acordo com suas preferências',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Notificações'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Notificações Push',
                          'Receba alertas instantâneos',
                          Icons.notifications_outlined,
                          _pushNotifications,
                          (value) => setState(() => _pushNotifications = value),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          'Notificações por Email',
                          'Receba atualizações por email',
                          Icons.email_outlined,
                          _emailNotifications,
                          (value) => setState(() => _emailNotifications = value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Aparência'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Modo Escuro',
                          'Altere o tema do aplicativo',
                          Icons.dark_mode_outlined,
                          _darkMode,
                          (value) async {
                            setState(() => _darkMode = value);
                            // Atualiza o ThemeService e persiste a preferência
                            await ThemeService.setDarkMode(value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Segurança'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Autenticação Biométrica',
                          'Use sua digital para login',
                          Icons.fingerprint,
                          _biometricAuth,
                          (value) => setState(() => _biometricAuth = value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Dados e Permissões'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          'Serviços de Localização',
                          'Permitir acesso à localização',
                          Icons.location_on_outlined,
                          _locationServices,
                          (value) => setState(() => _locationServices = value),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          'Atualizações Automáticas',
                          'Manter o app sempre atualizado',
                          Icons.system_update_outlined,
                          _autoUpdate,
                          (value) => setState(() => _autoUpdate = value),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          'Sincronização de Dados',
                          'Sincronizar dados em segundo plano',
                          Icons.sync_outlined,
                          _dataSync,
                          (value) => setState(() => _dataSync = value),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Mais Opções'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildActionTile(
                          'Limpar Cache',
                          'Liberar espaço no dispositivo',
                          Icons.cleaning_services_outlined,
                          () => _showFeatureMessage(context, 'Limpar Cache'),
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          'Backup de Dados',
                          'Fazer backup das suas informações',
                          Icons.backup_outlined,
                          () => _showFeatureMessage(context, 'Backup de Dados'),
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          'Sobre o Aplicativo',
                          'Informações da versão e licenças',
                          Icons.info_outline,
                          () => _showAboutDialog(context),
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          'Termos de Uso',
                          'Leia nossos termos e condições',
                          Icons.description_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsOfUseScreen(),
                            ),
                          ),
                        ),
                        _buildDivider(),
                        _buildActionTile(
                          'Política de Privacidade',
                          'Saiba como protegemos seus dados',
                          Icons.privacy_tip_outlined,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF047857).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF047857),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF047857).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  void _showFeatureMessage(BuildContext context, String feature) {
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF047857)),
              SizedBox(width: 8),
              Text('Sobre o Aplicativo'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guapó Cidadão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Versão: 1.26.10'),
              SizedBox(height: 16),
              Text(
                '© 2025 Avant & Prefeitura de Guapó\nTodos os direitos reservados',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Color(0xFF047857)),
              ),
            ),
          ],
        );
      },
    );
  }
}