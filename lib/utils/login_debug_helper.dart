import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utilitário para diagnosticar problemas de login
class LoginDebugHelper {
  static Future<Map<String, dynamic>> diagnoseLoginIssue(String userId) async {
    final results = <String, dynamic>{};
    final supabase = Supabase.instance.client;

    try {
      // 1. Verificar autenticação
      final currentUser = supabase.auth.currentUser;
      results['auth_current_user'] = currentUser != null;
      results['auth_user_id'] = currentUser?.id;
      results['auth_user_email'] = currentUser?.email;
      results['auth_user_id_matches'] = currentUser?.id == userId;

      debugPrint('📊 Diagnóstico de Login:');
      debugPrint('   Usuário autenticado: ${currentUser != null}');
      debugPrint('   ID autenticado: ${currentUser?.id}');
      debugPrint('   ID buscado: $userId');

      // 2. Verificar tabela responsaveis
      try {
        final parentCheck = await supabase
            .from('responsaveis')
            .select('id, nome, email')
            .eq('id', userId)
            .maybeSingle();
        
        results['parent_exists'] = parentCheck != null;
        results['parent_data'] = parentCheck;
        
        debugPrint('   Responsável encontrado: ${parentCheck != null}');
        if (parentCheck != null) {
          debugPrint('   Nome: ${parentCheck['nome']}');
          debugPrint('   Email: ${parentCheck['email']}');
        }
      } catch (e) {
        results['parent_check_error'] = e.toString();
        debugPrint('   ❌ Erro ao verificar responsável: $e');
      }

      // 3. Verificar tabela children
      try {
        final childCheck = await supabase
            .from('children')
            .select('id, nome, email, responsavel_id')
            .eq('id', userId)
            .maybeSingle();
        
        results['child_exists'] = childCheck != null;
        results['child_data'] = childCheck;
        
        debugPrint('   Criança encontrada: ${childCheck != null}');
        if (childCheck != null) {
          debugPrint('   Nome: ${childCheck['nome']}');
          debugPrint('   Email: ${childCheck['email']}');
          debugPrint('   Responsável ID: ${childCheck['responsavel_id']}');
        }
      } catch (e) {
        results['child_check_error'] = e.toString();
        debugPrint('   ❌ Erro ao verificar criança: $e');
      }

      // 4. Verificar RLS (Row Level Security)
      results['rls_issue'] = 
          (results['parent_exists'] == false && results['child_exists'] == false) &&
          results['parent_check_error'] == null &&
          results['child_check_error'] == null;

      if (results['rls_issue'] == true) {
        debugPrint('   ⚠️ Possível problema de RLS: usuário autenticado mas sem acesso às tabelas');
      }

      // 5. Resumo
      final hasProfile = (results['parent_exists'] == true) || 
                        (results['child_exists'] == true);
      results['has_profile'] = hasProfile;
      results['diagnosis'] = _getDiagnosis(results);

      debugPrint('   📋 Diagnóstico: ${results['diagnosis']}');

    } catch (e, stackTrace) {
      results['diagnosis_error'] = e.toString();
      results['diagnosis_stack'] = stackTrace.toString();
      debugPrint('   ❌ Erro no diagnóstico: $e');
    }

    return results;
  }

  static String _getDiagnosis(Map<String, dynamic> results) {
    if (results['auth_current_user'] != true) {
      return 'Usuário não está autenticado no Supabase';
    }

    if (results['auth_user_id_matches'] != true) {
      return 'ID do usuário autenticado não corresponde ao ID buscado';
    }

    if (results['parent_exists'] == true) {
      return 'Perfil encontrado: Responsável';
    }

    if (results['child_exists'] == true) {
      return 'Perfil encontrado: Criança';
    }

    if (results['rls_issue'] == true) {
      return 'Problema de RLS: Usuário autenticado mas sem acesso às tabelas. Verifique as políticas de segurança no Supabase.';
    }

    if (results['parent_check_error'] != null || results['child_check_error'] != null) {
      return 'Erro ao verificar tabelas. Pode ser problema de conexão ou permissões.';
    }

    return 'Perfil não encontrado. O usuário precisa completar o cadastro nas tabelas responsaveis ou children.';
  }
}
