import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Cores da área da criança que mudam com o modo claro/escuro.
///
/// O mockup do redesenho só tem a versão clara: os valores de [claro] são os
/// tokens dele (`LummyColors.ink900`, `surface100`...). O [escuro] é um azul
/// noite dessaturado, na mesma família da tinta `#0B1533`, para combinar com o
/// cartão espacial sem virar fundo colorido.
///
/// Registrada nos dois temas do app (`AppTheme.lightTheme` e `darkTheme`).
/// Numa tela:
/// ```dart
/// final cores = context.cores;
/// Container(color: cores.superficie);
/// Text('Oi', style: LummyText.apoio(context));
/// ```
///
/// Cores que NÃO mudam (continuam em `LummyColors`): branco sobre o tema ou
/// sobre o cartão espacial, verde de guardar, dourado do XP, cores do tema
/// usadas como fundo, sombras.
@immutable
class LummyCores extends ThemeExtension<LummyCores> {
  const LummyCores({
    required this.fundo,
    required this.superficie,
    required this.superficieNeutra,
    required this.superficieElevada,
    required this.linha,
    required this.tinta,
    required this.tintaApoio,
    required this.iconeApagado,
    required this.bordaPendente,
    required this.tracejado,
    required this.alca,
    required this.grafico,
    required this.veu,
    required this.dinheiro,
    required this.perigo,
    required this.contorno,
    required this.escuro,
  });

  /// Fundo das telas (branco no claro).
  final Color fundo;

  /// Cartões, painéis de baixo, menu lateral, cápsula do menu (branco no claro).
  final Color superficie;

  /// Superfície neutra: quadradinhos de ícone, campos, esqueleto (`surface100`).
  final Color superficieNeutra;

  /// Superfície acima da neutra: pílula escolhida do seletor (branco no
  /// claro).
  final Color superficieElevada;

  /// Linhas, trilhos e divisórias (`line100`).
  final Color linha;

  /// Texto principal (`ink900`).
  final Color tinta;

  /// Texto de apoio (`ink600`).
  final Color tintaApoio;

  /// Ícone apagado (`ink500`).
  final Color iconeApagado;

  /// Borda do círculo de missão pendente (`ink300`).
  final Color bordaPendente;

  /// Tracejados e parada futura da trilha (`ink200`).
  final Color tracejado;

  /// Alça do painel de baixo (`ink100`).
  final Color alca;

  /// Gráficos e números neutros (`chartInk`).
  final Color grafico;

  /// Véu atrás do painel de baixo e do menu lateral (`scrimInk`).
  final Color veu;

  /// Laranja do dinheiro como texto ou ícone (`orange600` no claro).
  final Color dinheiro;

  /// Ação destrutiva, como "Desistir da meta" (`danger700` no claro).
  final Color perigo;

  /// Contorno fino que separa cartões do fundo. Transparente no claro (lá a
  /// sombra separa); no escuro a sombra some e o contorno faz esse papel.
  final Color contorno;

  /// Se é a paleta do modo escuro.
  final bool escuro;

  static const claro = LummyCores(
    fundo: LummyColors.white,
    superficie: LummyColors.white,
    superficieNeutra: LummyColors.surface100,
    superficieElevada: LummyColors.white,
    linha: LummyColors.line100,
    tinta: LummyColors.ink900,
    tintaApoio: LummyColors.ink600,
    iconeApagado: LummyColors.ink500,
    bordaPendente: LummyColors.ink300,
    tracejado: LummyColors.ink200,
    alca: LummyColors.ink100,
    grafico: LummyColors.chartInk,
    veu: LummyColors.scrimInk,
    dinheiro: LummyColors.orange600,
    perigo: LummyColors.danger700,
    contorno: Color(0x00000000),
    escuro: false,
  );

  static const escuroPadrao = LummyCores(
    fundo: Color(0xFF0E1422),
    superficie: Color(0xFF172033),
    superficieNeutra: Color(0xFF1F2A3F),
    superficieElevada: Color(0xFF2E3A55),
    linha: Color(0xFF27324A),
    tinta: Color(0xFFEEF1F7),
    tintaApoio: Color(0xFFA3ACBF),
    iconeApagado: Color(0xFF8E97AB),
    bordaPendente: Color(0xFF56617A),
    tracejado: Color(0xFF414C64),
    alca: Color(0xFF414C64),
    grafico: Color(0xFFC5CCDB),
    veu: Color(0x99000000),
    dinheiro: Color(0xFFFB8B45),
    perigo: Color(0xFFF97066),
    contorno: Color(0x14FFFFFF),
    escuro: true,
  );

  /// A paleta do tema atual. Sem a extensão registrada (testes, prévias),
  /// escolhe pela claridade do tema.
  static LummyCores of(BuildContext context) {
    final tema = Theme.of(context);
    return tema.extension<LummyCores>() ??
        (tema.brightness == Brightness.dark ? escuroPadrao : claro);
  }

  /// Cor do tema (ou outra cor forte) usada como TEXTO ou ÍCONE sobre o fundo.
  /// No escuro clareia para manter o contraste; como fundo de botão, use a cor
  /// do tema direto.
  Color realce(Color cor) =>
      escuro ? Color.lerp(cor, LummyColors.white, 0.45)! : cor;

  /// Ícones das barras do sistema combinando com o [fundo].
  Brightness get brilhoDosIcones => escuro ? Brightness.light : Brightness.dark;

  @override
  LummyCores copyWith({
    Color? fundo,
    Color? superficie,
    Color? superficieNeutra,
    Color? superficieElevada,
    Color? linha,
    Color? tinta,
    Color? tintaApoio,
    Color? iconeApagado,
    Color? bordaPendente,
    Color? tracejado,
    Color? alca,
    Color? grafico,
    Color? veu,
    Color? dinheiro,
    Color? perigo,
    Color? contorno,
    bool? escuro,
  }) {
    return LummyCores(
      fundo: fundo ?? this.fundo,
      superficie: superficie ?? this.superficie,
      superficieNeutra: superficieNeutra ?? this.superficieNeutra,
      superficieElevada: superficieElevada ?? this.superficieElevada,
      linha: linha ?? this.linha,
      tinta: tinta ?? this.tinta,
      tintaApoio: tintaApoio ?? this.tintaApoio,
      iconeApagado: iconeApagado ?? this.iconeApagado,
      bordaPendente: bordaPendente ?? this.bordaPendente,
      tracejado: tracejado ?? this.tracejado,
      alca: alca ?? this.alca,
      grafico: grafico ?? this.grafico,
      veu: veu ?? this.veu,
      dinheiro: dinheiro ?? this.dinheiro,
      perigo: perigo ?? this.perigo,
      contorno: contorno ?? this.contorno,
      escuro: escuro ?? this.escuro,
    );
  }

  @override
  LummyCores lerp(ThemeExtension<LummyCores>? other, double t) {
    if (other is! LummyCores) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return LummyCores(
      fundo: m(fundo, other.fundo),
      superficie: m(superficie, other.superficie),
      superficieNeutra: m(superficieNeutra, other.superficieNeutra),
      superficieElevada: m(superficieElevada, other.superficieElevada),
      linha: m(linha, other.linha),
      tinta: m(tinta, other.tinta),
      tintaApoio: m(tintaApoio, other.tintaApoio),
      iconeApagado: m(iconeApagado, other.iconeApagado),
      bordaPendente: m(bordaPendente, other.bordaPendente),
      tracejado: m(tracejado, other.tracejado),
      alca: m(alca, other.alca),
      grafico: m(grafico, other.grafico),
      veu: m(veu, other.veu),
      dinheiro: m(dinheiro, other.dinheiro),
      perigo: m(perigo, other.perigo),
      contorno: m(contorno, other.contorno),
      escuro: t < 0.5 ? escuro : other.escuro,
    );
  }
}

/// Atalho: `context.cores`.
extension LummyCoresContext on BuildContext {
  LummyCores get cores => LummyCores.of(this);
}
