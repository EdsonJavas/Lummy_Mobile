import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

import 'v1_text.dart';

/// Uma opção do [LummySegmented].
class LummySegment<T> {
  const LummySegment(this.valor, this.rotulo);
  final T valor;
  final String rotulo;
}

/// Tamanhos do segmentado no mockup.
enum LummySegmentedSize {
  /// 44 de altura, raio 22, item raio 18: Período (Gastos) e simulador (Metas).
  medio(44, 22, 18),

  /// 48 de altura, raio 24, item raio 20: "Precisava / Queria" (painel).
  grande(48, 24, 20);

  const LummySegmentedSize(this.altura, this.raio, this.raioItem);
  final double altura;
  final double raio;
  final double raioItem;
}

/// Segmentado do mockup: trilho `#F2F4F7` com padding 4 e `gap: 4px`; a opção
/// escolhida ganha fundo branco e sombra `0 2px 6px rgba(11,21,51,0.10)`,
/// Poppins 600 14 tinta; as outras ficam transparentes, Poppins 500 14 `#5B6478`.
///
/// [selecionado] pode ser nulo (nenhuma marcada, ex.: "Precisava/Queria" antes
/// da escolha). Tocar na opção já marcada chama [onChanged] com o mesmo valor;
/// quem usa decide se desmarca.
class LummySegmented<T> extends StatelessWidget {
  const LummySegmented({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.onChanged,
    this.tamanho = LummySegmentedSize.medio,
    this.semanticLabel,
  });

  final List<LummySegment<T>> opcoes;
  final T? selecionado;
  final ValueChanged<T> onChanged;
  final LummySegmentedSize tamanho;

  /// Ex.: "Período", "Quanto guardar por semana".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        height: tamanho.altura,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: LummyColors.surface100,
          borderRadius: BorderRadius.circular(tamanho.raio),
        ),
        child: Row(
          children: [
            for (var i = 0; i < opcoes.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(child: _item(opcoes[i])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _item(LummySegment<T> opcao) {
    final ativo = opcao.valor == selecionado;
    return Semantics(
      button: true,
      selected: ativo,
      label: opcao.rotulo,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(opcao.valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ativo ? LummyColors.white : LummyColors.white.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(tamanho.raioItem),
            boxShadow: ativo ? LummyShadows.segment : const [],
          ),
          child: Text(
            opcao.rotulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LummyText.poppins(
              size: 14,
              weight: ativo ? FontWeight.w600 : FontWeight.w500,
              color: ativo ? LummyColors.ink900 : LummyColors.ink600,
            ),
          ),
        ),
      ),
    );
  }
}
