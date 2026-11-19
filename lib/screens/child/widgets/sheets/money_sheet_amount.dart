import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// O que a criança digitou no teclado do painel, como texto cru.
///
/// Formato interno: só dígitos e, no máximo, uma vírgula (ex.: `"4,5"`).
/// Regras (briefing do Dev 4):
/// - até [maxInteiros] dígitos antes da vírgula (R$ 99.999,99);
/// - até [maxDecimais] dígitos depois da vírgula;
/// - uma vírgula só; vírgula primeiro vira `"0,"`;
/// - zero à esquerda é trocado pelo próximo dígito.
///
/// Imutável: cada tecla devolve uma entrada nova (ou a mesma, se a tecla não
/// puder ser aceita).
@immutable
class MoneySheetAmountInput {
  const MoneySheetAmountInput([this.cru = '']);

  static const maxInteiros = 5;
  static const maxDecimais = 2;

  final String cru;

  bool get vazio => cru.isEmpty;

  bool get _temVirgula => cru.contains(',');

  String get _inteiros => _temVirgula ? cru.substring(0, cru.indexOf(',')) : cru;

  String get _decimais => _temVirgula ? cru.substring(cru.indexOf(',') + 1) : '';

  /// Valor em reais (0 se nada foi digitado).
  double get valor {
    if (cru.isEmpty) return 0;
    final inteiros = int.tryParse(_inteiros) ?? 0;
    final centavos = int.tryParse(_decimais.padRight(maxDecimais, '0')) ?? 0;
    return (inteiros * 100 + centavos) / 100;
  }

  /// Texto do visor. Vazio = "R$ 0,00"; digitando, mostra só o que foi
  /// digitado, sem completar casas: "R$ 4", "R$ 4,", "R$ 4,5", "R$ 1.250".
  /// Usa o mesmo espaço que não quebra do `V1Format.brl`.
  String get texto {
    if (cru.isEmpty) return V1Format.brl(0);
    final buffer = StringBuffer('R\$ ')..write(_comMilhar(_inteiros));
    if (_temVirgula) {
      buffer
        ..write(',')
        ..write(_decimais);
    }
    return buffer.toString();
  }

  /// Tecla de "0" a "9".
  MoneySheetAmountInput comDigito(String digito) {
    assert(digito.length == 1 && '0123456789'.contains(digito));
    if (_temVirgula) {
      if (_decimais.length >= maxDecimais) return this;
      return MoneySheetAmountInput('$cru$digito');
    }
    if (cru == '0') return MoneySheetAmountInput(digito);
    if (cru.length >= maxInteiros) return this;
    return MoneySheetAmountInput('$cru$digito');
  }

  /// Tecla ",".
  MoneySheetAmountInput comVirgula() {
    if (_temVirgula) return this;
    return MoneySheetAmountInput(cru.isEmpty ? '0,' : '$cru,');
  }

  /// Tecla "Apagar": tira o último caractere.
  MoneySheetAmountInput apagar() {
    if (cru.isEmpty) return this;
    return MoneySheetAmountInput(cru.substring(0, cru.length - 1));
  }

  static String _comMilhar(String inteiros) {
    if (inteiros.length <= 3) return inteiros;
    final corte = inteiros.length - 3;
    return '${inteiros.substring(0, corte)}.${inteiros.substring(corte)}';
  }
}

/// Visor do painel (`Anotar-gasto.dc.html`): valor em Fredoka 600 46 e, com
/// `gap: 2px`, uma linha de apoio em Poppins 400 13.
///
/// As duas linhas têm altura fixa: trocar o texto não desloca o resto do
/// painel. [linha] nula mantém o espaço da linha, vazio (o saldo ainda não
/// chegou).
class MoneySheetAmountDisplay extends StatelessWidget {
  const MoneySheetAmountDisplay({
    super.key,
    required this.valor,
    required this.linha,
    this.corLinha = LummyColors.ink600,
  });

  /// Texto do valor, já formatado ([MoneySheetAmountInput.texto]).
  final String valor;

  /// "Depois disso, sobram R$ 82,00" e variações.
  final String? linha;
  final Color corLinha;

  @override
  Widget build(BuildContext context) {
    final linha = this.linha;
    return Semantics(
      container: true,
      liveRegion: true,
      label: linha == null ? valor : '$valor. $linha',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                maxLines: 1,
                softWrap: false,
                style: LummyText.valorPainel(),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: LummyText.poppins(size: 13, color: corLinha),
              child: Text(
                // Espaço que não quebra: segura a altura da linha sem texto.
                linha ?? ' ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
