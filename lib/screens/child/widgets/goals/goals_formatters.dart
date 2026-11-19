/// Formatadores usados pelos cards da tela de metas.
String goalsFormatCurrency(double value) {
  return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

String goalsFormatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;

  if (difference == 0) {
    return 'hoje';
  } else if (difference == 1) {
    return 'ontem';
  } else if (difference < 7) {
    return '$difference dias atrás';
  } else if (difference < 30) {
    final weeks = (difference / 7).floor();
    return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
  } else {
    final months = (difference / 30).floor();
    return '$months mês${months > 1 ? 'es' : ''} atrás';
  }
}
