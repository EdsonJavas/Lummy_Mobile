// Prévia das telas novas da criança para o PIXEL PERFECT (VINGADORES).
//
// Monta cada tela com os widgets reais do app e dados de exemplo iguais aos
// dos mockups, sem Supabase. A tela vem da URL:
//   ?tela=Main | Home-rolagem | Anotar-gasto | Drawer-crianca | Gastos-mes |
//         Gastos-lista | Metas-atual | Metas-rolagem
//   &tema=lummy | indigo | petroleo   (opcional; padrão lummy)
//   &escuro=1                         (opcional; modo escuro)
//
// Compilar (caminho sem acento, ver MISSAO\pp\fotos-app.mjs):
//   flutter build web -t tool/pp_preview/main.dart --no-pub -o build/pp_web
//
// Quando a tela fica pronta, escreve no console "PPDUMP:{json}" (medidas de
// textos, ícones e caixas) e depois "PP_READY".
//
// Não é código de produção.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/app_theme.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/drawer/child_drawer.dart';
import 'package:lummy/screens/child/widgets/home/home_b_mission_row.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheet_frame.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'pp_dados.dart';
import 'pp_medir.dart';
import 'pp_telas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final params = Uri.base.queryParameters;
  final tela = params['tela'] ?? 'Main';
  final cor = ChildThemeColor.values.firstWhere(
    (c) => c.name == params['tema'],
    orElse: () => ChildThemeColor.lummy,
  );
  await _carregarFontes();
  runApp(PpApp(
    tela: tela,
    cor: cor,
    corrigido: params['corrigido'] == '1',
    escuro: params['escuro'] == '1',
  ));
}

/// Baixa Poppins e Fredoka antes da primeira pintura (google_fonts em runtime).
Future<void> _carregarFontes() async {
  final estilos = <TextStyle>[
    for (final w in const [FontWeight.w400, FontWeight.w500, FontWeight.w600, FontWeight.w700])
      LummyFonts.body(fontWeight: w),
    for (final w in const [FontWeight.w500, FontWeight.w600, FontWeight.w700])
      LummyFonts.rounded(fontWeight: w),
  ];
  try {
    await GoogleFonts.pendingFonts(estilos).timeout(const Duration(seconds: 30));
  } catch (e) {
    print('PP_AVISO fontes: $e');
  }
}

/// Tema claro com o texto padrão do Material sem letterSpacing 0.25 e com
/// altura 1.5: é o efeito que a correção proposta em v1_text.dart teria.
ThemeData _temaCorrigido() {
  final base = AppTheme.lightTheme;
  final corpo = base.textTheme.bodyMedium!;
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      bodyMedium: corpo.copyWith(letterSpacing: 0, height: 1.5),
    ),
  );
}

class PpApp extends StatelessWidget {
  const PpApp({
    super.key,
    required this.tela,
    required this.cor,
    this.corrigido = false,
    this.escuro = false,
  });

  final String tela;

  /// Simula a correção proposta para LummyText (sem espaçamento de letra
  /// herdado e altura "normal" 1.5 do Poppins).
  final bool corrigido;
  final ChildThemeColor cor;

  /// Modo escuro do app (tema escuro do MaterialApp).
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChildThemeColorController>(create: (_) => PpCores(cor)),
        ChangeNotifierProvider<ChildProfileController>(create: (_) => PpPerfil()),
        ChangeNotifierProvider(create: (_) => ChildDataChanges()),
      ],
      child: MaterialApp(
        title: 'PP $tela',
        debugShowCheckedModeBanner: false,
        theme: escuro ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: PpCasca(tela: tela, corrigido: corrigido),
      ),
    );
  }
}

/// Cópia da casca `main_navigation.dart` (build): tema do app, ChildShellScope,
/// Scaffold no fundo do tema com o menu lateral e o véu, degradê e cápsula por cima.
class PpCasca extends StatefulWidget {
  const PpCasca({super.key, required this.tela, this.corrigido = false});

  final String tela;
  final bool corrigido;

  @override
  State<PpCasca> createState() => _PpCascaState();
}

class _PpCascaState extends State<PpCasca> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controle = ScrollController();

  int get _aba => switch (widget.tela) {
        'Gastos-mes' || 'Gastos-lista' => ChildTabs.gastos,
        'Metas-atual' || 'Metas-rolagem' => ChildTabs.metas,
        _ => ChildTabs.inicio,
      };

  /// As telas "rolada" do mockup vão além do fim real da rolagem; um espaço
  /// em branco DEPOIS do conteúdo deixa alinhar a âncora sem mexer no resto.
  double get _extraFim => widget.tela.endsWith('rolagem') || widget.tela == 'Gastos-lista'
      ? 900
      : 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preparar());
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  Future<void> _preparar() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    switch (widget.tela) {
      case 'Home-rolagem':
        _rolarAte(
          (w) => w is HomeBMissionRow && w.missao.titulo == 'Conferir o saldo da semana',
          8,
        );
      case 'Gastos-lista':
        _rolarAte((w) => w is SectionTitle && w.titulo == 'Precisava ou queria?', 12);
      case 'Metas-rolagem':
        _rolarAte((w) => w is Text && w.data == 'Três quartos do caminho', 12);
      case 'Drawer-crianca':
        _scaffoldKey.currentState?.openDrawer();
      case 'Anotar-gasto':
        unawaited(
          showMoneySheet(
            _scaffoldKey.currentContext ?? context,
            builder: (_) => const PpPainelGasto(),
          ),
        );
    }
    // Animações de entrada, painel/menu abrindo e fonte de emoji.
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    print('PPDUMP:${medirTela(widget.tela)}');
    print('PP_READY');
  }

  void _rolarAte(bool Function(Widget w) alvo, double topo) {
    Element? achado;
    void visitar(Element e) {
      if (achado != null) return;
      if (alvo(e.widget)) {
        achado = e;
        return;
      }
      e.visitChildren(visitar);
    }

    context.visitChildElements(visitar);
    final ro = achado?.renderObject;
    if (ro is! RenderBox) {
      print('PP_AVISO âncora não encontrada em ${widget.tela}');
      return;
    }
    final y = ro.localToGlobal(Offset.zero).dy;
    _controle.jumpTo(_controle.offset + y - topo);
  }

  Widget _pagina() {
    if (widget.tela == 'Texto') return const PpTexto();
    switch (_aba) {
      case ChildTabs.gastos:
        return PpGastos(controle: _controle, extraFim: _extraFim);
      case ChildTabs.metas:
        return PpMetas(controle: _controle, extraFim: _extraFim);
      default:
        return PpHome(controle: _controle, extraFim: _extraFim);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.cores.escuro ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Theme(
        data: widget.corrigido ? _temaCorrigido() : Theme.of(context),
        child: ChildShellScope(
          currentTab: _aba,
          openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          closeDrawer: () => _scaffoldKey.currentState?.closeDrawer(),
          goToTab: (_) {},
          afterDrawerClosed: (_) {},
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: context.cores.fundo,
            resizeToAvoidBottomInset: false,
            drawer: const ChildDrawer(),
            drawerScrimColor: context.cores.veu,
            drawerEnableOpenDragGesture: false,
            body: Stack(
              children: [
                Positioned.fill(child: _pagina()),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ChildBottomFade(),
                ),
                Positioned(
                  left: ChildBottomNavMetrics.capsuleSide,
                  right: ChildBottomNavMetrics.capsuleSide,
                  bottom: ChildBottomNavMetrics.capsuleBottom + inset,
                  child: ChildBottomNavCapsule(currentIndex: _aba, onTap: (_) {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
