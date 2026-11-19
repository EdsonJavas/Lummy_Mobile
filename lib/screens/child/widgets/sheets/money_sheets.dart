import 'package:flutter/material.dart';

import 'money_sheet_expense.dart';
import 'money_sheet_frame.dart';
import 'money_sheet_income.dart';

/// Painéis de baixo de dinheiro da criança.
///
/// CONTRATO (arquiteto): as duas funções abaixo, com estas assinaturas, são
/// chamadas por outros devs e NÃO mudam:
/// - Home ("Anotar gasto") e Gastos (botão do topo) chamam
///   [showAnotarGastoSheet];
/// - o menu lateral ("Registrar dinheiro que ganhei") chama
///   [showRegistrarGanhoSheet].
///
/// Comportamento combinado:
/// - o painel lê sozinho saldo e categorias permitidas
///   (`ChildTransactionsRepository.carregarContexto`); [saldoAtual] é só uma
///   dica para a primeira pintura, se quem chama já souber o saldo;
/// - grava pelo `ChildTransactionsRepository`;
/// - depois de gravar, avisa `ChildDataChanges` e fecha devolvendo `true`;
/// - fechado sem gravar devolve `false`.
/// Quem chama NÃO precisa recarregar nada (escuta `ChildDataChanges`).
///
/// Painel "Anotar gasto" (`Anotar-gasto.dc.html`, DECISOES 17).
Future<bool> showAnotarGastoSheet(
  BuildContext context, {
  double? saldoAtual,
}) {
  return showMoneySheet(
    context,
    builder: (_) => MoneySheetExpense(saldoAtual: saldoAtual),
  );
}

/// Painel "Registrar dinheiro que ganhei" (DECISOES 18). Ver
/// [showAnotarGastoSheet] para o contrato.
///
/// [saldoAtual] fica na assinatura pelo contrato, mas hoje não é usado: pela
/// regra atual o ganho não soma ao saldo, então o painel não mostra saldo
/// (decisão do líder; ver `MoneySheetIncome`).
Future<bool> showRegistrarGanhoSheet(
  BuildContext context, {
  double? saldoAtual,
}) {
  return showMoneySheet(
    context,
    builder: (_) => const MoneySheetIncome(),
  );
}
