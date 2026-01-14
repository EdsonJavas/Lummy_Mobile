import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Utilitário para testar a conexão com Supabase e verificar se as tabelas existem
class SupabaseTest {
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    try {
      final supabase = Supabase.instance.client;

      // Teste 1: Verificar se Supabase está inicializado
      results['supabase_initialized'] = true;
      debugPrint('✅ Supabase está inicializado');

      // Teste 2: Verificar se há usuário autenticado
      final user = supabase.auth.currentUser;
      results['user_authenticated'] = user != null;
      results['user_id'] = user?.id;
      debugPrint(
        '${user != null ? "✅" : "⚠️"} Usuário autenticado: ${user?.id ?? "Nenhum"}',
      );

      // Teste 3: Verificar se a tabela responsaveis existe e pode ser acessada
      try {
        final responsaveis = await supabase
            .from('responsaveis')
            .select('id, nome, email')
            .limit(1);
        results['responsaveis_table'] = true;
        results['responsaveis_count'] = responsaveis.length;
        debugPrint('✅ Tabela responsaveis acessível');
      } catch (e) {
        results['responsaveis_table'] = false;
        results['responsaveis_error'] = e.toString();
        debugPrint('❌ Erro ao acessar tabela responsaveis: $e');
      }

      // Teste 4: Verificar se a tabela children existe e pode ser acessada
      try {
        final children = await supabase
            .from('children')
            .select('id, nome, email')
            .limit(1);
        results['children_table'] = true;
        results['children_count'] = children.length;
        debugPrint('✅ Tabela children acessível');
      } catch (e) {
        results['children_table'] = false;
        results['children_error'] = e.toString();
        debugPrint('❌ Erro ao acessar tabela children: $e');
      }

      // Teste 5: Verificar políticas RLS
      if (user != null) {
        try {
          // Tentar buscar dados do próprio usuário
          final ownData = await supabase
              .from('responsaveis')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          results['rls_responsaveis'] = true;
          debugPrint('✅ RLS permite acesso a responsaveis');
        } catch (e) {
          results['rls_responsaveis'] = false;
          results['rls_responsaveis_error'] = e.toString();
          debugPrint('❌ RLS pode estar bloqueando acesso a responsaveis: $e');
        }

        try {
          final ownChildren = await supabase
              .from('children')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          results['rls_children'] = true;
          debugPrint('✅ RLS permite acesso a children');
        } catch (e) {
          results['rls_children'] = false;
          results['rls_children_error'] = e.toString();
          debugPrint('❌ RLS pode estar bloqueando acesso a children: $e');
        }
      }

      return results;
    } catch (e, stackTrace) {
      results['error'] = e.toString();
      results['stack_trace'] = stackTrace.toString();
      debugPrint('❌ Erro geral no teste: $e');
      return results;
    }
  }

  /// Testa se consegue inserir um registro de teste (apenas para debugging)
  static Future<Map<String, dynamic>> testInsert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final results = <String, dynamic>{};

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        results['error'] = 'Usuário não autenticado';
        return results;
      }

      debugPrint('🔄 Tentando inserir em $table: $data');

      final response = await supabase
          .from(table)
          .insert(data)
          .select()
          .single();

      results['success'] = true;
      results['response'] = response;
      debugPrint('✅ Inserção bem-sucedida em $table');

      return results;
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();

      if (e is PostgrestException) {
        results['code'] = e.code;
        results['message'] = e.message;
        results['details'] = e.details;
        results['hint'] = e.hint;
      }

      debugPrint('❌ Erro ao inserir em $table: $e');
      return results;
    }
  }

  /// Verifica se um usuário específico existe na tabela children
  static Future<Map<String, dynamic>?> checkChildExists(String userId) async {
    try {
      final supabase = Supabase.instance.client;

      final child = await supabase
          .from('children')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (child != null) {
        debugPrint('✅ Criança encontrada: ${child['nome']}');
        return child;
      } else {
        debugPrint('⚠️ Criança não encontrada na tabela children');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar criança: $e');
      return null;
    }
  }

  /// Verifica se um usuário específico existe na tabela responsaveis
  static Future<Map<String, dynamic>?> checkResponsavelExists(
    String userId,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      final responsavel = await supabase
          .from('responsaveis')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (responsavel != null) {
        debugPrint('✅ Responsável encontrado: ${responsavel['nome']}');
        return responsavel;
      } else {
        debugPrint('⚠️ Responsável não encontrado na tabela responsaveis');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar responsável: $e');
      return null;
    }
  }
}
