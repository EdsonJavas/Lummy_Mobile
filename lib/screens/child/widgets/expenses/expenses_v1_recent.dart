import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'expenses_v1_calc.dart';

/// "Últimos gastos" (`Gastos-lista.dc.html`): gastos agrupados por dia, do mais
/// novo para o mais antigo. Mostra os 5 mais recentes e, havendo mais, o link
/// "Ver todos os gastos" abre o resto do período.
class ExpensesV1Recent extends StatelessWidget {
  const ExpensesV1Recent({
    super.key,
    required this.gastos,
    required this.expandido,
    required this.onVerTodos,
    required this.agora,
  });

  /// Gastos do período, já filtrados pela categoria tocada, mais novo primeiro.
  final List<ChildExpense> gastos;

  /// true = mostra todos; false = só os [ExpensesCalc.limiteRecentes] primeiros.
  final bool expandido;
  final VoidCallback onVerTodos;

  /// "Agora" da tela, para "Hoje" e "Ontem".
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final temMais = gastos.length > ExpensesCalc.limiteRecentes;
    final visiveis = expandido || !temMais
        ? gastos
        : gastos.sublist(0, ExpensesCalc.limiteRecentes);
    final grupos = ExpensesCalc.agruparPorDia(visiveis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(titulo: 'Últimos gastos'),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: gastos.isEmpty
              ? const _Vazio()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final grupo in grupos) ...[
                      const SizedBox(height: 14),
                      Semantics(
                        header: true,
                        child: Text(
                          V1Format.rotuloDia(grupo.data, agora: agora),
                          style: LummyText.contagem(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      for (final gasto in grupo.gastos)
                        _GastoItem(key: ValueKey(gasto.id), gasto: gasto),
                    ],
                    if (temMais && !expandido)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ThemeLink(
                          rotulo: 'Ver todos os gastos',
                          gap: 4,
                          onTap: onVerTodos,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Lista vazia: os textos de hoje do app, com as fontes novas.
class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nenhuma transação recente', style: LummyText.corpo(context)),
            const SizedBox(height: 2),
            Text('Suas movimentações aparecerão aqui', style: LummyText.apoio(context)),
          ],
        ),
      ),
    );
  }
}

/// Um gasto: quadrado neutro 44 com o ícone da categoria, descrição, sub-linha
/// (categoria + marca "Precisava"/"Queria") e o valor à direita, sem sinal.
class _GastoItem extends StatelessWidget {
  const _GastoItem({super.key, required this.gasto});

  final ChildExpense gasto;

  @override
  Widget build(BuildContext context) {
    final cat = ChildCategories.porId(gasto.categoriaId);
    final descricao = gasto.descricao.trim();
    // DECISOES 19: o painel novo grava o nome da categoria como descrição;
    // nesse caso a sub-linha não repete a categoria.
    final repeteCategoria =
        descricao.isEmpty || descricao.toLowerCase() == cat.nome.toLowerCase();
    final titulo = descricao.isEmpty ? cat.nome : descricao;
    final marca = gasto.needOrWant;
    final temSubLinha = !repeteCategoria || marca != null;

    return MergeSemantics(
      child: Container(
        // `min-height: 64px` de conteúdo + 1 da borda de baixo (content-box).
        constraints: const BoxConstraints(minHeight: 65),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.cores.linha)),
        ),
        child: Row(
          children: [
            NeutralIconTile(
              glyph: cat.glyph,
              size: 44,
              radius: 14,
              iconSize: 20,
              strokeWidth: cat.traco(2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LummyText.corpo(context),
                  ),
                  if (temSubLinha) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (!repeteCategoria)
                          Flexible(
                            child: Text(
                              cat.nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LummyText.apoio(context),
                            ),
                          ),
                        if (!repeteCategoria && marca != null) const SizedBox(width: 10),
                        if (marca != null) _Marca(marca: marca),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              V1Format.brl(gasto.valor),
              maxLines: 1,
              softWrap: false,
              style: LummyText.corpo(context, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quadradinho 8×8 raio 2 (tema = "Precisava", laranja = "Queria") + o texto.
class _Marca extends StatelessWidget {
  const _Marca({required this.marca});

  final NeedOrWant marca;

  @override
  Widget build(BuildContext context) {
    final cor = marca == NeedOrWant.need
        ? ChildThemeColorController.of(context).tema
        : LummyColors.orange600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(marca.rotulo, maxLines: 1, softWrap: false, style: LummyText.apoio(context)),
      ],
    );
  }
}
