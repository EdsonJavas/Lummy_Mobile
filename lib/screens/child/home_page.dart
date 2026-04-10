import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/core/constants/app_constants.dart';
import 'package:lummy_login/core/utils/network_errors.dart';
import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/screens/child/new_goal_screen.dart';
import 'package:lummy_login/screens/child/request_money_screen.dart';
import 'package:lummy_login/screens/child/claim_share_screen.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummy_login/utils/supabase_test.dart';
import 'package:lummy_login/utils/child_money_notification.dart';
import 'package:lummy_login/screens/child/profile_page.dart';
import 'package:lummy_login/screens/child/daily_missions_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados do usuário
  String userName = '';
  final String userRole = 'Pequeno Empreendedor';
  double currentBalance = 0.0;
  bool _balanceLoadFailed = false;
  double _weekIncomeTotal = 0.0;
  double savingsGoal = 0.0;
  String goalName = '';
  String goalEmoji = '🎯';
  double goalCurrentAmount = 0.0;
  bool hasActiveGoal = false;
  int _earnedMissionPoints = 0;
  RealtimeChannel? _goalsChannel;
  RealtimeChannel? _balanceChannel;
  RealtimeChannel? _customMissionsChannel;
  RealtimeChannel? _dailyMissionsChannel;
  RealtimeChannel? _achievementsChannel;
  bool _isLoading = true;
  bool _isClaimContextLoading = false;
  String? _activeDistributionId;
  double _activeDistributionAmount = 0.0;
  bool _alreadyClaimedCurrentDistribution = false;
  String _currentChildId = '';
  String _currentChildName = 'Você';
  List<Map<String, dynamic>> _realSiblings = const [];

  // Lista de transações
  List<Map<String, dynamic>> transactions = [];

  // Lista de conquistas
  List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_saving',
      'title': 'Primeira Economia',
      'description': 'Você guardou seu primeiro dinheiro!',
      'emoji': '🥇',
      'isCompleted': true,
    },
    {
      'id': 'expense_control',
      'title': 'Controle de Gastos',
      'description': 'Anotou gastos por 7 dias seguidos',
      'emoji': '📊',
      'isCompleted': true,
    },
    {
      'id': 'goal_reached',
      'title': 'Meta Alcançada',
      'description': 'Complete sua primeira meta de economia',
      'emoji': '🎯',
      'isCompleted': false,
    },
  ];

  // Lista de dicas educativas - MUITAS dicas!
  int currentTipIndex = 0;
  final List<EducationalTip> educationalTips = [
    EducationalTip(
      'Dica do Dia',
      'Que tal anotar todos os seus gastos por uma semana? Isso ajuda a entender para onde vai seu dinheiro!',
      '📝',
    ),
    EducationalTip(
      'Você Sabia?',
      'Guardar 10% do que você ganha é um ótimo começo para realizar seus sonhos!',
      '💡',
    ),
    EducationalTip(
      'Desafio',
      'Tente economizar R\$ 5,00 esta semana comprando menos doces e lanches!',
      '🎯',
    ),
    EducationalTip(
      'Aprenda',
      'Antes de comprar algo, pergunte: "Eu realmente preciso disso agora?"',
      '🤔',
    ),
    EducationalTip(
      'Meta Inteligente',
      'Divida sua meta grande em metas menores. Assim fica mais fácil de conquistar!',
      '🧠',
    ),
    EducationalTip(
      'Super Dica',
      'Antes de pedir algo aos pais, pense se pode economizar sua mesada para comprar!',
      '⭐',
    ),
    EducationalTip(
      'Sabedoria',
      'Dinheiro guardado hoje é um sonho realizado amanhã!',
      '🌟',
    ),
    EducationalTip(
      'Aprenda Mais',
      'Compare preços antes de comprar. Às vezes o mesmo produto está mais barato em outro lugar!',
      '🔍',
    ),
    EducationalTip(
      'Você Sabia?',
      'Fazer uma lista antes de comprar ajuda a não gastar com coisas que não precisa!',
      '📋',
    ),
    EducationalTip(
      'Desafio Diário',
      'Conte quantas vezes você resistiu comprar algo desnecessário hoje!',
      '💪',
    ),
    EducationalTip(
      'Dica Especial',
      'Guarde as moedas que sobram no troco. No fim do mês você se surpreende!',
      '🪙',
    ),
    EducationalTip(
      'Educação Financeira',
      'Aprenda a diferença entre QUERER e PRECISAR. Isso muda tudo!',
      '🎓',
    ),
    EducationalTip(
      'Pensamento do Dia',
      'Pequenas economias se transformam em grandes conquistas!',
      '💭',
    ),
    EducationalTip(
      'Truque Ninja',
      'Espere 24 horas antes de comprar algo que você viu. Se ainda quiser, talvez valha a pena!',
      '🥷',
    ),
    EducationalTip(
      'Você Sabia?',
      'Ter um cofrinho em casa ajuda você a ver seu dinheiro crescendo todos os dias!',
      '🐷',
    ),
    EducationalTip(
      'Desafio da Semana',
      'Tente economizar o dinheiro do lanche de 3 dias e veja quanto juntou!',
      '🏆',
    ),
    EducationalTip(
      'Aprenda Jogando',
      'Transforme economia em jogo: a cada R\$ 10 economizados, ganhe 1 ponto!',
      '🎮',
    ),
    EducationalTip(
      'Dica de Ouro',
      'Quando ganhar dinheiro, separe uma parte para economizar ANTES de gastar!',
      '🥇',
    ),
    EducationalTip(
      'Sabedoria Popular',
      'Dinheiro não dá em árvore, mas você pode fazer ele crescer com paciência!',
      '🌱',
    ),
    EducationalTip(
      'Aprenda Cedo',
      'Quanto mais cedo você aprende a economizar, mais sonhos você vai realizar!',
      '🚀',
    ),
    EducationalTip(
      'Você Sabia?',
      'Anotar seus gastos é como ter um mapa do tesouro do seu dinheiro!',
      '🗺️',
    ),
    EducationalTip(
      'Desafio Master',
      'Passe um dia inteiro sem gastar nada. Você consegue?',
      '🎖️',
    ),
    EducationalTip(
      'Dica Incrível',
      'Troque guloseimas por frutas 2x na semana e economize!',
      '🍎',
    ),
    EducationalTip(
      'Aprenda Sempre',
      'Pergunte aos seus pais como eles economizam. Você vai aprender muito!',
      '👨‍👩‍👧',
    ),
    EducationalTip(
      'Pensamento',
      'Economizar não é deixar de comprar, é comprar o que realmente importa!',
      '✨',
    ),
    EducationalTip(
      'Planejamento Inteligente',
      'Faça uma lista com tudo que você quer comprar e coloque números de 1 a 10 do mais importante para o menos. Assim você economiza para o que realmente importa primeiro!',
      '📊',
    ),
    EducationalTip(
      'Cuide do que é Seu',
      'Quando você cuida bem dos seus brinquedos, roupas e materiais escolares, eles duram muito mais tempo e você não precisa pedir para comprar novos!',
      '🛡️',
    ),
    EducationalTip(
      'Economia Compartilhada',
      'Que tal combinar com seus amigos de trocar brinquedos ou jogos por um tempo? Assim todos experimentam coisas novas sem precisar gastar dinheiro!',
      '🤝',
    ),
    EducationalTip(
      'Seja Criativo',
      'Presentes feitos por você são especiais e únicos! Desenhos, cartões, pulseiras... Use sua criatividade e economize dinheiro fazendo presentes com amor!',
      '🎨',
    ),
    EducationalTip(
      'Controle Semanal',
      'No final de cada semana, anote quanto dinheiro você conseguiu guardar. Você vai se surpreender como pequenas economias viram grandes conquistas!',
      '📈',
    ),
    EducationalTip(
      'O Poder da Espera',
      'Quando você espera alguns dias antes de comprar algo, descobre se realmente quer ou se era só vontade do momento. Isso te ajuda a economizar muito!',
      '⏰',
    ),
    EducationalTip(
      'Organize Seu Dinheiro',
      'Use três potes ou cofrinhos: um para gastar no que você quiser, um para economizar para seus sonhos e um para ajudar quem precisa. É uma forma perfeita de aprender!',
      '🏺',
    ),
    EducationalTip(
      'Preciso ou Quero?',
      'Sempre que quiser comprar algo, pergunte: é algo que eu PRECISO agora ou só QUERO? Essa pergunta mágica ajuda você a economizar para o que é realmente importante!',
      '🎯',
    ),
    EducationalTip(
      'Crescendo com Responsabilidade',
      'Cada vez que você guarda dinheiro ao invés de gastar tudo, está mostrando que está crescendo e aprendendo a ser responsável com suas escolhas!',
      '🌟',
    ),
    EducationalTip(
      'Agradeça Sempre',
      'Antes de pedir algo novo, olhe tudo que você já tem e agradeça. Você vai perceber que já tem muitas coisas legais e talvez não precise comprar mais agora!',
      '🙏',
    ),
    EducationalTip(
      'Construa Seu Futuro',
      'Cada moedinha que você guarda hoje é como colocar um tijolinho na construção da sua casa dos sonhos. Com paciência e dedicação, você realiza tudo!',
      '🏗️',
    ),
    EducationalTip(
      'Sabedoria dos Avós',
      'Seus avós viveram em tempos diferentes e aprenderam muito sobre economizar. Peça para eles contarem histórias de quando eram jovens, você vai aprender demais!',
      '👴',
    ),
    EducationalTip(
      'Ajude o Planeta',
      'Sabia que quando você compra menos coisas, também está ajudando o meio ambiente? Menos lixo, menos poluição e um planeta mais feliz para todos!',
      '🌍',
    ),
    EducationalTip(
      'Visualize Seus Sonhos',
      'Tire uma foto ou recorte uma imagem do que você está economizando para comprar e cole no seu cofrinho. Assim você lembra todos os dias do seu objetivo!',
      '🖼️',
    ),
    EducationalTip(
      'Celebre Suas Conquistas',
      'Quando você alcançar uma meta de economia, comemore! Você pode fazer um desenho, dançar, ou contar para sua família. Você merece por todo esforço que fez!',
      '🎉',
    ),
    EducationalTip(
      'Errar Faz Parte',
      'Se você gastou mais do que planejava, não tem problema! O importante é entender o que aconteceu e tentar fazer diferente da próxima vez. Todo mundo erra e aprende!',
      '💪',
    ),
    EducationalTip(
      'Família Unida',
      'Converse com seus pais e irmãos sobre economia. Vocês podem criar desafios juntos, como ver quem economiza mais água ou energia. Juntos é mais divertido!',
      '👨‍👩‍👧‍👦',
    ),
    EducationalTip(
      'Faça Seu Dinheiro Crescer',
      'Dinheiro parado no cofrinho não aumenta sozinho. Pergunte aos seus pais sobre poupança e como o dinheiro pode crescer um pouquinho todo mês. É mágico!',
      '💰',
    ),
    EducationalTip(
      'Economizar é Divertido',
      'Transforme economia em um jogo! A cada R\$ 5 economizados você ganha pontos. Quando chegar a 100 pontos, faça algo especial que não custa dinheiro, como um piquenique!',
      '🎪',
    ),
    EducationalTip(
      'Prepare-se para Emergências',
      'Sempre guarde um dinheirinho extra para imprevistos, como quando você quebra algo sem querer ou precisa comprar algo urgente. Ter essa reserva te deixa mais tranquilo!',
      '🚨',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _subscribeGoalsRealtime();
    // Testar conexão na inicialização (apenas em debug)
    if (kDebugMode) {
      _testConnection();
    }
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await initChildMoneyNotifications();
      await Future.wait([
        _loadUserName(),
        _loadEarnedPoints(),
        _loadBalance(),
        _loadGoal(),
        _loadClaimContext(),
      ]);
    } catch (e) {
      debugLogDataLoad('Erro ao inicializar dados', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _subscribeGoalsRealtime() {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _balanceChannel = supabase
          .channel('public:children:balance:${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'children',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: user.id,
            ),
            callback: (payload) {
              // Usar o payload em tempo real para notificar na hora (não depender de nova consulta)
              try {
                final newRecord = payload.newRecord;
                final newBalance =
                    (newRecord['balance'] as num?)?.toDouble() ?? 0.0;
                if (mounted) {
                  setState(() {
                    currentBalance = newBalance;
                    _balanceLoadFailed = false;
                  });
                  checkAndNotifyBalanceIncrease(newBalance);
                }
              } catch (_) {}
              _loadBalance();
            },
          )
          .subscribe();

      _customMissionsChannel = supabase
          .channel('public:custom_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'custom_missions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (_) {
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'Nova missão adicionada! 🎯',
                body: 'Seu responsável criou uma missão para você.',
              );
            },
          )
          .subscribe();

      _dailyMissionsChannel = supabase
          .channel('public:daily_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'daily_missions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (_) {
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
                title: 'Missão do dia recebida! ✅',
                body: 'Você recebeu uma nova missão diária.',
              );
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
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
                title: 'Nova conquista disponível! 🏆',
                body: 'Seu responsável adicionou uma nova conquista.',
              );
            },
          )
          .subscribe();

      _goalsChannel = supabase
          .channel('public:goals:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) {
              _loadGoal();
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3,
                title: 'Nova meta criada! 🚀',
                body: 'Seu responsável adicionou uma nova meta.',
              );
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) => _loadGoal(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) => _loadGoal(),
          )
          .subscribe();
    } catch (e) {
      debugLogDataLoad('Erro ao assinar realtime', e);
    }
  }

  @override
  void dispose() {
    try {
      if (_balanceChannel != null) {
        Supabase.instance.client.removeChannel(_balanceChannel!);
      }
      if (_customMissionsChannel != null) {
        Supabase.instance.client.removeChannel(_customMissionsChannel!);
      }
      if (_dailyMissionsChannel != null) {
        Supabase.instance.client.removeChannel(_dailyMissionsChannel!);
      }
      if (_achievementsChannel != null) {
        Supabase.instance.client.removeChannel(_achievementsChannel!);
      }
      if (_goalsChannel != null) {
        Supabase.instance.client.removeChannel(_goalsChannel!);
      }
    } catch (_) {}
    super.dispose();
  }

  Future<void> _testConnection() async {
    try {
      debugPrint('🧪 Iniciando teste de conexão com Supabase...');
      final results = await SupabaseTest.testConnection();
      debugPrint('📊 Resultados do teste:');
      results.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    } catch (e) {
      debugLogDataLoad('Teste de conexão Supabase', e);
    }
  }

  Future<void> _loadUserName() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      String? name;

      if (user != null) {
        debugPrint('🔍 Buscando nome para usuário: ${user.id}');

        // 1) Buscar na tabela children pelo id do usuário autenticado
        try {
          final childRow = await supabase
              .from('children')
              .select('nome')
              .eq('id', user.id)
              .maybeSingle();

          debugPrint(
            '📊 Resultado da busca em children: ${childRow != null ? "encontrado" : "não encontrado"}',
          );

          if (childRow != null && childRow['nome'] != null) {
            name = childRow['nome'] as String?;
            debugPrint('✅ Nome encontrado na tabela children: $name');
          } else {
            debugPrint(
              '⚠️ Nome não encontrado na tabela children, tentando fallbacks...',
            );
          }
        } catch (e) {
          if (isNetworkFailure(e)) {
            debugLogDataLoad('Busca nome em children', e);
          } else {
            debugPrint('❌ Erro ao buscar na tabela children: $e');
            if (e is PostgrestException) {
              debugPrint('   Código: ${e.code}');
              debugPrint('   Mensagem: ${e.message}');
              debugPrint('   Detalhes: ${e.details}');
            }
          }
        }

        // 2) Fallback: metadata do usuário (caso exista)
        if (name == null || name.trim().isEmpty) {
          final meta = user.userMetadata ?? {};
          name =
              (meta['name'] ?? meta['full_name'] ?? meta['username'])
                  as String?;
          if (name != null) {
            debugPrint('✅ Nome encontrado no metadata: $name');
          }
        }

        // 3) Fallback: prefixo do email
        if (name == null || name.trim().isEmpty) {
          name = user.email?.split('@').first;
          if (name != null) {
            debugPrint('✅ Usando prefixo do email: $name');
          }
        }
      } else {
        debugPrint('⚠️ Nenhum usuário autenticado');
      }

      // 4) Fallback: valor salvo localmente (se existir)
      if (name == null || name.trim().isEmpty) {
        name = (await SharedPreferences.getInstance()).getString('user_name');
        if (name != null) {
          debugPrint('✅ Nome encontrado no SharedPreferences: $name');
        }
      }

      setState(() {
        userName = (name?.trim().isNotEmpty == true) ? name!.trim() : 'Usuário';
        debugPrint('👤 Nome final definido: $userName');
      });
    } catch (e, stackTrace) {
      debugLogDataLoad('Erro ao carregar nome do usuário', e, stackTrace);
      setState(() {
        userName = 'Usuário';
      });
    }
  }

  Future<void> _loadEarnedPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _earnedMissionPoints = prefs.getInt('missions_earned_points') ?? 0;
    });
  }

  bool get _hasRealSiblings => _realSiblings.isNotEmpty;

  double get _currentWeightedScore {
    final completedAchievements = achievements
        .where((a) => a['isCompleted'] == true)
        .length
        .toDouble();
    final score = _earnedMissionPoints.toDouble() + (completedAchievements * 5.0);
    return score <= 0 ? 1.0 : score;
  }

  List<double> get _otherSiblingsScores =>
      List<double>.filled(_realSiblings.length, 1.0);

  List<String> get _otherSiblingsNames => _realSiblings
      .map((s) => (s['nome'] as String?)?.trim())
      .whereType<String>()
      .where((n) => n.isNotEmpty)
      .toList();

  Future<void> _loadClaimContext() async {
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
    } catch (e) {
      debugLogDataLoad('Contexto de resgate', e);
      if (!mounted) return;
      setState(() => _isClaimContextLoading = false);
    }
  }

  Future<void> _refreshData() async {
    try {
      // Recarregar todos os dados
      await Future.wait([
        _loadUserName(),
        _loadEarnedPoints(),
        _loadBalance(),
        _loadGoal(),
        _loadClaimContext(),
      ]);
    } catch (e) {
      debugLogDataLoad('Atualizar dados (refresh)', e);
    }
  }

  Future<void> _loadBalance() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          currentBalance = 0.0;
          _balanceLoadFailed = true;
          _weekIncomeTotal = 0.0;
        });
        return;
      }
      final row = await supabase
          .from('children')
          .select('balance')
          .eq('id', user.id)
          .maybeSingle();
      final bal = (row?['balance'] as num?)?.toDouble() ?? 0.0;

      final weekStart = DateTime.now().subtract(const Duration(days: 7));
      double weekIn = 0.0;
      try {
        final tRows = await supabase
            .from('transactions')
            .select('amount, type, status')
            .eq('child_id', user.id)
            .gte('date', weekStart.toIso8601String());
        for (final r in tRows) {
          final type = (r['type'] ?? '').toString();
          if (!['income', 'allowance', 'reward'].contains(type)) continue;
          final st = (r['status'] ?? '').toString();
          if (st.isNotEmpty &&
              st != 'approved' &&
              st != 'completed') {
            continue;
          }
          weekIn += (r['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        debugLogDataLoad('Entradas da semana', e);
      }

      setState(() {
        currentBalance = bal;
        _balanceLoadFailed = false;
        _weekIncomeTotal = weekIn;
      });
      await checkAndNotifyBalanceIncrease(bal);

      // Sincronizar meta com o novo balance
      if (hasActiveGoal) {
        final goalRow = await supabase
            .from('goals')
            .select('id')
            .eq('child_id', user.id)
            .eq('status', 'ongoing')
            .maybeSingle();
        if (goalRow != null) {
          await _syncGoalWithBalance(goalRow['id'] as String);
          // Recarregar meta para atualizar a UI
          await _loadGoal();
        }
      }
    } catch (e) {
      debugLogDataLoad('Carregar saldo', e);
      setState(() => _balanceLoadFailed = true);
    }
  }

  Future<void> _syncGoalWithBalance(String goalId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Buscar saldo do cofrinho
      final childRow = await supabase
          .from('children')
          .select('balance')
          .eq('id', user.id)
          .maybeSingle();
      final balance = (childRow?['balance'] as num?)?.toDouble() ?? 0.0;

      // Buscar meta atual
      final goalRow = await supabase
          .from('goals')
          .select('target_amount, status')
          .eq('id', goalId)
          .maybeSingle();

      if (goalRow == null) return;

      final target = (goalRow['target_amount'] as num).toDouble();
      final status = goalRow['status'] as String;

      // Se já está concluída, não atualizar
      if (status == 'completed') return;

      final newAmount = balance.clamp(0.0, target);

      // Atualizar current_amount para refletir o cofrinho
      await supabase
          .from('goals')
          .update({'current_amount': newAmount})
          .eq('id', goalId)
          .eq('child_id', user.id);

      // Se atingiu ou superou o alvo, marcar como concluída
      if (balance >= target) {
        await supabase
            .from('goals')
            .update({
              'status': 'completed',
              'current_amount': target,
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', goalId)
            .eq('child_id', user.id);
      }
    } catch (e) {
      debugLogDataLoad('Sincronizar meta com saldo', e);
    }
  }

  Future<void> _loadGoal() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('❌ Usuário não autenticado ao carregar meta');
        setState(() {
          hasActiveGoal = false;
        });
        return;
      }

      final goalData = await supabase
          .from('goals')
          .select('*')
          .eq('child_id', user.id)
          .eq('status', 'ongoing')
          .maybeSingle();

      if (goalData != null) {
        // Sincronizar meta com cofrinho antes de exibir
        await _syncGoalWithBalance(goalData['id'] as String);

        // Recarregar meta atualizada
        final updatedGoal = await supabase
            .from('goals')
            .select('*')
            .eq('id', goalData['id'] as String)
            .maybeSingle();

        if (updatedGoal != null) {
          setState(() {
            goalName = updatedGoal['name'] as String;
            goalEmoji = updatedGoal['emoji'] as String? ?? '🎯';
            savingsGoal = (updatedGoal['target_amount'] as num).toDouble();
            final current = (updatedGoal['current_amount'] as num).toDouble();
            goalCurrentAmount = current > savingsGoal ? savingsGoal : current;
            hasActiveGoal = true;
          });
          debugPrint('✅ Meta carregada e sincronizada na homepage: $goalName');
        } else {
          setState(() {
            goalName = goalData['name'] as String;
            goalEmoji = goalData['emoji'] as String? ?? '🎯';
            savingsGoal = (goalData['target_amount'] as num).toDouble();
            final current = (goalData['current_amount'] as num).toDouble();
            goalCurrentAmount = current > savingsGoal ? savingsGoal : current;
            hasActiveGoal = true;
          });
          debugPrint('✅ Meta carregada na homepage: $goalName');
        }
      } else {
        // Se não há meta em andamento, mostrar a última meta concluída
        final lastCompleted = await supabase
            .from('goals')
            .select('*')
            .eq('child_id', user.id)
            .eq('status', 'completed')
            .order('completed_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastCompleted != null) {
          final target = (lastCompleted['target_amount'] as num).toDouble();
          setState(() {
            goalName = lastCompleted['name'] as String;
            goalEmoji = lastCompleted['emoji'] as String? ?? '🎯';
            savingsGoal = target;
            goalCurrentAmount = target; // meta concluída nunca excede o alvo
            hasActiveGoal = true; // Exibir cartão com status de concluída
          });
          debugPrint(
            'ℹ️ Exibindo última meta concluída na homepage: $goalName',
          );
        } else {
          setState(() {
            hasActiveGoal = false;
            goalName = '';
            goalEmoji = '🎯';
            savingsGoal = 0.0;
            goalCurrentAmount = 0.0;
          });
          debugPrint('ℹ️ Nenhuma meta encontrada para exibir na homepage');
        }
      }
    } catch (e) {
      debugLogDataLoad('Carregar meta na homepage', e);
      setState(() {
        hasActiveGoal = false;
      });
    }
  }

  void _nextTip() {
    setState(() {
      currentTipIndex = (currentTipIndex + 1) % educationalTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const ChildHomeSkeleton()
            : BrandedRefreshIndicator(
                onRefresh: _refreshData,
                color: theme.colorScheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      _buildSimpleHeader(screenWidth, isSmallScreen)
                          .animate()
                          .fadeIn(duration: 220.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      _buildBalanceCard(screenWidth, isSmallScreen)
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 260.ms)
                          .slideY(begin: 0.03, end: 0, curve: Curves.easeOut),
                      (hasActiveGoal
                              ? _buildSavingsGoal(screenWidth, isSmallScreen)
                              : _buildEmptyGoalCard(screenWidth, isSmallScreen))
                          .animate()
                          .fadeIn(delay: 140.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      _buildQuickActionsInter(screenWidth, isSmallScreen)
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      _buildEducationSection(screenWidth, isSmallScreen)
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      _buildAchievementsImproved(screenWidth, isSmallScreen)
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSimpleHeader(double screenWidth, bool isSmallScreen) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Olá, ',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            primary,
                            const Color(AppConstants.purple),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  'Como estão suas finanças hoje?',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            child: CachedAvatar(
              imageUrl:
                  'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
              size: isSmallScreen ? 50 : 56,
              borderColor: primary,
              borderWidth: 2,
              fallbackIcon: Icons.person_rounded,
              fallbackIconColor: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double screenWidth, bool isSmallScreen) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _balanceLoadFailed ? () => _loadBalance() : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 22 : 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E40AF).withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meu Cofrinho',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 17 : 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🐷',
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _balanceLoadFailed
                    ? '—'
                    : 'R\$ ${currentBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 38 : 44,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (_balanceLoadFailed) ...[
                const SizedBox(height: 8),
                Text(
                  'Não foi possível carregar o saldo. Toque aqui para tentar de novo.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.35,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                if (_weekIncomeTotal > 0)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '+${AppFormatters.formatCurrency(_weekIncomeTotal)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'entradas nos últimos 7 dias',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.88),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Nenhuma entrada registrada nos últimos 7 dias',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsGoal(double screenWidth, bool isSmallScreen) {
    // Usar valor reservado da meta (goalCurrentAmount) e nunca exceder o alvo
    final cappedTarget = savingsGoal < 0 ? 0.0 : savingsGoal;
    final contributed = goalCurrentAmount.clamp(0.0, cappedTarget);
    final progress = cappedTarget > 0 ? contributed / cappedTarget : 0.0;
    final remaining = cappedTarget - contributed;
    final progressPercent = (progress * 100).clamp(0, 100).toInt();
    final isCompleted = progress >= 1.0;

    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
      padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXLarge),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF475569)
              : const Color(AppConstants.borderLight),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [
                            const Color(AppConstants.successGreen).withValues(alpha: 0.15),
                            const Color(AppConstants.successGreen).withValues(alpha: 0.05),
                          ]
                        : [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Text(
                  goalEmoji,
                  style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalName,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 17 : 19,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(AppConstants.successGreen).withValues(alpha: 0.12)
                            : theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleted ? 'Meta concluída' : 'Em progresso',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isCompleted
                              ? const Color(AppConstants.successGreen)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(AppConstants.successGreen).withValues(alpha: 0.12)
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$progressPercent%',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(AppConstants.successGreen)
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${contributed.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'R\$ ${savingsGoal.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF475569)
                          : const Color(AppConstants.borderLight),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [
                                  const Color(AppConstants.successGreen),
                                  const Color(0xFF059669),
                                ]
                              : [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted
                                    ? const Color(AppConstants.successGreen)
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : const Color(AppConstants.backgroundGray),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF475569)
                          : const Color(AppConstants.borderLight),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            size: 16,
                            color: Color(AppConstants.successGreen),
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              'Economizado',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF94A3B8)
                                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        _balanceLoadFailed
                            ? '—'
                            : 'R\$ ${currentBalance.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : const Color(AppConstants.backgroundGray),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF475569)
                          : const Color(AppConstants.borderLight),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            remaining > 0
                                ? Icons.trending_up_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: remaining > 0
                                ? const Color(AppConstants.warningOrange)
                                : const Color(AppConstants.successGreen),
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              remaining > 0 ? 'Falta' : 'Excedente',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF94A3B8)
                                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        'R\$ ${remaining.abs().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGoalCard(double screenWidth, bool isSmallScreen) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewGoalScreen()),
        );

        if (result != null) {
          // Recarregar meta do banco após criar nova meta
          await _loadGoal();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Nova meta criada! 🎯',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
            );
          }
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Container(
            margin: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
            padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingLarge : AppConstants.spacingXLarge),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF475569)
                    : const Color(AppConstants.borderLight),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(AppConstants.purple).withValues(alpha: 0.15),
                            const Color(AppConstants.purple).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      child: Text(
                        '🎯',
                        style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sem metas ainda',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 17 : 19,
                              fontWeight: FontWeight.w600,
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFFCBD5E1)
                                  : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.6),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.purple).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Crie sua primeira meta',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(AppConstants.purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.purple).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '0%',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(AppConstants.purple).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ 0,00',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF94A3B8)
                                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          'R\$ 0,00',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF94A3B8)
                                : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF475569)
                                : const Color(AppConstants.borderLight),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.0,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF1E293B)
                              : const Color(AppConstants.backgroundGray),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF475569)
                                : const Color(AppConstants.borderLight),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.savings_outlined,
                                  size: 16,
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF94A3B8)
                                      : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                ),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    'Economizado',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFF94A3B8)
                                          : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              'R\$ 0,00',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFFCBD5E1)
                                    : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF1E293B)
                              : const Color(AppConstants.backgroundGray),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF475569)
                                : const Color(AppConstants.borderLight),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 16,
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF94A3B8)
                                      : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                ),
                                const Gap(6),
                                Expanded(
                                  child: Text(
                                    'Falta',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.brightness == Brightness.dark
                                          ? const Color(0xFF94A3B8)
                                          : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              'R\$ 0,00',
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFFCBD5E1)
                                    : theme.textTheme.titleLarge?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsInter(double screenWidth, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF3B82F6),
                      const Color(0xFF8B5CF6),
                    ] // Azul → Roxo como no site
                  : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
            ).createShader(bounds),
            child: Text(
              'O que você quer fazer?',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyMissionsScreen(),
                          ),
                        );
                      },
                      child: _buildActionCardInter(
                        'Missões Diárias',
                        'Complete desafios e ganhe pontos',
                        Icons.emoji_events_outlined,
                        const Color(0xFFF59E0B),
                        isSmallScreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewGoalScreen(),
                          ),
                        );

                        if (result != null) {
                          // Recarregar meta do banco após criar nova meta
                          await _loadGoal();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Nova meta criada! 🎯',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF8B5CF6),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: _buildActionCardInter(
                        'Nova Meta',
                        'Defina um novo objetivo',
                        Icons.flag_outlined,
                        const Color(0xFF8B5CF6),
                        isSmallScreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RequestMoneyScreen(),
                          ),
                        );
                      },
                      child: _buildActionCardInter(
                        'Pedir Dinheiro',
                        'Peça dinheiro ao responsável',
                        Icons.request_quote_rounded,
                        const Color(0xFF10B981),
                        isSmallScreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_isClaimContextLoading) return;
                        if (!_hasRealSiblings) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Não há irmãos cadastrados pelo mesmo responsável.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (_activeDistributionId == null ||
                            _activeDistributionAmount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sem valor ativo para resgate no momento.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (_alreadyClaimedCurrentDistribution) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Você já retirou sua parte desta distribuição.',
                              ),
                            ),
                          );
                          return;
                        }

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClaimShareScreen(
                              distributionId: _activeDistributionId!,
                              childId: _currentChildId,
                              totalAmount: _activeDistributionAmount,
                              currentChildScore: _currentWeightedScore,
                              otherChildrenScores: _otherSiblingsScores,
                              otherChildrenNames: _otherSiblingsNames,
                              currentChildName: _currentChildName,
                            ),
                          ),
                        );
                        if (result is Map && result['claimed'] == true) {
                          final claimedAmount =
                              ((result['amount'] ?? 0.0) as double);
                          await _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Você retirou R\$ ${claimedAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      child: _buildActionCardInter(
                        'Retirar Minha Parte',
                        _isClaimContextLoading
                            ? 'Carregando distribuição...'
                            : (!_hasRealSiblings
                                  ? 'Inativo: sem irmãos cadastrados'
                                  : (_alreadyClaimedCurrentDistribution
                                        ? 'Você já retirou nesta distribuição'
                                        : (_activeDistributionId == null
                                              ? 'Sem distribuição ativa'
                                              : 'Resgate sua parte do valor do responsável'))),
                        Icons.payments_rounded,
                        const Color(0xFF10B981),
                        isSmallScreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardInter(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF475569)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(double screenWidth, bool isSmallScreen) {
    final currentTip = educationalTips[currentTipIndex];

    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFFFF8C42),
                      const Color(0xFF10B981),
                    ] // Laranja → Verde como no site
                  : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
            ).createShader(bounds),
            child: Text(
              'Aprenda Brincando',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey<int>(currentTipIndex),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: isSmallScreen ? 200 : 220),
              padding: EdgeInsets.all(isSmallScreen ? 24.0 : 28.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF7C3AED),
                    Color(0xFF6D28D9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          currentTip.emoji,
                          style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTip.category,
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 15 : 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Dica ${currentTipIndex + 1} de ${educationalTips.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentTip.content,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _nextTip,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 22,
                      ),
                      label: Text(
                        'Próxima Dica',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8B5CF6),
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsImproved(double screenWidth, bool isSmallScreen) {
    final completedAchievements = achievements
        .where((a) => a['isCompleted'] == true)
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFF10B981),
                          const Color(0xFF3B82F6),
                        ] // Verde → Azul como no site
                      : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
                ).createShader(bounds),
                child: Text(
                  'Suas Conquistas',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$completedAchievements de ${achievements.length}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF475569)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: achievements.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 16),
                    _buildAchievementItem(
                      achievement['emoji'],
                      achievement['title'],
                      achievement['description'],
                      achievement['isCompleted'],
                      isSmallScreen,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(
    String emoji,
    String title,
    String description,
    bool isCompleted,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 48 : 56,
          height: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? Theme.of(context).textTheme.titleMedium?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
      ],
    );
  }
}

class EducationalTip {
  final String category;
  final String content;
  final String emoji;

  EducationalTip(this.category, this.content, this.emoji);
}
