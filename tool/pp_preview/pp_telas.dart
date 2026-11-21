// Telas montadas com os widgets REAIS do app, na mesma composição e com os
// mesmos espaços das telas de produção, mas com dados de exemplo (sem
// Supabase). Cada bloco cita o arquivo de produção que ele copia.
//
// Não é código de produção: só alimenta tool/pp_preview/main.dart.

import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_calc.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_categories.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_need_want.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_recent.dart';
import 'package:lummy/screens/child/widgets/expenses/expenses_v1_summary.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_calc.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_card.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_completed.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_manage.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_simulator.dart';
import 'package:lummy/screens/child/widgets/goals/goals_v1_stops.dart';
import 'package:lummy/screens/child/widgets/home/home_b_achievements.dart';
import 'package:lummy/screens/child/widgets/home/home_b_lesson_card.dart';
import 'package:lummy/screens/child/widgets/home/home_b_missions.dart';
import 'package:lummy/screens/child/widgets/home/home_b_streak.dart';
import 'package:lummy/screens/child/widgets/home/home_b_tip.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_header.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_level.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_piggy_card.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_quick_actions.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheet_amount.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheet_category_grid.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheet_frame.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheet_keypad.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/branded_refresh_indicator.dart';

import 'pp_dados.dart';

void _nada() {}

Future<void> _nadaAsync() async {}

/// Raiz de uma aba, como nas telas reais: fundo branco + SafeArea sem o
/// fundo + puxar para atualizar na cor do tema.
Widget _raizDaAba(BuildContext context, Widget rolagem) {
  final tema = ChildThemeColorController.of(context).tema;
  return ColoredBox(
    color: context.cores.fundo,
    child: SafeArea(
      bottom: false,
      child: BrandedRefreshIndicator(
        onRefresh: _nadaAsync,
        color: tema,
        backgroundColor: context.cores.superficie,
        child: rolagem,
      ),
    ),
  );
}

/// Home: cópia de `home_page.dart` (build e _conteudo) + o corpo de
/// `home_bottom_sections.dart` (seções com 26/18/14/22/20 de topo).
class PpHome extends StatelessWidget {
  const PpHome({super.key, required this.controle, this.extraFim = 0});

  final ScrollController controle;

  /// Espaço em branco depois do fim real (só para alinhar telas "rolada").
  final double extraFim;

  @override
  Widget build(BuildContext context) {
    final perfil = ChildProfileController.of(context);
    final aula = HomeBLessonCard.aulaRapida();

    final secoesDeBaixo = <Widget>[
      const Padding(
        padding: EdgeInsets.only(top: 26),
        child: HomeBMissions(missoes: ppMissoes, onAbrirMissoes: _nada),
      ),
      const Padding(padding: EdgeInsets.only(top: 18), child: HomeBTip()),
      if (aula != null)
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: HomeBLessonCard(aula: aula, onTap: _nada),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 22),
        child: HomeBStreak(streak: ppSequencia),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 20),
        child: HomeBAchievements(conquistas: ppConquistas, onVerTodas: _nada),
      ),
    ];

    return _raizDaAba(
      context,
      SingleChildScrollView(
        controller: controle,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeV1Header(
              primeiroNome: perfil.primeiroNome,
              streak: ppSequencia,
              onNotificacoesTap: _nada,
            ),
            const SizedBox(height: 16),
            HomeV1Level(
              level: perfil.level,
              xpNoNivel: perfil.xpNoNivel,
              progresso: perfil.progressoNivel,
            ),
            const SizedBox(height: 18),
            HomeV1PiggyCard(
              saldo: ppSaldo,
              estado: ppEstadoMeta,
              onTentarDeNovo: _nada,
              onCriarMeta: _nada,
            ),
            const SizedBox(height: 22),
            const HomeV1QuickActions(
              onPedirDinheiro: _nada,
              onAnotarGasto: _nada,
              onNovaMeta: _nada,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: secoesDeBaixo,
            ),
            SizedBox(height: ChildBottomNavMetrics.scrollBottomPadding(context)),
            SizedBox(height: extraFim),
          ],
        ),
      ),
    );
  }
}

/// Gastos: cópia de `expenses_screen.dart` (_conteudo), período "Mês".
class PpGastos extends StatelessWidget {
  const PpGastos({super.key, required this.controle, this.extraFim = 0});

  final ScrollController controle;
  final double extraFim;

  @override
  Widget build(BuildContext context) {
    final resumo = ExpensesCalc.resumir(ppGastos, ExpensesPeriod.mes, ppAgora);
    final recentes = ExpensesCalc.filtrarPorCategoria(resumo.gastos, null);
    final needWant = resumo.needWant;

    return _raizDaAba(
      context,
      SingleChildScrollView(
        controller: controle,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          ChildBottomNavMetrics.scrollBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ChildTabHeader(
              title: 'Gastos',
              trailing: LummyPillButton(
                rotulo: 'Anotar gasto',
                glyph: LummyGlyphs.shoppingBag,
                onTap: _nada,
              ),
            ),
            const SizedBox(height: 14),
            LummySegmented<ExpensesPeriod>(
              semanticLabel: 'Período',
              opcoes: [
                for (final p in ExpensesPeriod.values) LummySegment(p, p.rotulo),
              ],
              selecionado: ExpensesPeriod.mes,
              onChanged: (_) {},
            ),
            const SizedBox(height: 22),
            ExpensesV1Summary(resumo: resumo, agora: ppAgora),
            const SizedBox(height: 28),
            ExpensesV1Categories(
              categorias: resumo.categorias,
              selecionadaId: null,
              onTap: (_) {},
            ),
            if (needWant != null)
              Padding(
                padding: const EdgeInsets.only(top: 26),
                child: ExpensesV1NeedWant(dados: needWant),
              ),
            const SizedBox(height: 26),
            ExpensesV1Recent(
              gastos: recentes,
              expandido: false,
              agora: ppAgora,
              onVerTodos: _nada,
            ),
            SizedBox(height: extraFim),
          ],
        ),
      ),
    );
  }
}

/// Metas: cópia de `goals_screen.dart` (build e _secoes), meta em andamento.
class PpMetas extends StatelessWidget {
  const PpMetas({super.key, required this.controle, this.extraFim = 0});

  final ScrollController controle;
  final double extraFim;

  @override
  Widget build(BuildContext context) {
    final paradas = GoalsV1Calc.paradas(
      nomeDaMeta: ppMeta.name,
      alvo: ppMeta.targetAmount,
      saldo: ppEstadoMeta.saldo,
    );
    return _raizDaAba(
      context,
      LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          controller: controle,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ChildTabHeader(title: 'Metas'),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: GoalsV1Card(
                    meta: ppMeta,
                    progresso: ppEstadoMeta.progresso,
                    falta: ppEstadoMeta.falta,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: GoalsV1Simulator(
                    falta: ppEstadoMeta.falta,
                    valorPorSemana: GoalsV1Calc.valorPorSemanaPadrao,
                    onValorChanged: (_) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 26),
                  child: GoalsV1Stops(paradas: paradas),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: GoalsV1Completed(metas: ppConcluidas),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: GoalsV1Manage(nomeDaMeta: ppMeta.name, onDesistir: _nada),
                ),
                SizedBox(height: ChildBottomNavMetrics.scrollBottomPadding(context)),
                SizedBox(height: extraFim),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Painel "Anotar gasto": cópia de `money_sheet_expense.dart` (build) com o
/// estado do mockup: "R$ 4,50", Comida e Queria escolhidos, saldo R$ 86,50.
class PpPainelGasto extends StatelessWidget {
  const PpPainelGasto({super.key});

  static const _segmentos = [
    LummySegment(NeedOrWant.need, 'Precisava'),
    LummySegment(NeedOrWant.want, 'Queria'),
  ];

  @override
  Widget build(BuildContext context) {
    final entrada = const MoneySheetAmountInput()
        .comDigito('4')
        .comVirgula()
        .comDigito('5')
        .comDigito('0');
    final categorias = ChildCategories.permitidas(const <String>[])
        .map(MoneySheetOption.categoria)
        .toList(growable: false);

    return MoneySheetFrame(
      titulo: 'Anotar gasto',
      corpo: [
        const SizedBox(height: 4),
        MoneySheetAmountDisplay(
          valor: entrada.texto,
          linha: 'Depois disso, sobram ${V1Format.brl(ppSaldo - entrada.valor)}',
          corLinha: context.cores.tintaApoio,
        ),
        const SizedBox(height: 16),
        Text('Com o quê?', style: LummyText.pergunta(context)),
        const SizedBox(height: 10),
        MoneySheetOptionGrid(
          opcoes: categorias,
          escolhidaId: 'food',
          onEscolher: (_) {},
        ),
        const SizedBox(height: 16),
        Text('Você precisava ou só queria?', style: LummyText.pergunta(context)),
        const SizedBox(height: 10),
        LummySegmented<NeedOrWant>(
          opcoes: _segmentos,
          selecionado: NeedOrWant.want,
          tamanho: LummySegmentedSize.grande,
          semanticLabel: 'Você precisava ou só queria?',
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        MoneySheetKeypad(
          onDigito: (_) {},
          onVirgula: _nada,
          onApagar: _nada,
          onLimpar: _nada,
        ),
      ],
      rodape: const LummyWideButton(rotulo: 'Salvar gasto', onTap: _nada),
    );
  }
}

/// Teste de métrica: Poppins em vários tamanhos com a altura herdada (como
/// está hoje), com 1.5 e com a altura "normal" do Chrome arredondada.
class PpTexto extends StatelessWidget {
  const PpTexto({super.key});

  static double _normalChrome(double s) =>
      ((1.05 * s).roundToDouble() + (0.35 * s).roundToDouble() + (0.1 * s).roundToDouble()) / s;

  @override
  Widget build(BuildContext context) {
    final linhas = <Widget>[];
    for (final s in const [12.0, 13.0, 14.0, 15.0, 18.0, 24.0]) {
      final variantes = <String, double?>{'herdada': null, '1.5': 1.5, 'chrome': _normalChrome(s)};
      for (final v in variantes.entries) {
        linhas.add(
          Text(
            'T${s.toInt()} ${v.key} Hg',
            style: LummyText.poppins(context, size: s, height: v.value),
          ),
        );
      }
    }
    return ColoredBox(
      color: context.cores.fundo,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: linhas),
      ),
    );
  }
}
