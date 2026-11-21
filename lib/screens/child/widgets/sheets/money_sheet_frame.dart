import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Abre um painel de baixo de dinheiro e devolve `true` se ele gravou.
///
/// - Véu `rgba(11,21,51,0.45)` por cima da tela real (D5); o `#858A99` do
///   mockup só representa esse véu.
/// - Ocupa a tela inteira (`isScrollControlled`), sem área segura: o painel
///   começa a 88 do topo da tela e cobre a cápsula do menu de baixo.
/// - Tem `ScaffoldMessenger` próprio: os avisos do `LummyFeedback` aparecem
///   POR CIMA do painel (os da tela de baixo ficariam escondidos atrás dele).
///
/// [builder] deve devolver um [MoneySheetFrame].
Future<bool> showMoneySheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) async {
  final gravou = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: context.cores.veu,
    elevation: 0,
    showDragHandle: false,
    enableDrag: true,
    builder: (_) => ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Builder(builder: builder),
      ),
    ),
  );
  return gravou ?? false;
}

/// Moldura comum dos painéis de dinheiro (`Anotar-gasto.dc.html`,
/// `<section aria-label="Anotar gasto">`).
///
/// Painel branco de `top: 88` até o fim da tela, raio `28 28 0 0`, padding
/// `10 20 24` (mais o inset de baixo do sistema). Em ordem: alça 40×4,
/// cabeçalho (título + fechar), [corpo] e [rodape] empurrado para o fim
/// (`margin-top: auto`).
///
/// Se a altura não couber o conteúdo (celular baixo), a coluna rola; quando
/// cabe, o [rodape] fica colado no fim.
class MoneySheetFrame extends StatelessWidget {
  const MoneySheetFrame({
    super.key,
    required this.titulo,
    required this.corpo,
    required this.rodape,
    this.bloqueado = false,
  });

  /// "Anotar gasto" / "Registrar dinheiro que ganhei".
  final String titulo;

  /// Tudo entre o cabeçalho e o botão. Cada item cuida do próprio espaço de
  /// cima (as margens do mockup).
  final List<Widget> corpo;

  /// O botão de salvar.
  final Widget rodape;

  /// true durante a gravação: o painel não fecha por voltar, por toque fora,
  /// pelo "Fechar" nem por arrasto.
  final bool bloqueado;

  static const _topo = 88.0;
  static const _raio = BorderRadius.vertical(top: Radius.circular(28));

  void _fechar(BuildContext context) {
    // maybePop respeita o PopScope (não fecha durante a gravação).
    Navigator.maybePop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final insetDeBaixo = MediaQuery.viewPaddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(20, 10, 20, 24 + insetDeBaixo);

    return PopScope(
      canPop: !bloqueado,
      child: Column(
        children: [
          // Faixa do véu acima do painel: tocar fecha, como no resto do véu.
          ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _fechar(context),
              child: const SizedBox(height: _topo, width: double.infinity),
            ),
          ),
          Expanded(
            child: GestureDetector(
              // Durante a gravação, este detector ganha o arrasto vertical do
              // painel (o de dentro vence o do BottomSheet) e não faz nada.
              onVerticalDragStart: bloqueado ? (_) {} : null,
              onVerticalDragUpdate: bloqueado ? (_) {} : null,
              onVerticalDragEnd: bloqueado ? (_) {} : null,
              child: Material(
                color: context.cores.superficie,
                borderRadius: _raio,
                clipBehavior: Clip.antiAlias,
                child: Semantics(
                  container: true,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final alturaMinima =
                          (constraints.maxHeight - padding.vertical).clamp(0.0, double.infinity);
                      return SingleChildScrollView(
                        padding: padding,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: alturaMinima),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _Alca(),
                                const SizedBox(height: 6),
                                _Cabecalho(
                                  titulo: titulo,
                                  onFechar: bloqueado ? null : () => _fechar(context),
                                ),
                                ...corpo,
                                // `margin-top: auto` do botão. O mínimo evita
                                // que ele encoste no teclado quando a coluna rola.
                                const Expanded(child: SizedBox(height: 12)),
                                rodape,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alça: 40×4, raio 2, `#D5D9E2`, centralizada.
class _Alca extends StatelessWidget {
  const _Alca();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.cores.alca,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Título (Poppins 600 18, literal: não é Fredoka) e o botão "Fechar" 44×44
/// com `margin-right: -10px`.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.titulo, required this.onFechar});

  final String titulo;
  final VoidCallback? onFechar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Semantics(
                  header: true,
                  child: Text(titulo, maxLines: 1, softWrap: false, style: LummyText.h2(context)),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(10, 0),
            child: Semantics(
              button: true,
              enabled: onFechar != null,
              label: 'Fechar',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onFechar,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: LummyIcon(
                      LummyGlyphs.x,
                      size: 22,
                      color: context.cores.tintaApoio,
                      strokeWidth: 2.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
