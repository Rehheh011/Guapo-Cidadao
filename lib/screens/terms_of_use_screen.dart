import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Termos de Uso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Aceitação dos Termos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ao acessar e usar este aplicativo, você aceita e concorda em cumprir estes termos e condições de uso.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Uso do Aplicativo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'O aplicativo deve ser usado apenas para fins legais e de acordo com estes termos. Você concorda em não usar o aplicativo:',
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                '• De maneira ilegal ou fraudulenta\n'
                '• Para fins não autorizados\n'
                '• Para violar quaisquer regulamentos ou leis aplicáveis',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '3. Modificações dos Termos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Reservamos o direito de modificar estes termos a qualquer momento. As modificações entram em vigor imediatamente após sua publicação no aplicativo.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Responsabilidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'O usuário é responsável por todas as atividades realizadas em sua conta e deve manter suas credenciais de acesso seguras.',
            ),
          ],
        ),
      ),
    );
  }
}