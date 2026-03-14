import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Política de Privacidade',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Coleta de Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coletamos informações que você nos fornece diretamente ao usar nosso aplicativo. Isso pode incluir:',
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                '• Informações de registro\n'
                '• Informações de perfil\n'
                '• Conteúdo gerado pelo usuário\n'
                '• Informações de uso do aplicativo',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '2. Uso das Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Utilizamos as informações coletadas para:',
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                '• Fornecer e manter nossos serviços\n'
                '• Melhorar a experiência do usuário\n'
                '• Enviar atualizações e notificações importantes\n'
                '• Detectar e prevenir fraudes',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '3. Compartilhamento de Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Não compartilhamos suas informações pessoais com terceiros, exceto quando:',
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                '• Exigido por lei\n'
                '• Necessário para proteger nossos direitos\n'
                '• Com seu consentimento explícito',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '4. Segurança',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Implementamos medidas de segurança apropriadas para proteger suas informações contra acesso não autorizado ou alteração.',
            ),
          ],
        ),
      ),
    );
  }
}