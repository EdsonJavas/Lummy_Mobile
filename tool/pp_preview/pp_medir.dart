// Medidas da tela montada (textos, ícones e caixas), em pixels lógicos, para
// comparar número a número com o mockup (scripts em MISSAO\pp\).
//
// Não é código de produção: só alimenta tool/pp_preview/main.dart.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:lummy/screens/child/widgets/v1/lummy_icon.dart';

String _hex(Color? c) {
  if (c == null) return '';
  return '#${c.toARGB32().toRadixString(16).padLeft(8, '0')}';
}

double _r(double v) => (v * 100).roundToDouble() / 100;

Map<String, double> _rect(Rect r) => {
      'x': _r(r.left),
      'y': _r(r.top),
      'w': _r(r.width),
      'h': _r(r.height),
    };

Rect _global(RenderBox box) {
  final a = box.localToGlobal(Offset.zero);
  return a & box.size;
}

/// Mede a árvore inteira e devolve o JSON das medidas.
String medirTela(String tela) {
  final textos = <Map<String, Object?>>[];
  final caixas = <Map<String, Object?>>[];
  final icones = <Map<String, Object?>>[];

  void textoDe(RenderParagraph p) {
    if (!p.hasSize || p.size.isEmpty) return;
    final plano = p.text.toPlainText();
    if (plano.trim().isEmpty) return;
    final span = p.text;
    final estilo = span is TextSpan ? span.style : null;
    final caixasTexto = p.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: plano.length),
    );
    if (caixasTexto.isEmpty) return;
    final origem = p.localToGlobal(Offset.zero);
    final linhas = <double, Rect>{};
    for (final b in caixasTexto) {
      final r = b.toRect().shift(origem);
      final chave = _r(r.top);
      final atual = linhas[chave];
      linhas[chave] = atual == null ? r : atual.expandToInclude(r);
    }
    // Fora do layout do pai: só vale no build release (sem asserts), que é o
    // usado pelo harness. Em debug o assert cai no catch e a base fica nula.
    double? baseline;
    try {
      baseline = p.getDistanceToBaseline(TextBaseline.alphabetic);
    } catch (_) {
      baseline = null;
    }
    textos.add({
      't': plano,
      'caixa': _rect(_global(p)),
      'linhas': [for (final r in linhas.values) _rect(r)],
      'baseline': baseline == null ? null : _r(origem.dy + baseline),
      'familia': estilo?.fontFamily,
      'tamanho': estilo?.fontSize,
      'peso': estilo?.fontWeight?.value,
      'cor': _hex(estilo?.color),
      'altura': estilo?.height,
      'espacoLetra': estilo?.letterSpacing,
      'espacoPalavra': estilo?.wordSpacing,
      'distribuicao': estilo?.leadingDistribution?.name,
      'herda': estilo?.inherit,
      'decoracao': estilo?.decoration?.toString(),
      'escala': p.textScaler.scale(10) / 10,
    });
  }

  void caixaDe(RenderDecoratedBox d) {
    if (!d.hasSize || d.size.isEmpty) return;
    final dec = d.decoration;
    if (dec is! BoxDecoration) return;
    final r = _global(d);
    final raio = dec.borderRadius?.resolve(TextDirection.ltr);
    final borda = dec.border;
    caixas.add({
      ..._rect(r),
      'cor': _hex(dec.color),
      'frente': d.position == DecorationPosition.foreground,
      'circulo': dec.shape == BoxShape.circle,
      'raio': raio == null
          ? null
          : [raio.topLeft.x, raio.topRight.x, raio.bottomRight.x, raio.bottomLeft.x],
      'borda': borda is Border
          ? {
              'top': [borda.top.width, _hex(borda.top.color), borda.top.style.name],
              'right': [borda.right.width, _hex(borda.right.color), borda.right.style.name],
              'bottom': [borda.bottom.width, _hex(borda.bottom.color), borda.bottom.style.name],
              'left': [borda.left.width, _hex(borda.left.color), borda.left.style.name],
            }
          : null,
      'sombras': [
        for (final s in dec.boxShadow ?? const <BoxShadow>[])
          {
            'cor': _hex(s.color),
            'dx': s.offset.dx,
            'dy': s.offset.dy,
            'blur': s.blurRadius,
            'spread': s.spreadRadius,
          },
      ],
      'gradiente': dec.gradient?.runtimeType.toString(),
    });
  }

  void visitarRender(RenderObject ro) {
    if (ro is RenderParagraph) textoDe(ro);
    if (ro is RenderDecoratedBox) caixaDe(ro);
    ro.visitChildren(visitarRender);
  }

  for (final view in RendererBinding.instance.renderViews) {
    view.visitChildren(visitarRender);
  }

  void visitarElemento(Element e) {
    final w = e.widget;
    if (w is LummyIcon) {
      final ro = e.renderObject;
      if (ro is RenderBox && ro.hasSize) {
        icones.add({
          ..._rect(_global(ro)),
          'glifo': w.glyph.name,
          'tamanho': w.size,
          'cor': _hex(w.color),
          'traco': w.strokeWidth,
          'preenchimento': _hex(w.fill),
        });
      }
    }
    e.visitChildren(visitarElemento);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visitarElemento);

  return jsonEncode({
    'tela': tela,
    'tamanho': {
      'w': WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width,
      'h': WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height,
      'dpr': WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio,
    },
    'textos': textos,
    'caixas': caixas,
    'icones': icones,
  });
}
