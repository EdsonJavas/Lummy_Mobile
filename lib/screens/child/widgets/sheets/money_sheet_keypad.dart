import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Teclado numérico próprio do painel (`Anotar-gasto.dc.html`, D17).
///
/// Grade de 3 colunas, `gap: 4px`, 4 linhas de 46. Teclas sem fundo, raio 14:
/// "1" a "9", ",", "0" e Apagar. Dígitos em Poppins 500 24 tinta.
///
/// Estado pressionado (não desenhado no mockup): fundo `#F2F4F7` enquanto o
/// dedo está na tecla. Segurar "Apagar" limpa tudo.
///
/// Precisa de um `Material` acima (o `MoneySheetFrame` fornece).
class MoneySheetKeypad extends StatelessWidget {
  const MoneySheetKeypad({
    super.key,
    required this.onDigito,
    required this.onVirgula,
    required this.onApagar,
    required this.onLimpar,
    this.habilitado = true,
  });

  final ValueChanged<String> onDigito;
  final VoidCallback onVirgula;
  final VoidCallback onApagar;
  final VoidCallback onLimpar;

  /// false = ignora toques (durante a gravação).
  final bool habilitado;

  static const _alturaTecla = 46.0;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !habilitado,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _linha([_digito('1'), _digito('2'), _digito('3')]),
          const SizedBox(height: _gap),
          _linha([_digito('4'), _digito('5'), _digito('6')]),
          const SizedBox(height: _gap),
          _linha([_digito('7'), _digito('8'), _digito('9')]),
          const SizedBox(height: _gap),
          _linha([
            _Tecla(
              rotuloAcessivel: 'Vírgula',
              onTap: onVirgula,
              child: const _TextoTecla(','),
            ),
            _digito('0'),
            _Tecla(
              rotuloAcessivel: 'Apagar',
              onTap: onApagar,
              onLongPress: onLimpar,
              child: const LummyIcon(
                LummyGlyphs.delete,
                size: 24,
                color: LummyColors.ink900,
                strokeWidth: 2,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _digito(String d) => _Tecla(
        rotuloAcessivel: d,
        onTap: () => onDigito(d),
        child: _TextoTecla(d),
      );

  Widget _linha(List<Widget> teclas) {
    return SizedBox(
      height: _alturaTecla,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < teclas.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            Expanded(child: teclas[i]),
          ],
        ],
      ),
    );
  }
}

class _TextoTecla extends StatelessWidget {
  const _TextoTecla(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: LummyText.poppins(size: 24, weight: FontWeight.w500),
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({
    required this.rotuloAcessivel,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final String rotuloAcessivel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  static const _raio = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    final longPress = onLongPress;
    return Semantics(
      button: true,
      label: rotuloAcessivel,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: _raio,
        highlightColor: LummyColors.surface100,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        enableFeedback: false,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        onLongPress: longPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                longPress();
              },
        child: Center(child: child),
      ),
    );
  }
}
