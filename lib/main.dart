import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/theme_service.dart';
import 'package:flutter_teste_aplicacao/screens/status_screen.dart';
import 'screens/my_account_screen.dart';
import 'services/user_service.dart';
import 'screens/user_registration_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/schedule_appointment_screen.dart';
import 'screens/report_stray_animal_screen.dart';
import 'screens/register_occurrence_screen.dart';
import 'screens/news_screen.dart';
import 'utils/notifications.dart';
import 'screens/report_gcm_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://afumetzimncnuqpjkwij.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFmdW1ldHppbW5jbnVxcGprd2lqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNTk5ODMsImV4cCI6MjA3NjczNTk4M30.TRh3uzByrrR1Bph_1KUyV0Jn8dYM_8yIVZvFqe6nrco',
  );
  
  // Inicializa o serviço de tema (carrega preferência salva)
  await ThemeService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta alterações no ThemeService.themeMode para aplicar tema dinamicamente
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Guapó Cidadão',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[100],
            // Force consistent button colors across the app
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF047857), // Texto dos TextButtons
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047857), // Fundo dos ElevatedButtons
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF047857), // Texto dos OutlinedButtons
                side: const BorderSide(color: Color(0xFF047857)),
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[900],
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.tealAccent),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ),
          themeMode: themeMode,
          home: const LoginPage(),
        );
      },
    );
  }

}

// Função demonstrativa que abre um chat de suporte (apenas UI, não funcional)
void showSupportChatDemo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text('Chat de Suporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Card(
                          color: const Color(0xFFF1F1F1),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('Olá! Em que podemos ajudar hoje?'),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Card(
                          color: const Color(0xFF047857),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Tenho uma dúvida sobre um pedido', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Card(
                          color: const Color(0xFFF1F1F1),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('Certo, podemos fornecer informações. Lembre-se que isto é apenas uma demonstração.'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Escreva sua mensagem (demo)',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // ação demonstrativa: apenas fecha ou mostra uma mensagem
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mensagem enviada (demo)'), duration: Duration(seconds: 2)),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857)),
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// Serviço de gerenciamento de inatividade
class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  Timer? _inactivityTimer;
  final Duration _inactivityDuration = const Duration(minutes: 5);
  VoidCallback? _onInactivityDetected;

  void initialize(VoidCallback onInactivityDetected) {
    _onInactivityDetected = onInactivityDetected;
    resetTimer();
  }

  void resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, () {
      _onInactivityDetected?.call();
    });
  }

  void dispose() {
    _inactivityTimer?.cancel();
    _onInactivityDetected = null;
  }
}

// Widget wrapper que detecta interação do usuário
class InactivityDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onInactive;

  const InactivityDetector({
    super.key,
    required this.child,
    required this.onInactive,
  });

  @override
  State<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  final InactivityService _inactivityService = InactivityService();

  @override
  void initState() {
    super.initState();
    _inactivityService.initialize(widget.onInactive);
  }

  @override
  void dispose() {
    _inactivityService.dispose();
    super.dispose();
  }

  void _handleUserInteraction() {
    _inactivityService.resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleUserInteraction,
      onPanDown: (_) => _handleUserInteraction(),
      onScaleStart: (_) => _handleUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: Listener(
        onPointerDown: (_) => _handleUserInteraction(),
        onPointerMove: (_) => _handleUserInteraction(),
        onPointerUp: (_) => _handleUserInteraction(),
        child: widget.child,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        try {
          // Buscar dados do perfil do usuário
      await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', response.user!.id)
        .single();

          if (!mounted) return;

          // Se chegou aqui, o perfil existe, ir para a página inicial
          navigator.pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } catch (e) {
          // Se não encontrou o perfil, redirecionar para a tela de registro
          if (!mounted) return;
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Por favor, complete seu cadastro'),
              backgroundColor: Colors.orange,
            ),
          );

          navigator.push(
            MaterialPageRoute(builder: (context) => const UserRegistrationScreen()),
          );
          return;
        }
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF047857),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'GUAPÓ CIDADÃO',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bem-vindo de volta',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'seu@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF047857),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: '********',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF047857),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              if (_emailController.text.isEmpty) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor, insira seu email'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              try {
                                await Supabase.instance.client.auth.resetPasswordForEmail(
                                  _emailController.text,
                                );

                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Email de recuperação enviado! Verifique sua caixa de entrada.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (error) {
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao enviar email de recuperação: ${error.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(color: Color(0xFF047857)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047857),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserRegistrationScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF047857)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Criar Conta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Versão 1.26.10 - Demo',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  List<Occurrence> _filteredOccurrences = [];
  // Lista em memória de ocorrências
  final List<Occurrence> _occurrences = [
    Occurrence(
      id: '1',
      title: 'Poste com lâmpada queimada',
      description: 'Problema em poste na Av. Cristalina, Poste com a lâmpada Queimada.',
      dateTime: DateTime(2025, 5, 20),
      status: OccurrenceStatus.inProgress,
      photos: const [],
    ),
    Occurrence(
      id: '2',
      title: 'Animal na via',
      description: 'Problema Com animal na Rua Roberto Carlos, Manada de elefantes na pista.',
      dateTime: DateTime(2025, 5, 20),
      status: OccurrenceStatus.completed,
      photos: const [],
    ),
    Occurrence(
      id: '3',
      title: 'Buraco na rua',
      description: 'Buraco grande na Rua das Flores, próximo ao número 123.',
      dateTime: DateTime(2025, 5, 21),
      status: OccurrenceStatus.inAnalysis,
      photos: const [],
    ),
    Occurrence(
      id: '4',
      title: 'Falta de água',
      description: 'Rua inteira sem água há 2 dias no Setor Central.',
      dateTime: DateTime(2025, 5, 22),
      status: OccurrenceStatus.pending,
      photos: const [],
    ),
    Occurrence(
      id: '5',
      title: 'Descarte irregular de lixo',
      description: 'Lixo sendo descartado irregularmente na Praça Principal.',
      dateTime: DateTime(2025, 5, 19),
      status: OccurrenceStatus.cancelled,
      photos: const [],
    ),
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      // Abre o menu lateral
      _scaffoldKey.currentState?.openDrawer();
      return;
    }

    // Ao selecionar o item 2, abrimos a tela de registrar ocorrência
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterOccurrenceScreen(),
        ),
      );
      return;
    }

    // Ao selecionar o item 3, abrimos a tela de notícias
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NewsScreen(),
        ),
      );
      return;
    }

    if(index == 4){
      // Instead of pushing a new route, switch the selected tab to Status
      setState(() {
        _selectedIndex = 4;
      });
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }



    Widget _buildStatusScreen() {
      return StatusScreen(
        occurrences: _occurrences,
        searchController: _searchController,
      );
    }  Future<void> _handleLogout() async {
    InactivityService().dispose();
    
    try {
      await Supabase.instance.client.auth.signOut();
      
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _filteredOccurrences = List.from(_occurrences);
    _searchController.addListener(_filterOccurrences);
    _loadUserProfile();
  }

  UserProfile? _userProfile;

  Future<void> _loadUserProfile() async {
    try {
      final svc = UserService();
      final p = await svc.fetchUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = p;
      });
    } catch (e) {
      // Não bloquear a UI se não houver perfil
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOccurrences() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOccurrences = List.from(_occurrences);
      } else {
        _filteredOccurrences = _occurrences.where((occurrence) =>
          occurrence.title.toLowerCase().contains(query) ||
          occurrence.description.toLowerCase().contains(query)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InactivityDetector(
      onInactive: _handleLogout,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF047857),
                  Color(0xFF059669),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header do Menu
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Olá, 👋',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _userProfile?.shortName ?? 'Usuário',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 1),
                  // Itens do Menu
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        MenuItemTile(
                          icon: Icons.person_outline,
                          title: 'Minha Conta',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyAccountScreen()),
                            );
                          },
                        ),
                        MenuItemTile(
                          icon: Icons.event_note_outlined,
                          title: 'Marcar Consulta',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScheduleAppointmentScreen(),
                              ),
                            );
                          },
                        ),
                        MenuItemTile(
                          icon: Icons.home_outlined,
                          title: 'Impressão do IPTU',
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Impressão do IPTU, EM DESENVOLVIMENTO.')),
                            );
                          },
                        ),
                        MenuItemTile(
                          icon: Icons.pets_outlined,
                          title: 'Denunciar animais soltos',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportStrayAnimalScreen(),
                              ),
                            );
                          },
                        ),

                        MenuItemTile(
                          icon: Icons.security_outlined,
                          title: 'Denunciar na GCM',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ReportGcmScreen()),
                            );
                          },
                        ),
                        MenuItemTile(
                          icon: Icons.settings_outlined,
                          title: 'Configurações',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                        MenuItemTile(
                          icon: Icons.logout_outlined,
                          title: 'Sair da conta',
                          style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                          onTap: () {
                            Navigator.pop(context);
                            _handleLogout();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Versão
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Versão 1.26.10',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Olá, ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '👋',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                              Text(
                                '${_userProfile?.shortName ?? 'Usuário'}!', //_nameController.text.isEmpty ? 'Usuário' : _nameController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 255, 255, 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                showNotificationsDialog(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          // Use theme cardColor so search field follows light/dark modes
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Procurando algo?',
                            hintStyle: TextStyle(color: Theme.of(context).hintColor),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        // follow scaffold background so the curve matches theme
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _selectedIndex == 4
                  ? _buildStatusScreen()
                  : HomeDashboard(
                      occurrences: _filteredOccurrences,
                      onOpenAll: () {
                        setState(() {
                          _selectedIndex = 4;
                        });
                      },
                      onActionSelected: (action) {
                        // ações rápidas: abrir telas correspondentes
                        if (action == 'report') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterOccurrenceScreen(),
                            ),
                          );
                        } else if (action == 'animal') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportStrayAnimalScreen(),
                            ),
                          );
                        } else if (action == 'appointment') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScheduleAppointmentScreen(),
                            ),
                          );
                        } else if (action == 'news') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NewsScreen()),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showSupportChatDemo(context),
          backgroundColor: const Color(0xFF047857),
          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF047857),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Nova Solicitação',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper),
              label: 'Notícias',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted),
              label: 'Status',

            ),
          ],
        ),
      ),
    );
  }
}

// Widget para itens do menu lateral
class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final TextStyle? style;

  const MenuItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: style ??
            const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
    );
  }
}

// Re-exportando o modelo de ocorrência da tela de status
// Widget de dashboard inicial mais dinâmico
class HomeDashboard extends StatelessWidget {
  final List<Occurrence> occurrences;
  final VoidCallback onOpenAll;
  final void Function(String action) onActionSelected;

  const HomeDashboard({
    super.key,
    required this.occurrences,
    required this.onOpenAll,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final recent = occurrences.take(3).toList();

    return Container(
      // use theme background so dark mode is respected
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Carrossel simples de destaque (placeholder)
            SizedBox(
              height: 140,
              child: PageView(
                children: [
                  _buildHighlightCard(context, Colors.orangeAccent, 'Atenção: Novo cronograma de coleta'),
                  _buildHighlightCard(context, Colors.blueAccent, 'Campanha de castração gratuita'),
                  _buildHighlightCard(context, Colors.green, 'Participe da audiência pública'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ações rápidas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton(context, Icons.add_box_outlined, 'Nova', 'report'),
                _actionButton(context, Icons.pets_outlined, 'Animal', 'animal'),
                _actionButton(context, Icons.event_note_outlined, 'Consulta', 'appointment'),
                _actionButton(context, Icons.newspaper_outlined, 'Notícias', 'news'),
              ],
            ),
            const SizedBox(height: 16),

            // Estatísticas rápidas (contagens por status)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: OccurrenceStatus.values.map((s) {
                    final count = occurrences.where((o) => o.status == s).length;
                    return Column(
                      children: [
                        Icon(s.icon, color: s.color),
                        const SizedBox(height: 8),
                        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(s.label, style: const TextStyle(fontSize: 10))
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ocorrências recentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ocorrências Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: onOpenAll, child: const Text('Ver todas')),
              ],
            ),
            const SizedBox(height: 8),

            ...recent.map((occ) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(occ.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(occ.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(occ.status.icon, color: occ.status.color),
                    const SizedBox(height: 4),
                    Text(occ.status.label, style: TextStyle(color: occ.status.color, fontSize: 12)),
                  ],
                ),
                onTap: () {
                  // abrir detalhes simples
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(occ.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      content: Text(occ.description),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
                      ],
                    ),
                  );
                },
              ),
            )),

            const SizedBox(height: 24),

            // Dica / chat
            Card(
              // let card follow theme surface color
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).iconTheme.color?.withAlpha((0.7 * 255).round()),
                ),
                title: Text('Precisa de ajuda?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                subtitle: Text('Abra o chat de suporte ou veja as opções no menu.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                trailing: ElevatedButton(
                  onPressed: () => showSupportChatDemo(context),
                  child: const Text('Chat'),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, Color color, String text) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, String action) {
    return GestureDetector(
      onTap: () => onActionSelected(action),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8)],
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}