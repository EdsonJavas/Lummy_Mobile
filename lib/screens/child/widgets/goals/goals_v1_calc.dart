import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/widgets/v1/v1_format.dart';

/// Estado de uma parada da viagem da meta.
enum GoalStopState {
  /// O saldo já passou do limite da parada.
  feita,

  /// A primeira parada ainda não alcançada.
  atual,

  /// As paradas depois da atual.
  futura,
}

/// Uma parada da viagem ("Paradas da viagem" da aba Metas).
class GoalStop {
  const GoalStop({
    required this.titulo,
    required this.subtitulo,
    required this.limite,
    required this.xp,
    required this.estado,
  });

  /// "Primeira estrela", "Metade do caminho", ... "{nome da meta}!".
  final String titulo;

  /// "R$ 35,00, um quarto do caminho" ou "R$ 105,00. Faltam R$ 18,50 para chegar.".
  final String subtitulo;

  /// Valor em reais em que a parada é alcançada.
  final double limite;

  /// XP prometido pela parada (ainda não é pago: pendência D7).
  final int xp;

  final GoalStopState estado;

  bool get feita => estado == GoalStopState.feita;
}

/// Contas da aba Metas (simulador, paradas e legenda das metas conquistadas).
///
/// Tudo aqui é calculado com o que já existe no app (saldo e alvo da meta):
/// nada de número inventado (DECISOES 7).
abstract final class GoalsV1Calc {
  /// Valores do simulador "Quando você chega lá?" (reais por semana).
  static const List<int> valoresPorSemana = [5, 10, 20];

  /// Valor que vem marcado, como no mockup.
  static const int valorPorSemanaPadrao = 10;

  /// Frações do alvo em que ficam as 4 paradas.
  static const List<double> _fracoes = [0.25, 0.5, 0.75, 1];

  /// XP prometido por parada (mockup: 30, 40, 50 e 100).
  static const List<int> _xp = [30, 40, 50, 100];

  /// Semanas para juntar [falta] guardando [valorPorSemana]. Mínimo 1.
  static int semanasPara(double falta, int valorPorSemana) {
    if (falta <= 0 || valorPorSemana <= 0) return 0;
    // Arredonda para centavos antes de dividir: 30,00 / 10 não pode virar 4
    // por causa de 30,000000001.
    final centavos = (falta * 100).round();
    final semanas = (centavos / (valorPorSemana * 100)).ceil();
    return semanas < 1 ? 1 : semanas;
  }

  /// Dia previsto: hoje + [semanas] × 7 dias (só a data, sem hora).
  static DateTime dataPrevista(int semanas, {DateTime? hoje}) {
    final h = hoje ?? DateTime.now();
    // Somar no campo "dia" evita o deslize de 1 hora do horário de verão.
    return DateTime(h.year, h.month, h.day + semanas * 7);
  }

  /// "Em 6 semanas, lá pelo dia 31 de dezembro."
  ///
  /// 1 semana fica no singular; ano diferente do atual ganha " de 2027"
  /// (casos que o mockup não desenhou).
  static String textoSimulador({
    required double falta,
    required int valorPorSemana,
    DateTime? hoje,
  }) {
    final h = hoje ?? DateTime.now();
    final semanas = semanasPara(falta, valorPorSemana);
    final data = dataPrevista(semanas, hoje: h);
    final quando = semanas == 1 ? 'Em 1 semana' : 'Em $semanas semanas';
    final dia = V1Format.diaDeMes(data);
    final ano = data.year == h.year ? '' : ' de ${data.year}';
    return '$quando, lá pelo dia $dia$ano.';
  }

  /// As 4 paradas (25%, 50%, 75% e 100% do alvo) com o estado de cada uma.
  ///
  /// Feita se `saldo >= limite`; atual = a primeira não feita; futura = o resto.
  static List<GoalStop> paradas({
    required String nomeDaMeta,
    required double alvo,
    required double saldo,
  }) {
    if (alvo <= 0) return const [];
    final titulos = [
      'Primeira estrela',
      'Metade do caminho',
      'Três quartos do caminho',
      '$nomeDaMeta!',
    ];
    const complementos = [', um quarto do caminho', '', '', ', a meta inteira'];

    final lista = <GoalStop>[];
    var achouAtual = false;
    for (var i = 0; i < _fracoes.length; i++) {
      final limite = _centavos(alvo * _fracoes[i]);
      final GoalStopState estado;
      if (saldo >= limite) {
        estado = GoalStopState.feita;
      } else if (!achouAtual) {
        estado = GoalStopState.atual;
        achouAtual = true;
      } else {
        estado = GoalStopState.futura;
      }
      final base = V1Format.brl(limite);
      final subtitulo = estado == GoalStopState.atual
          ? '$base. Faltam ${V1Format.brl(_centavos(limite - saldo))} para chegar.'
          : '$base${complementos[i]}';
      lista.add(
        GoalStop(
          titulo: titulos[i],
          subtitulo: subtitulo,
          limite: limite,
          xp: _xp[i],
          estado: estado,
        ),
      );
    }
    return lista;
  }

  /// "R$ 80,00, conquistada em setembro" (ano diferente do atual:
  /// "em setembro de 2025"; sem data: só o valor).
  static String legendaConquistada(Goal meta, {DateTime? agora}) {
    final valor = V1Format.brl(meta.targetAmount);
    final data = meta.completedDate;
    if (data == null) return valor;
    final hoje = agora ?? DateTime.now();
    final ano = data.year == hoje.year ? '' : ' de ${data.year}';
    return '$valor, conquistada em ${V1Format.mes(data)}$ano';
  }

  static double _centavos(double valor) => (valor * 100).round() / 100;
}
