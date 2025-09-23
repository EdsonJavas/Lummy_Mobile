import 'package:lummy_login/core/result.dart';
import 'package:lummy_login/models/financial_data.dart';
import 'package:lummy_login/domain/repositories/finance_repository.dart';

class GetFinancialDataUseCase {
  final FinanceRepository financeRepository;
  const GetFinancialDataUseCase(this.financeRepository);

  Future<Result<FinancialData>> call(String userId) {
    return financeRepository.getFinancialData(userId);
  }
}


