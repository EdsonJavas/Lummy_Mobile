import 'package:intl/intl.dart';

/// Formatação pt-BR do redesenho infantil V1.
///
/// `intl` pt_BR já é inicializado em `lib/main.dart` (`initializeDateFormatting`).
abstract final class V1Format {
  static final NumberFormat _brl = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static final NumberFormat _brlInteiro = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 0,
  );

  /// "R$ 86,50" (com espaço que não quebra entre "R$" e o número).
  /// Negativos saem como "-R$ 6,20"; para "a menos que", passe o valor absoluto.
  static String brl(num valor) => _brl.format(valor);

  /// "R$ 5", "R$ 10" (botões do simulador de Metas).
  static String brlInteiro(num valor) => _brlInteiro.format(valor);

  /// "62%" (arredondado). [fracao] de 0 a 1.
  static String porcento(double fracao) => '${(fracao * 100).round()}%';

  /// "novembro".
  static String mes(DateTime data) => DateFormat('MMMM', 'pt_BR').format(data);

  /// "31 de dezembro".
  static String diaDeMes(DateTime data) =>
      DateFormat("d 'de' MMMM", 'pt_BR').format(data);

  static const _diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  /// Abreviação da coluna da sequência: "Dom", "Seg", ... "Sáb".
  static String diaCurto(DateTime data) =>
      const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][data.weekday - 1];

  /// Título do grupo de gastos: "Hoje", "Ontem" ou "Segunda, 16 de novembro".
  /// Ano diferente do atual acrescenta " de 2025".
  static String rotuloDia(DateTime data, {DateTime? agora}) {
    final hoje = _soData(agora ?? DateTime.now());
    final dia = _soData(data);
    final diff = hoje.difference(dia).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Ontem';
    final base = '${_diasSemana[dia.weekday - 1]}, ${diaDeMes(dia)}';
    return dia.year == hoje.year ? base : '$base de ${dia.year}';
  }

  /// "2026-11-19" (formato da coluna DATE do Postgres), na data LOCAL.
  static String dataIso(DateTime data) => DateFormat('yyyy-MM-dd').format(data);

  /// Data sem hora, em UTC, para que diferenças em dias não sofram com
  /// horário de verão.
  static DateTime _soData(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
