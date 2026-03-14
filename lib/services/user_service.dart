import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? street;
  final String? neighborhood;
  final String? city;
  final String? zip;
  final String? avatarUrl;
  // novo: tipo/credencial do perfil (ex: 'admin', 'user', etc.)
  final String? type;

  UserProfile({
    this.name,
    this.cpf,
    this.email,
    this.phone,
    this.birthDate,
    this.street,
    this.neighborhood,
    this.city,
    this.zip,
    this.avatarUrl,
    this.type,
  });

  UserProfile copy() => UserProfile(
        name: name,
        cpf: cpf,
        email: email,
        phone: phone,
        birthDate: birthDate,
        street: street,
        neighborhood: neighborhood,
        city: city,
        zip: zip,
    avatarUrl: avatarUrl,
        type: type,
      );

  UserProfile copyWith({
    String? name,
    String? cpf,
    String? email,
    String? phone,
    String? birthDate,
    String? street,
    String? neighborhood,
    String? city,
    String? zip,
    String? avatarUrl,
    String? type,
  }) {
    return UserProfile(
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String?,
        cpf: json['cpf'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        birthDate: json['birthDate'] as String?,
        street: json['street'] as String?,
        neighborhood: json['neighborhood'] as String?,
        city: json['city'] as String?,
    zip: json['zip'] as String?,
    avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
    type: json['type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'cpf': cpf,
        'email': email,
        'phone': phone,
        'birthDate': birthDate,
        'street': street,
        'neighborhood': neighborhood,
        'city': city,
    'zip': zip,
    'avatar_url': avatarUrl,
    'type': type,
      };

  /// Retorna apenas o primeiro e segundo nome (ex: "João Silva")
  String get shortName {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'Usuário';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0];
    // Lista de conectivos/preposições que não devem ser considerados como segundo nome
    final stopWords = <String>{
      'da', 'de', 'do', 'das', 'dos', 'e', 'du', 'del', 'della', 'di', 'van', 'von', 'la', 'le', 'el', 'al'
    };

    // Encontrar o primeiro token após o primeiro que não seja um conectivo
    String? second;
    for (var i = 1; i < parts.length; i++) {
      final token = parts[i].replaceAll(RegExp(r"[^\p{L}\p{N}'-]", unicode: true), '');
      if (token.isEmpty) continue;
      if (stopWords.contains(token.toLowerCase())) continue;
      second = token;
      break;
    }

    if (second == null) return parts[0];
    return '${parts[0]} $second';
  }
}

class UserService {
  // Busca o perfil do usuário autenticado na tabela 'profiles'
  Future<UserProfile> fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res == null) {
        throw Exception('Perfil não encontrado');
      }

      // Mapeia campos comuns. Alguns projetos usam 'full_name' em vez de 'name'.
      final name = res['full_name'] ?? res['name'] ?? res['display_name'] ?? res['fullName'];
      final cpf = res['cpf'] ?? res['document'] ?? res['cpf_number'];
      final email = res['email'] ?? user.email;
      final phone = res['phone'] ?? res['telephone'];
      final birthDate = res['birth_date'] ?? res['birthDate'] ?? res['birthdate'];
      final street = res['street'] ?? res['address'] ?? res['address_street'];
      final neighborhood = res['neighborhood'] ?? res['district'];
      final city = res['city'] ?? res['town'];
      final zip = res['zip'] ?? res['postal_code'] ?? res['cep'];
      final type = res['type'] ?? res['role'];

      return UserProfile(
        name: name as String?,
        cpf: cpf as String?,
        email: email as String?,
        phone: phone as String?,
        birthDate: birthDate as String?,
        street: street as String?,
        neighborhood: neighborhood as String?,
        city: city as String?,
        zip: zip as String?,
        avatarUrl: (res['avatar_url'] ?? res['photo_url']) as String?,
        type: type as String?,
      );
    } catch (e) {
      // Repassa a exceção para a camada de UI
      throw Exception('Falha ao buscar perfil: $e');
    }
  }

  // Atualiza o perfil do usuário na tabela 'profiles'
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      final payload = {
        'full_name': profile.name,
        'name': profile.name,
        'cpf': profile.cpf,
        'email': profile.email,
        'phone': profile.phone,
        'birth_date': profile.birthDate,
        'street': profile.street,
        'neighborhood': profile.neighborhood,
        'city': profile.city,
        'zip': profile.zip,
        'avatar_url': profile.avatarUrl,
        'type': profile.type,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('profiles')
          .update(payload)
          .eq('user_id', user.id);

      // Retorna o perfil atualizado consultando novamente
      return await fetchUserProfile();
    } catch (e) {
      throw Exception('Falha ao atualizar perfil: $e');
    }
  }
}
