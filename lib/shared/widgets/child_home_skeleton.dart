import 'package:flutter/material.dart';

import 'package:lummy/screens/child/widgets/v1/child_avatar.dart';

import 'skeleton_loader.dart';

/// Esqueleto da Home da criança enquanto a primeira carga não termina.
///
/// Segue o layout novo (`Main.dc.html`): cabeçalho com avatar 44 e saudação,
/// barra de nível, cofrinho de 236 com raio 24, 3 ações de 56 com raio 18 e
/// 3 linhas de missão. Mesmo padding da tela (`16 20 0`).
///
/// As cores vêm do `SkeletonLoader`; a área da criança é sempre clara
/// (`Theme` claro forçado em `MainNavigation`).
class ChildHomeSkeleton extends StatelessWidget {
  const ChildHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // O avatar de verdade fica por cima do osso do avatar: com rede lenta, a
    // criança ainda abre o menu lateral (e consegue sair da conta).
    return Stack(
      children: [
        _esqueleto(),
        const Positioned(left: 20, top: 16, child: ChildAvatar(size: 44)),
      ],
    );
  }

  Widget _esqueleto() {
    return Semantics(
      label: 'Carregando',
      child: ExcludeSemantics(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(),
              const SizedBox(height: 16),
              _nivel(),
              const SizedBox(height: 18),
              _bloco(altura: 236, raio: 24),
              const SizedBox(height: 22),
              _acoes(),
              const SizedBox(height: 26),
              _missoes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bloco({required double altura, required double raio}) {
    return SkeletonLoader(
      width: double.infinity,
      height: altura,
      borderRadius: BorderRadius.circular(raio),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        const SkeletonAvatar(size: 44),
        const SizedBox(width: 12),
        const Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SkeletonText(width: 130, height: 22),
          ),
        ),
        const SizedBox(width: 12),
        SkeletonLoader(
          width: 44,
          height: 44,
          borderRadius: BorderRadius.circular(22),
        ),
      ],
    );
  }

  Widget _nivel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonText(width: 56, height: 13),
            SkeletonText(width: 96, height: 12),
          ],
        ),
        const SizedBox(height: 7),
        _bloco(altura: 8, raio: 4),
      ],
    );
  }

  Widget _acoes() {
    Widget acao() {
      return Expanded(
        child: Column(
          children: [
            SkeletonLoader(
              width: 56,
              height: 56,
              borderRadius: BorderRadius.circular(18),
            ),
            const SizedBox(height: 8),
            const SkeletonText(width: 72, height: 13),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        acao(),
        const SizedBox(width: 12),
        acao(),
        const SizedBox(width: 12),
        acao(),
      ],
    );
  }

  Widget _missoes() {
    Widget linha() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SkeletonLoader(
              width: 28,
              height: 28,
              borderRadius: BorderRadius.circular(14),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonText(width: 180, height: 15),
              ),
            ),
            const SizedBox(width: 12),
            SkeletonLoader(
              width: 52,
              height: 26,
              borderRadius: BorderRadius.circular(13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SkeletonText(width: 150, height: 18),
        ),
        const SizedBox(height: 8),
        linha(),
        linha(),
        linha(),
      ],
    );
  }
}
