import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/data/child/child_achievements_repository.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/daily_missions_screen.dart';
import 'package:lummy/screens/child/flows/child_logout_flow.dart';
import 'package:lummy/screens/child/notifications_screen.dart';
import 'package:lummy/screens/child/profile_page.dart';
import 'package:lummy/screens/child/request_money_screen.dart';
import 'package:lummy/screens/child/widgets/sheets/money_sheets.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'child_drawer_item.dart';
import 'child_drawer_theme_swatches.dart';

/// Menu lateral da criança (`Drawer-crianca.dc.html`).
///
/// CONTRATO (arquiteto): `MainNavigation` usa `const ChildDrawer()` como
/// `Scaffold.drawer`. O nome da classe e o construtor `const ChildDrawer({super.key})`
/// NÃO mudam.
///
/// O `Scaffold` monta este widget a cada abertura do menu, então os valores
/// "N de M" (missões e conquistas) são consultados no `initState` e aparecem
/// quando chegam. Sem dado (erro, sem rede, lista vazia) o valor fica
/// escondido: nada de número inventado (D7).
///
/// Segue o modo claro/escuro do app: as cores vêm de `context.cores`.
class ChildDrawer extends StatefulWidget {
  const ChildDrawer({super.key});

  /// Largura do painel no mockup.
  static const double largura = 320;

  /// Texto do rodapé. Manter igual ao pubspec (`version: 1.0.0`): o app não
  /// tem `package_info`, então este número precisa ser trocado à mão.
  static const String versaoDoApp = 'Lummy, versão 1.0';

  @override
  State<ChildDrawer> createState() => _ChildDrawerState();
}

class _ChildDrawerState extends State<ChildDrawer> {
  /// "2 de 5" das missões de hoje. Nulo = não mostrar.
  String? _missoes;

  /// "3 de 12" das conquistas. Nulo = não mostrar.
  String? _conquistas;

  @override
  void initState() {
    super.initState();
    _carregarMissoes();
    _carregarConquistas();
  }

  Future<void> _carregarMissoes() async {
    try {
      final lista = await ChildMissionsRepository().missoesDeHoje();
      if (!mounted || lista.isEmpty) return;
      final feitas = lista.where((m) => m.concluida).length;
      setState(() => _missoes = '$feitas de ${lista.length}');
    } catch (e) {
      appLog('⚠️ Menu lateral: missões de hoje indisponíveis: $e');
    }
  }

  Future<void> _carregarConquistas() async {
    try {
      final resultado = await ChildAchievementsRepository().listar();
      final total = resultado.totalPossivel;
      // Sem as conquistas ainda não ganhas no banco, o "de M" seria inventado.
      if (!mounted || total == null) return;
      setState(() => _conquistas = '${resultado.totalConquistadas} de $total');
    } catch (e) {
      appLog('⚠️ Menu lateral: conquistas indisponíveis: $e');
    }
  }

  // ── Ações ──
  //
  // Sempre por `afterDrawerClosed`: ele fecha o menu e entrega um contexto da
  // casca que continua montado (o deste widget some quando o menu fecha).

  void _depoisDeFechar(void Function(BuildContext shellContext) acao) {
    ChildShellScope.read(context)?.afterDrawerClosed(acao);
  }

  void _fechar() => ChildShellScope.read(context)?.closeDrawer();

  void _abrirTela(Widget tela) {
    _depoisDeFechar((ctx) {
      Navigator.of(ctx).push(MaterialPageRoute<void>(builder: (_) => tela));
    });
  }

  /// Perfil (também é onde ficam as conquistas e as configurações da criança).
  /// O nome pode ter sido editado lá: relê o perfil na volta.
  void _abrirPerfil() {
    _depoisDeFechar((ctx) async {
      await Navigator.of(ctx).push(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
      );
      if (!ctx.mounted) return;
      ctx.read<ChildProfileController>().refresh();
    });
  }

  /// Missões: concluir missão muda XP e nível, então avisa as abas na volta.
  void _abrirMissoes() {
    _depoisDeFechar((ctx) async {
      await Navigator.of(ctx).push(
        MaterialPageRoute<void>(builder: (_) => const DailyMissionsScreen()),
      );
      if (!ctx.mounted) return;
      ctx.read<ChildDataChanges>().avisar({ChildDataKind.missoes});
      ctx.read<ChildProfileController>().refresh();
    });
  }

  void _registrarGanho() {
    _depoisDeFechar((ctx) => showRegistrarGanhoSheet(ctx));
  }

  void _sair() => _depoisDeFechar(sairDaContaCrianca);

  @override
  Widget build(BuildContext context) {
    final tela = MediaQuery.sizeOf(context);
    final sistema = MediaQuery.viewPaddingOf(context);
    // 320 do mockup; em telas muito estreitas sobra uma faixa do véu para
    // fechar com um toque.
    final largura = math.min(ChildDrawer.largura, tela.width - 40);

    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Menu',
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: largura),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.cores.superficie,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: LummyShadows.drawer,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          20 + sistema.top,
                          20,
                          20 + sistema.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Topo(onFechar: _fechar),
                            _Identidade(onVerPerfil: _abrirPerfil),
                            _lista(),
                            const _CorDoApp(),
                            // `margin-top: auto`: o rodapé fica colado embaixo.
                            const Spacer(),
                            _Rodape(onSair: _sair),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// `<ul>`: `margin: 8px 0 0`, `padding: 8px 0 0`, borda de cima 1 `#EEF0F4`.
  Widget _lista() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.cores.linha)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChildDrawerItem(
            glyph: LummyGlyphs.listChecks,
            rotulo: 'Missões do dia',
            valor: _missoes,
            onTap: _abrirMissoes,
          ),
          ChildDrawerItem(
            glyph: LummyGlyphs.trophy,
            rotulo: 'Conquistas',
            valor: _conquistas,
            onTap: _abrirPerfil,
          ),
          ChildDrawerItem(
            glyph: LummyGlyphs.coins,
            rotulo: 'Pedir dinheiro',
            onTap: () => _abrirTela(const RequestMoneyScreen()),
          ),
          ChildDrawerItem(
            glyph: LummyGlyphs.handCoins,
            rotulo: 'Registrar dinheiro que ganhei',
            onTap: _registrarGanho,
          ),
          // A pílula "2 novas" do mockup não aparece: não há contador de
          // notificações não lidas (D7).
          ChildDrawerItem(
            glyph: LummyGlyphs.bell,
            rotulo: 'Notificações',
            onTap: () => _abrirTela(const NotificationsScreen()),
          ),
          ChildDrawerItem(
            glyph: LummyGlyphs.settings,
            rotulo: 'Configurações',
            onTap: _abrirPerfil,
          ),
        ],
      ),
    );
  }
}

/// Avatar 56 à esquerda e o "x" de fechar à direita.
class _Topo extends StatelessWidget {
  const _Topo({required this.onFechar});

  final VoidCallback onFechar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChildAvatar(size: 56, tappable: false),
        // `margin: -6px -10px 0 0` do mockup.
        Transform.translate(
          offset: const Offset(10, -6),
          child: Semantics(
            button: true,
            label: 'Fechar menu',
            excludeSemantics: true,
            child: InkWell(
              onTap: onFechar,
              customBorder: const CircleBorder(),
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
    );
  }
}

/// Nome, pílula do nível e "Ver meu perfil".
class _Identidade extends StatelessWidget {
  const _Identidade({required this.onVerPerfil});

  final VoidCallback onVerPerfil;

  @override
  Widget build(BuildContext context) {
    final perfil = ChildProfileController.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Vazio até o perfil carregar (a linha guarda a altura).
        Text(
          perfil.nome,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: LummyText.nomeMenu(context),
        ),
        const SizedBox(height: 6),
        // O "Exploradora" do mockup não aparece: não existe no banco (D7).
        SizedBox(
          height: 24,
          child: perfil.nivelConhecido
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [LevelPill(level: perfil.level)],
                )
              : null,
        ),
        const SizedBox(height: 6),
        ThemeLink(rotulo: 'Ver meu perfil', gap: 2, onTap: onVerPerfil),
      ],
    );
  }
}

/// Seção "Cor do app": `margin-top: 18px`, `padding-top: 16px`, borda de cima.
class _CorDoApp extends StatelessWidget {
  const _CorDoApp();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.cores.linha)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Cor do app', style: LummyText.pergunta(context)),
          ),
          const SizedBox(height: 12),
          const ChildThemeColorSwatches(),
        ],
      ),
    );
  }
}

/// Rodapé: "Sair da conta" e a versão.
class _Rodape extends StatelessWidget {
  const _Rodape({required this.onSair});

  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Respiro mínimo quando o conteúdo ocupa a tela toda e o menu rola.
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.cores.linha)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Semantics(
              button: true,
              child: InkWell(
                onTap: onSair,
                borderRadius: BorderRadius.circular(14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: LummyIcon(
                            LummyGlyphs.logOut,
                            size: 20,
                            color: context.cores.tintaApoio,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Sair da conta', style: LummyText.corpo(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ChildDrawer.versaoDoApp,
            style: LummyText.poppins(context, size: 12, color: context.cores.tintaApoio),
          ),
        ],
      ),
    );
  }
}
