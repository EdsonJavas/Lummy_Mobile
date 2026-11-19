import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/app_theme.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/network_errors.dart';
import 'package:lummy/data/child/child_achievements_repository.dart';
import 'package:lummy/data/child/child_goals_repository.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/claim_share_screen.dart';
import 'package:lummy/screens/child/flows/criar_meta_flow.dart';
import 'package:lummy/screens/child/notifications_screen.dart';
import 'package:lummy/screens/child/request_money_screen.dart';
import 'package:lummy/screens/child/widgets/home/home_bottom_sections.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_claim_row.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_header.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_level.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_piggy_card.dart';
import 'package:lummy/screens/child/widgets/home/home_v1_quick_actions.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheets.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/branded_refresh_indicator.dart';
import 'package:lummy/shared/widgets/child_home_skeleton.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';
import 'package:lummy/utils/child_money_notification.dart';

/// Aba Início da criança (`Main.dc.html`): cabeçalho, nível, cofrinho
/// espacial com a meta, linha "Retirar" (DECISOES 20), ações rápidas e as
/// seções de baixo ([HomeBottomSections]).
///
/// Esta tela é dona das cargas (saldo, meta, sequência, contexto de resgate),
/// do realtime e do puxar-para-atualizar. Nome e nível vêm do
/// [ChildProfileController]; mudanças feitas por outras telas chegam pelo
/// [ChildDataChanges].
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _goalsRepo = ChildGoalsRepository();
  final _missionsRepo = ChildMissionsRepository();
  final _achievementsRepo = ChildAchievementsRepository();

  late final ChildDataChanges _changes;
  late final ChildProfileController _perfil;
  int _versaoSaldo = 0;
  int _versaoMeta = 0;
  int _versaoMissoes = 0;

  /// Só a primeira carga mostra o esqueleto.
  bool _carregando = true;

  /// Saldo do cofrinho. Nulo = a primeira leitura falhou (mostra "—"). Se uma
  /// recarga falhar depois, fica o último valor lido.
  double? _saldo;

  /// Meta sincronizada com o saldo. Nulo = não deu para ler.
  ChildGoalState? _estadoMeta;

  ChildStreak? _streak;

  /// Muda a cada puxar-para-atualizar (as seções de baixo recarregam).
  int _refreshTick = 0;

  // Descarta respostas antigas quando duas cargas se cruzam.
  int _pedidoSaldoMeta = 0;
  int _pedidoSequencia = 0;

  // Resgate ("Retirar minha parte").
  int _pontosDeMissao = 0;
  int _conquistasConcluidas = 0;
  bool _isClaimContextLoading = false;
  String? _activeDistributionId;
  double _activeDistributionAmount = 0.0;
  bool _alreadyClaimedCurrentDistribution = false;
  String _currentChildId = '';
  String _currentChildName = 'Você';
  List<Map<String, dynamic>> _realSiblings = const [];

  RealtimeChannel? _goalsChannel;
  RealtimeChannel? _balanceChannel;
  RealtimeChannel? _customMissionsChannel;
  RealtimeChannel? _dailyMissionsChannel;
  RealtimeChannel? _achievementsChannel;

  /// Junta os avisos de missão do realtime (as 5 do dia chegam de uma vez).
  Timer? _avisoMissoesTimer;

  @override
  void initState() {
    super.initState();
    _changes = context.read<ChildDataChanges>();
    _perfil = context.read<ChildProfileController>();
    _versaoSaldo = _changes.versao(ChildDataKind.saldo);
    _versaoMeta = _changes.versao(ChildDataKind.meta);
    _versaoMissoes = _changes.versao(ChildDataKind.missoes);
    _changes.addListener(_aoMudarDados);

    unawaited(_iniciarNotificacoes());
    unawaited(_cargaInicial());
    _assinarRealtime();
  }

  @override
  void dispose() {
    _changes.removeListener(_aoMudarDados);
    _avisoMissoesTimer?.cancel();
    try {
      final supabase = Supabase.instance.client;
      for (final canal in [
        _balanceChannel,
        _customMissionsChannel,
        _dailyMissionsChannel,
        _achievementsChannel,
        _goalsChannel,
      ]) {
        if (canal != null) supabase.removeChannel(canal);
      }
    } catch (_) {}
    super.dispose();
  }

  // ── Cargas ──

  Future<void> _iniciarNotificacoes() async {
    try {
      await initChildMoneyNotifications();
    } catch (e, st) {
      debugLogDataLoad('Home: iniciar notificações', e, st);
    }
  }

  Future<void> _cargaInicial() async {
    await Future.wait<void>([_carregarTudo(), _esperarPerfil()]);
    if (!mounted) return;
    setState(() => _carregando = false);
  }

  /// Cada carga trata o próprio erro; esta função não lança.
  Future<void> _carregarTudo() async {
    await Future.wait<void>([
      _carregarSaldoEMeta(),
      _carregarSequencia(),
      _loadClaimContext(),
      _carregarConquistas(),
      _carregarPontosDeMissao(),
    ]);
  }

  /// Espera o perfil (carregado pela casca) para a saudação não piscar.
  /// Desiste em 3 s: a tela abre mesmo sem o nome.
  Future<void> _esperarPerfil() {
    if (_perfil.carregado) return Future.value();
    final pronto = Completer<void>();
    void ouvir() {
      if (_perfil.carregado && !pronto.isCompleted) pronto.complete();
    }

    _perfil.addListener(ouvir);
    return pronto.future
        .timeout(const Duration(seconds: 3), onTimeout: () {})
        .whenComplete(() => _perfil.removeListener(ouvir));
  }

  Future<void> _carregarSaldoEMeta() async {
    final pedido = ++_pedidoSaldoMeta;
    try {
      final estado = await _goalsRepo.carregarMetaSincronizada();
      if (!mounted || pedido != _pedidoSaldoMeta) return;
      setState(() {
        _estadoMeta = estado;
        _saldo = estado.saldo;
      });
      unawaited(checkAndNotifyBalanceIncrease(estado.saldo));
    } catch (e, st) {
      // Sem rede numa recarga: mantém o último saldo e a última meta lidos.
      // Só a primeira carga que falha deixa nulo (o cofrinho mostra "—" e o
      // "tentar de novo").
      debugLogDataLoad('Home: saldo e meta', e, st);
    }
  }

  Future<void> _carregarSequencia() async {
    final pedido = ++_pedidoSequencia;
    try {
      final streak = await _missionsRepo.sequencia();
      if (!mounted || pedido != _pedidoSequencia) return;
      setState(() => _streak = streak);
    } catch (e, st) {
      // Sem dado, a pílula e a seção ficam como estavam.
      debugLogDataLoad('Home: sequência de dias', e, st);
    }
  }

  /// Só para a pontuação do resgate (a lista de conquistas é das seções de
  /// baixo).
  Future<void> _carregarConquistas() async {
    try {
      final resultado = await _achievementsRepo.listar();
      if (!mounted) return;
      setState(() => _conquistasConcluidas = resultado.totalConquistadas);
    } catch (e, st) {
      debugLogDataLoad('Home: conquistas (pontuação do resgate)', e, st);
    }
  }

  Future<void> _carregarPontosDeMissao() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _pontosDeMissao = prefs.getInt('missions_earned_points') ?? 0;
      });
    } catch (e, st) {
      debugLogDataLoad('Home: pontos de missão', e, st);
    }
  }

  Future<void> _loadClaimContext() async {
    if (!mounted) return;
    setState(() => _isClaimContextLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _activeDistributionId = null;
          _activeDistributionAmount = 0.0;
          _alreadyClaimedCurrentDistribution = false;
          _currentChildId = '';
          _currentChildName = 'Você';
          _realSiblings = const [];
          _isClaimContextLoading = false;
        });
        return;
      }

      final me = await supabase
          .from('children')
          .select('id, nome, responsavel_id')
          .eq('id', user.id)
          .maybeSingle();
      if (me == null) {
        if (!mounted) return;
        setState(() {
          _activeDistributionId = null;
          _activeDistributionAmount = 0.0;
          _alreadyClaimedCurrentDistribution = false;
          _currentChildId = user.id;
          _currentChildName = 'Você';
          _realSiblings = const [];
          _isClaimContextLoading = false;
        });
        return;
      }

      final parentId = me['responsavel_id'] as String?;
      final childId = me['id'] as String? ?? user.id;
      final childName = ((me['nome'] as String?) ?? 'Você').trim();

      final siblings = parentId == null
          ? <Map<String, dynamic>>[]
          : (await supabase
                  .from('children')
                  .select('id, nome')
                  .eq('responsavel_id', parentId)
                  .neq('id', childId))
              .cast<Map<String, dynamic>>();

      Map<String, dynamic>? activeDistribution;
      if (parentId != null && siblings.isNotEmpty) {
        // 'active' aqui é o status de allowance_distributions (não o de goals).
        activeDistribution = await supabase
            .from('allowance_distributions')
            .select('id, total_amount')
            .eq('parent_id', parentId)
            .eq('status', 'active')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      bool alreadyClaimed = false;
      if (activeDistribution != null) {
        final claim = await supabase
            .from('allowance_claims')
            .select('id')
            .eq('distribution_id', activeDistribution['id'] as String)
            .eq('child_id', childId)
            .maybeSingle();
        alreadyClaimed = claim != null;
      }

      if (!mounted) return;
      setState(() {
        _activeDistributionId = activeDistribution?['id'] as String?;
        _activeDistributionAmount =
            (activeDistribution?['total_amount'] as num?)?.toDouble() ?? 0.0;
        _alreadyClaimedCurrentDistribution = alreadyClaimed;
        _currentChildId = childId;
        _currentChildName = childName.isEmpty ? 'Você' : childName;
        _realSiblings = siblings;
        _isClaimContextLoading = false;
      });
    } catch (e, st) {
      debugLogDataLoad('Contexto de resgate', e, st);
      if (!mounted) return;
      setState(() => _isClaimContextLoading = false);
    }
  }

  /// Puxar para atualizar: tudo de novo, sem esqueleto.
  Future<void> _refreshData() async {
    if (mounted) setState(() => _refreshTick++);
    await Future.wait<void>([_carregarTudo(), _perfil.refresh()]);
  }

  // ── Avisos de outras telas e realtime ──

  /// "Quem grava avisa; quem mostra escuta." Recarrega sem esqueleto e sem
  /// mexer na rolagem.
  void _aoMudarDados() {
    if (!mounted) return;
    final saldo = _changes.versao(ChildDataKind.saldo);
    final meta = _changes.versao(ChildDataKind.meta);
    final missoes = _changes.versao(ChildDataKind.missoes);
    final saldoMudou = saldo != _versaoSaldo;
    final metaMudou = meta != _versaoMeta;
    final missoesMudaram = missoes != _versaoMissoes;
    _versaoSaldo = saldo;
    _versaoMeta = meta;
    _versaoMissoes = missoes;

    if (saldoMudou || metaMudou) unawaited(_carregarSaldoEMeta());
    if (saldoMudou) unawaited(_loadClaimContext());
    if (missoesMudaram) {
      unawaited(_carregarSequencia());
      unawaited(_perfil.refresh());
    }
  }

  /// Chamado pelas seções de baixo ao voltar da tela de Missões. O listener
  /// acima recarrega sequência e perfil; o das seções recarrega a lista.
  void _aoVoltarDasMissoes() {
    if (!mounted) return;
    _changes.avisar({ChildDataKind.missoes});
  }

  void _avisarMissoesEmLote() {
    _avisoMissoesTimer?.cancel();
    _avisoMissoesTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _changes.avisar({ChildDataKind.missoes});
    });
  }

  void _aoMudarSaldoNoBanco(PostgresChangePayload payload) {
    if (!mounted) return;
    final novo = (payload.newRecord['balance'] as num?)?.toDouble();
    final anterior = _saldo;
    final saldoMudou =
        novo != null && (anterior == null || (novo - anterior).abs() >= 0.005);

    if (novo != null) {
      // Mostra na hora pelo payload, sem esperar a nova consulta.
      setState(() {
        _saldo = novo;
        final estado = _estadoMeta;
        if (estado != null) {
          _estadoMeta = ChildGoalState(
            saldo: novo,
            atual: estado.atual,
            ultimaConcluida: estado.ultimaConcluida,
          );
        }
      });
      unawaited(checkAndNotifyBalanceIncrease(novo));
    }

    if (saldoMudou) {
      // Dinheiro que entrou ou saiu por fora (ex.: os pais): avisa as outras
      // abas. O listener desta tela recarrega saldo, meta e resgate.
      _changes.avisar({ChildDataKind.saldo});
    } else {
      unawaited(_carregarSaldoEMeta());
    }
    // O mesmo UPDATE pode ter mudado XP e nível.
    unawaited(_perfil.refresh());
  }

  void _assinarRealtime() {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      PostgresChangeFilter doFilho(String coluna) => PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: coluna,
            value: user.id,
          );

      _balanceChannel = supabase
          .channel('public:children:balance:${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'children',
            filter: doFilho('id'),
            callback: _aoMudarSaldoNoBanco,
          )
          .subscribe();

      _customMissionsChannel = supabase
          .channel('public:custom_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'custom_missions',
            filter: doFilho('child_id'),
            callback: (_) {
              if (!mounted) return;
              unawaited(showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'Nova missão adicionada! 🎯',
                body: 'Seu responsável criou uma missão para você.',
              ));
              _avisarMissoesEmLote();
            },
          )
          .subscribe();

      // Sem notificação local aqui: a própria Home pede as 5 missões do dia
      // (RPC das seções de baixo) e o aviso viraria ruído (PLANO 2.9).
      _dailyMissionsChannel = supabase
          .channel('public:daily_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'daily_missions',
            filter: doFilho('child_id'),
            callback: (_) {
              if (!mounted) return;
              _avisarMissoesEmLote();
            },
          )
          .subscribe();

      _achievementsChannel = supabase
          .channel('public:achievements:new')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'achievements',
            callback: (_) {
              if (!mounted) return;
              unawaited(showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
                title: 'Nova conquista disponível! 🏆',
                body: 'Seu responsável adicionou uma nova conquista.',
              ));
              _changes.avisar({ChildDataKind.conquistas});
              unawaited(_carregarConquistas());
            },
          )
          .subscribe();

      _goalsChannel = supabase
          .channel('public:goals:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'goals',
            filter: doFilho('child_id'),
            callback: (_) {
              if (!mounted) return;
              unawaited(_carregarSaldoEMeta());
              unawaited(showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3,
                title: 'Nova meta criada! 🚀',
                body: 'Seu responsável adicionou uma nova meta.',
              ));
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'goals',
            filter: doFilho('child_id'),
            callback: (_) {
              if (!mounted) return;
              unawaited(_carregarSaldoEMeta());
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'goals',
            filter: doFilho('child_id'),
            callback: (_) {
              if (!mounted) return;
              unawaited(_carregarSaldoEMeta());
            },
          )
          .subscribe();
    } catch (e, st) {
      debugLogDataLoad('Erro ao assinar realtime', e, st);
    }
  }

  // ── Resgate ("Retirar minha parte") ──

  bool get _hasRealSiblings => _realSiblings.isNotEmpty;

  double get _currentWeightedScore {
    final score = _pontosDeMissao.toDouble() + (_conquistasConcluidas * 5.0);
    return score <= 0 ? 1.0 : score;
  }

  List<double> get _otherSiblingsScores =>
      List<double>.filled(_realSiblings.length, 1.0);

  List<String> get _otherSiblingsNames => _realSiblings
      .map((s) => (s['nome'] as String?)?.trim())
      .whereType<String>()
      .where((n) => n.isNotEmpty)
      .toList();

  /// A mesma conta da `ClaimShareScreen._computeYourShare`, com as mesmas
  /// pontuações que esta tela passa para ela.
  double get _minhaParte {
    final meu = _currentWeightedScore;
    final scores = [meu, ..._otherSiblingsScores];
    final total = scores.fold<double>(0, (a, b) => a + (b < 0 ? 0 : b));
    if (total <= 0) return 0;
    final ratio = (meu <= 0 ? 0 : meu) / total;
    final cents = (_activeDistributionAmount * 100).round();
    return (cents * ratio).floor() / 100.0;
  }

  /// Há valor para retirar: irmãos reais, distribuição ativa com valor e a
  /// criança ainda não retirou.
  bool get _podeRetirar =>
      _hasRealSiblings &&
      _activeDistributionId != null &&
      _activeDistributionAmount > 0 &&
      !_alreadyClaimedCurrentDistribution &&
      _minhaParte > 0;

  Future<void> _onClaimShareTap() async {
    if (_isClaimContextLoading) return;
    if (!_hasRealSiblings) {
      LummyFeedback.info(
        context,
        'Não há irmãos cadastrados pelo mesmo responsável.',
      );
      return;
    }
    final distributionId = _activeDistributionId;
    if (distributionId == null || _activeDistributionAmount <= 0) {
      LummyFeedback.info(context, 'Sem valor ativo para resgate no momento.');
      return;
    }
    if (_alreadyClaimedCurrentDistribution) {
      LummyFeedback.info(
        context,
        'Você já retirou sua parte desta distribuição.',
      );
      return;
    }

    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        // Área da criança sempre clara (D12), também nesta tela empurrada.
        builder: (context) => Theme(
          data: AppTheme.lightTheme,
          child: ClaimShareScreen(
          distributionId: distributionId,
          childId: _currentChildId,
          totalAmount: _activeDistributionAmount,
          currentChildScore: _currentWeightedScore,
          otherChildrenScores: _otherSiblingsScores,
          otherChildrenNames: _otherSiblingsNames,
          currentChildName: _currentChildName,
        ),
        ),
      ),
    );
    if (!mounted) return;
    if (result is Map && result['claimed'] == true) {
      final claimedAmount = (result['amount'] as num?)?.toDouble() ?? 0.0;
      // A linha some na hora; o aviso recarrega saldo, meta e resgate.
      setState(() => _alreadyClaimedCurrentDistribution = true);
      _changes.avisar({ChildDataKind.saldo});
      LummyFeedback.success(
        context,
        'Você retirou ${V1Format.brl(claimedAmount)}',
      );
    }
  }

  // ── Navegação ──

  void _abrirNotificacoes() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  void _abrirPedirDinheiro() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RequestMoneyScreen()),
    );
  }

  /// O painel grava e avisa `ChildDataChanges`; o listener recarrega.
  void _anotarGasto() {
    unawaited(showAnotarGastoSheet(context, saldoAtual: _saldo));
  }

  /// O fluxo grava a meta e avisa `ChildDataChanges`; o listener recarrega.
  void _criarMeta() {
    unawaited(abrirCriacaoDeMeta(context));
  }

  // ── Tela ──

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;

    return ColoredBox(
      color: LummyColors.white,
      child: SafeArea(
        bottom: false,
        child: _carregando
            ? const ChildHomeSkeleton()
            : BrandedRefreshIndicator(
                onRefresh: _refreshData,
                color: tema,
                backgroundColor: LummyColors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _conteudo(context),
                ),
              ),
      ),
    );
  }

  Widget _conteudo(BuildContext context) {
    final perfil = ChildProfileController.of(context);

    // A entrada só toca quando o bloco é montado (primeira pintura depois do
    // esqueleto). Nas recargas só os números mudam. A chave mantém o estado
    // de cada bloco quando a linha "Retirar" entra ou sai da coluna.
    Widget entrada(Widget child, int ordem) {
      return child
          .animate(key: ValueKey<int>(ordem), delay: (70 * ordem).ms)
          .fadeIn(duration: 240.ms)
          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entrada(
          HomeV1Header(
            primeiroNome: perfil.primeiroNome,
            streak: _streak,
            onNotificacoesTap: _abrirNotificacoes,
          ),
          0,
        ),
        // Sem nível lido do banco, a barra some (D7).
        if (perfil.nivelConhecido) ...[
          const SizedBox(height: 16),
          entrada(
            HomeV1Level(
              level: perfil.level,
              xpNoNivel: perfil.xpNoNivel,
              progresso: perfil.progressoNivel,
            ),
            1,
          ),
        ],
        const SizedBox(height: 18),
        entrada(
          HomeV1PiggyCard(
            saldo: _saldo,
            estado: _estadoMeta,
            onTentarDeNovo: () => unawaited(_carregarSaldoEMeta()),
            onCriarMeta: _criarMeta,
          ),
          2,
        ),
        if (_podeRetirar) ...[
          const SizedBox(height: 12),
          HomeV1ClaimRow(
            minhaParte: _minhaParte,
            onRetirar: () => unawaited(_onClaimShareTap()),
          ),
        ],
        const SizedBox(height: 22),
        entrada(
          HomeV1QuickActions(
            onPedirDinheiro: _abrirPedirDinheiro,
            onAnotarGasto: _anotarGasto,
            onNovaMeta: _criarMeta,
          ),
          3,
        ),
        // Sem `entrada`: as seções de baixo já animam a própria chegada.
        HomeBottomSections(
          key: const ValueKey<String>('home-secoes-de-baixo'),
          refreshTick: _refreshTick,
          streak: _streak,
          onMissoesTalvezMudaram: _aoVoltarDasMissoes,
        ),
        SizedBox(height: ChildBottomNavMetrics.scrollBottomPadding(context)),
      ],
    );
  }
}
