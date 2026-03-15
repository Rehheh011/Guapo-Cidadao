# Flutter Teste Aplicação

Uma aplicação Flutter de exemplo com organização de telas, serviços e utilitários.

## 🧭 Visão geral

Este projeto é um app Flutter simples para demonstrar:
- Estrutura de pastas para `screens`, `services` e `utils`
- Navegação entre telas
- Uso de plugins (GPS, câmera, armazenamento local, etc.)
- Boas práticas de organização e limpeza de código


## 🚀 Como executar

1. Instale o Flutter: https://docs.flutter.dev/get-started/install
2. Abra o terminal na pasta do projeto:
   ```bash
   cd "c:\\Users\\Renato\\Desktop\\VSCODE\\Teste Flutter\\flutter_teste_aplicacao"
   ```
3. Atualize dependências:
   ```bash
   flutter pub get
   ```
4. Rode no emulador/dispositivo:
   ```bash
   flutter run
   ```

> Dica: em Windows, use `flutter devices` para ver o dispositivo conectado.


## 📁 Estrutura principal

- `lib/main.dart` → Ponto de entrada do app
- `lib/screens/` → Telas do aplicativo
- `lib/services/` → Serviços (API, autenticação, armazenamento)
- `lib/utils/` → Funções e helpers reutilizáveis
- `assets/` → Imagens e recursos estáticos


## 🧩 Configuração comum

Se usar plugins nativos (por exemplo `geolocator`, `image_picker`, `shared_preferences`), verifique:
- `android/app/src/main/AndroidManifest.xml` (permissões)
- `ios/Runner/Info.plist` (permissões)


## ✅ Comandos úteis

- `flutter analyze` → Analisa problemas de lint/sintaxe
- `flutter test` → Executa testes unitários/widget
- `flutter pub outdated` → Verifica pacotes desatualizados


## 📌 Próximos passos

- Adicionar autenticação (Firebase Auth ou API própria)
- Implementar um serviço de API/HTTP em `lib/services/`
- Criar testes unitários em `test/`
- Publicar no Google Play / App Store


## ✨ Contato

Se quiser, posso te ajudar a adicionar uma tela de login e persistência de usuário.

