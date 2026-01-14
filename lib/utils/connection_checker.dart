import 'dart:io';
import 'package:flutter/foundation.dart';

/// Utilitário para verificar conectividade básica
class ConnectionChecker {
  /// Verifica se há conectividade básica tentando resolver o DNS
  static Future<bool> checkSupabaseConnection() async {
    try {
      debugPrint('🔍 Verificando conectividade com Supabase...');
      
      // Tentar resolver o DNS do Supabase
      final result = await InternetAddress.lookup('rcskqcorfmmeignsgcuj.supabase.co');
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('✅ DNS resolvido com sucesso: ${result[0].address}');
        return true;
      } else {
        debugPrint('❌ DNS não pôde ser resolvido');
        return false;
      }
    } on SocketException catch (e) {
      debugPrint('❌ Erro de socket ao verificar DNS: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Erro ao verificar conectividade: $e');
      return false;
    }
  }
  
  /// Verifica conectividade geral com Google DNS
  static Future<bool> checkGeneralConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Sem conectividade geral: $e');
      return false;
    }
  }
}
