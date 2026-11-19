import 'package:flutter/widgets.dart';

/// Índices das 4 abas da criança (ordem da cápsula do menu de baixo).
abstract final class ChildTabs {
  static const inicio = 0;
  static const gastos = 1;
  static const metas = 2;
  static const aprender = 3;
}

/// Ações da "casca" da área da criança (`MainNavigation`) para as abas e o
/// menu lateral: abrir o menu, trocar de aba e rodar algo depois de fechar o
/// menu.
///
/// As abas têm `Scaffold` próprio, então `Scaffold.of(context).openDrawer()`
/// pegaria o Scaffold errado. Use sempre esta classe:
/// ```dart
/// ChildShellScope.read(context)?.openDrawer();          // num onTap
/// ChildShellScope.read(context)?.goToTab(ChildTabs.aprender);
/// final aba = ChildShellScope.of(context).currentTab;     // num build
/// ```
/// Provido por `MainNavigation` acima do `Scaffold` (o menu lateral também vê).
class ChildShellScope extends InheritedWidget {
  const ChildShellScope({
    super.key,
    required this.currentTab,
    required this.openDrawer,
    required this.closeDrawer,
    required this.goToTab,
    required this.afterDrawerClosed,
    required super.child,
  });

  /// Aba aberta (ver [ChildTabs]).
  final int currentTab;

  /// Abre o menu lateral.
  final VoidCallback openDrawer;

  /// Fecha o menu lateral, se estiver aberto.
  final VoidCallback closeDrawer;

  /// Troca de aba (fecha o menu lateral se estiver aberto).
  final ValueChanged<int> goToTab;

  /// Fecha o menu lateral e chama `acao` com um `BuildContext` da casca que
  /// continua montado (o do menu some quando ele fecha). Use para empurrar
  /// telas ou abrir painéis a partir de um item do menu:
  /// ```dart
  /// ChildShellScope.read(context)?.afterDrawerClosed((ctx) {
  ///   Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const RequestMoneyScreen()));
  /// });
  /// ```
  final void Function(void Function(BuildContext shellContext) acao)
      afterDrawerClosed;

  /// Para usar dentro de `build` (reconstrói quando a aba muda).
  static ChildShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChildShellScope>();
    assert(scope != null, 'ChildShellScope não encontrado: use dentro de MainNavigation.');
    return scope!;
  }

  /// Para usar em callbacks (`onTap`). Nulo fora de `MainNavigation`.
  static ChildShellScope? read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ChildShellScope>();

  @override
  bool updateShouldNotify(ChildShellScope oldWidget) =>
      currentTab != oldWidget.currentTab;
}
