import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Utility class to ensure a child record exists in the children table
class EnsureChildRecord {
  /// Ensures the current user has a record in the children table.
  /// If the record doesn't exist, it attempts to create it using user metadata.
  /// Returns true if the record exists or was successfully created, false otherwise.
  static Future<bool> ensureChildExists() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('❌ Usuário não autenticado');
        return false;
      }

      // Verificar se o registro já existe
      final existingRecord = await supabase
          .from('children')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingRecord != null) {
        debugPrint('✅ Registro do usuário já existe na tabela children');
        return true;
      }

      debugPrint(
        '⚠️ Registro não encontrado na tabela children. Tentando criar...',
      );

      // Tentar obter dados dos metadados do usuário
      final metadata = user.userMetadata ?? {};
      final parentId = metadata['parent_id'] as String?;

      if (parentId == null || parentId.isEmpty) {
        debugPrint('❌ parent_id não encontrado nos metadados do usuário');
        return false;
      }

      // Verificar se o responsável existe
      final parentExists = await supabase
          .from('responsaveis')
          .select('id')
          .eq('id', parentId)
          .maybeSingle();

      if (parentExists == null) {
        debugPrint('❌ Responsável não encontrado na tabela responsaveis');
        return false;
      }

      // Criar registro na tabela children com dados dos metadados
      final nome =
          metadata['name'] as String? ??
          user.userMetadata?['full_name'] as String? ??
          user.email?.split('@').first ??
          'Usuário';

      final cpfFromMeta = metadata['cpf'] as String?;
      // Gerar CPF temporário único baseado no ID do usuário se não fornecido
      // Converte letras do UUID em dígitos (a->0, b->1, c->2, etc) e pega 11 caracteres
      String generateTempCpf(String userId) {
        final cleanId = userId.replaceAll('-', '');
        final digits = cleanId.split('').map((char) {
          if (RegExp(r'[0-9]').hasMatch(char)) return char;
          // Converter letra para dígito (a=0, b=1, c=2, etc)
          final code = char.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);
          return (code % 10).toString();
        }).join();
        return digits.substring(0, 11);
      }

      final cpf = cpfFromMeta?.isNotEmpty == true
          ? cpfFromMeta!
          : generateTempCpf(user.id);

      final idade = metadata['idade'] as int? ?? 10;
      final sexo = metadata['sexo'] as String? ?? 'Masculino';

      // Validar sexo
      final validSexo =
          (sexo == 'Masculino' || sexo == 'Feminino' || sexo == 'Outro')
          ? sexo
          : 'Masculino';

      await supabase.from('children').insert({
        'id': user.id,
        'responsavel_id': parentId,
        'nome': nome,
        'cpf': cpf,
        'email': user.email ?? '',
        'idade': idade.clamp(1, 17),
        'sexo': validSexo,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Registro criado com sucesso na tabela children');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao garantir registro na tabela children: $e');
      if (e is PostgrestException) {
        debugPrint('   Código: ${e.code}');
        debugPrint('   Mensagem: ${e.message}');
        debugPrint('   Detalhes: ${e.details}');
      }
      return false;
    }
  }
}
