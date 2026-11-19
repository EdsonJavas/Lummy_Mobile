import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/utils/network_errors.dart';

/// Dados de identidade e progresso da criança logada, lidos de `children`.
///
/// Compartilhado por: cabeçalho e nível da Home, avatar de todas as abas e
/// menu lateral. Provido na raiz do app (`lib/main.dart`).
///
/// - `MainNavigation` chama [loadForCurrentUser] ao abrir a área da criança.
/// - Quem muda XP/nível (ex.: voltar da tela de Missões) chama [refresh].
/// - O "Sair da conta" chama [reset].
///
/// Não guarda saldo: o saldo continua sendo lido por cada tela (a Home tem
/// realtime e notificação de dinheiro novo; ver `home_page.dart`).
class ChildProfileController extends ChangeNotifier {
  /// XP necessário para subir de nível (regra de `complete_daily_mission`:
  /// nível = floor(total_points / 1000) + 1).
  static const int xpPorNivel = 1000;

  String _nome = '';
  int _level = 1;
  int _totalPoints = 0;
  bool _carregado = false;
  bool _nivelConhecido = false;
  String? _childId;

  /// Número da carga mais recente. Uma resposta de carga mais antiga (ou de
  /// outra criança) chega atrasada e é descartada.
  int _pedido = 0;

  /// Nome para exibir. Vazio até a primeira carga terminar.
  String get nome => _nome;

  /// Primeiro nome (para "Oi, Ana!"). Vazio até carregar.
  String get primeiroNome {
    final partes = _nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty ? '' : partes.first;
  }

  /// Inicial em maiúscula para o avatar. "?" se o nome ainda não chegou.
  String get inicial {
    final n = _nome.trim();
    if (n.isEmpty) return '?';
    return n.characters.first.toUpperCase();
  }

  /// Nível (`children.level`).
  int get level => _level;

  /// XP total (`children.total_points`).
  int get totalPoints => _totalPoints;

  /// XP dentro do nível atual (0..999), para "320 de 1000 XP".
  int get xpNoNivel => _totalPoints % xpPorNivel;

  /// Fração da barra de nível (0..1).
  double get progressoNivel => xpNoNivel / xpPorNivel;

  /// true depois da primeira carga (com ou sem sucesso).
  bool get carregado => _carregado;

  /// true quando nível e XP vieram do banco para esta criança. Falso = a
  /// leitura falhou: quem mostra nível/XP esconde o elemento (D7).
  bool get nivelConhecido => _nivelConhecido;

  /// Atalho para `context.watch<ChildProfileController>()`.
  static ChildProfileController of(BuildContext context) =>
      context.watch<ChildProfileController>();

  /// Carrega os dados da criança logada.
  Future<void> loadForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      reset();
      return;
    }
    if (_childId != user.id) {
      // Troca de conta: não mostra o nome da criança anterior.
      _childId = user.id;
      _nome = '';
      _level = 1;
      _totalPoints = 0;
      _carregado = false;
      _nivelConhecido = false;
      notifyListeners();
    }
    await refresh();
  }

  /// Relê nome, nível e XP do banco.
  Future<void> refresh() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final pedido = ++_pedido;
    _childId ??= user.id;

    String? nome;
    int? level;
    int? totalPoints;
    try {
      final row = await supabase
          .from('children')
          .select('nome, level, total_points')
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) {
        nome = (row['nome'] as String?)?.trim();
        level = (row['level'] as num?)?.toInt() ?? 1;
        totalPoints = (row['total_points'] as num?)?.toInt() ?? 0;
      }
    } catch (e, st) {
      debugLogDataLoad('Perfil da criança (children)', e, st);
    }

    // Mesmos recursos de nome que a Home já usava (home_page.dart, _loadUserName).
    if (nome == null || nome.isEmpty) {
      final meta = user.userMetadata ?? const {};
      nome = (meta['name'] ?? meta['full_name'] ?? meta['username']) as String?;
    }
    if (nome == null || nome.trim().isEmpty) {
      nome = user.email?.split('@').first;
    }
    if (nome == null || nome.trim().isEmpty) {
      try {
        nome = (await SharedPreferences.getInstance()).getString('user_name');
      } catch (_) {}
    }

    // Outra carga começou depois desta, ou a conta trocou: descarta tudo,
    // inclusive nível e XP (não podem vazar de uma criança para outra).
    if (pedido != _pedido || _childId != user.id) return;
    if (level != null) {
      _level = level;
      _totalPoints = totalPoints ?? 0;
      _nivelConhecido = true;
    }
    _nome = (nome?.trim().isNotEmpty ?? false) ? nome!.trim() : 'Usuário';
    _carregado = true;
    notifyListeners();
  }

  /// Limpa tudo (ao sair da conta).
  void reset() {
    _childId = null;
    _nome = '';
    _level = 1;
    _totalPoints = 0;
    _carregado = false;
    _nivelConhecido = false;
    notifyListeners();
  }
}
