import 'package:flutter/foundation.dart';

/// Tipos de dado da área da criança que uma tela pode mudar e outra mostrar.
enum ChildDataKind {
  /// `children.balance` (cofrinho).
  saldo,

  /// `transactions` de gasto.
  gastos,

  /// `goals` (meta atual, criada, excluída, concluída).
  meta,

  /// `daily_missions` (e, por consequência, XP e nível).
  missoes,

  /// `achievements`.
  conquistas,
}

/// Aviso entre telas da criança: "este dado mudou, recarregue".
///
/// Por que existe: as 4 abas vivem num `IndexedStack` e não são recriadas. Um
/// gasto anotado pela Home precisa aparecer em Gastos; uma meta criada em
/// Metas precisa aparecer no cofrinho da Home. O realtime do Supabase só está
/// publicado para `children` (R5), então não dá para depender dele.
///
/// Regra: **quem grava avisa; quem mostra escuta.**
/// ```dart
/// // Depois de gravar:
/// context.read<ChildDataChanges>().avisar({ChildDataKind.saldo, ChildDataKind.gastos});
///
/// // Numa tela que mostra gastos (initState / dispose):
/// _changes = context.read<ChildDataChanges>()..addListener(_aoMudar);
/// _versaoGastos = _changes.versao(ChildDataKind.gastos);
/// void _aoMudar() {
///   final v = _changes.versao(ChildDataKind.gastos);
///   if (v != _versaoGastos) { _versaoGastos = v; _recarregarSemSkeleton(); }
/// }
/// ```
/// Provido na raiz do app (`lib/main.dart`).
class ChildDataChanges extends ChangeNotifier {
  final Map<ChildDataKind, int> _versoes = {};

  /// Versão atual de [tipo]. Muda a cada [avisar] que o inclua.
  int versao(ChildDataKind tipo) => _versoes[tipo] ?? 0;

  /// Avisa que os [tipos] mudaram no banco.
  void avisar(Set<ChildDataKind> tipos) {
    if (tipos.isEmpty) return;
    for (final t in tipos) {
      _versoes[t] = versao(t) + 1;
    }
    notifyListeners();
  }
}
