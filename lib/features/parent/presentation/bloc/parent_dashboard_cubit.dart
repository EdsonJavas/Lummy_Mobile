import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/entities/transaction_entity.dart';
import '../../../../domain/entities/notification_entity.dart';
import 'parent_dashboard_state.dart';

class ParentDashboardCubit extends Cubit<ParentDashboardState> {
  ParentDashboardCubit() : super(const ParentDashboardState());

  final _supabase = Supabase.instance.client;

  String? _parentId;
  String? _parentName;

  String? get parentId => _parentId;
  String? get parentName => _parentName;

  // Carregar dashboard do responsável
  Future<void> loadDashboard(String parentId, {String? parentName}) async {
    _parentId = parentId;
    if (parentName != null) {
      _parentName = parentName;
    }
    emit(state.copyWith(isLoading: true, parentName: _parentName));

    try {
      // Buscar dados reais do banco
      final children = await _fetchRealChildren(parentId);

      // Saldo principal do responsavel (separado do saldo dos filhos)
      final parentBalance = await _fetchParentBalance(parentId);

      // Buscar dados reais do banco
      final pendingApprovals = await _fetchPendingApprovals(parentId, children);
      final notifications = _getMockNotifications(parentId, children); // TODO: Implementar quando tiver tabela de notificações
      final spending = await _calculateSpending(children);
      final monthlyTrend = await _fetchMonthlyTrend(parentId, children);
      final categoryBreakdown = await _fetchCategoryBreakdown(parentId, children);
      final goalSummaries = await _fetchGoalSummaries(children);

      emit(
        state.copyWith(
          isLoading: false,
          parentName: _parentName,
          children: children,
          pendingApprovals: pendingApprovals,
          notifications: notifications,
          totalSpendingByChild: spending,
          walletBalance: parentBalance,
          monthIncomeTotal: monthlyTrend.isNotEmpty
              ? monthlyTrend.last.income
              : 0,
          monthExpenseTotal: monthlyTrend.isNotEmpty
              ? monthlyTrend.last.expense
              : 0,
          monthlyTrend: monthlyTrend,
          categoryBreakdown: categoryBreakdown,
          goalSummaries: goalSummaries,
          error: null,
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao carregar dashboard: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // Buscar filhos reais do banco de dados
  Future<List<ChildEntity>> _fetchRealChildren(String parentId) async {
    try {
      final response = await _supabase
          .from('children')
          .select('''
            id,
            responsavel_id,
            nome,
            cpf,
            email,
            idade,
            sexo,
            balance,
            allowance,
            requires_approval,
            created_at
          ''')
          .eq('responsavel_id', parentId);

      if (response.isEmpty) {
        debugPrint('ℹ️ Nenhum filho encontrado para o responsável $parentId');
        return [];
      }

      return response.map<ChildEntity>((row) {
        return ChildEntity(
          id: row['id'] as String,
          email: (row['email'] ?? '') as String,
          name: (row['nome'] ?? '') as String,
          parentId: (row['responsavel_id'] ?? '') as String,
          age: (row['idade'] as int?) ?? 0,
          gender: _mapGender(row['sexo'] as String?),
          cpf: (row['cpf'] ?? '') as String,
          createdAt: _parseDate(row['created_at']),
          balance: (row['balance'] as num?)?.toDouble() ?? 0.0,
          allowance: (row['allowance'] as num?)?.toDouble() ?? 0.0,
          requiresApproval: row['requires_approval'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar filhos: $e');
      return [];
    }
  }

  Gender _mapGender(String? value) {
    final normalized = value?.toLowerCase().trim();
    switch (normalized) {
      case 'masculino':
      case 'male':
      case 'm':
        return Gender.male;
      case 'feminino':
      case 'female':
      case 'f':
        return Gender.female;
      default:
        return Gender.other;
    }
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> refresh() async {
    final id = _parentId;
    if (id == null) return;
    await loadDashboard(id);
  }

  Future<double> _fetchParentBalance(String parentId) async {
    try {
      final row = await _supabase
          .from('responsaveis')
          .select('balance')
          .eq('id', parentId)
          .maybeSingle();
      return (row?['balance'] as num?)?.toDouble() ?? 2300.0;
    } catch (e) {
      debugPrint('⚠️ Erro ao buscar saldo do responsável: $e');
      return state.walletBalance > 0 ? state.walletBalance : 2300.0;
    }
  }

  Future<bool> _deductParentBalance(double amount) async {
    final parentId = _parentId;
    if (parentId == null) return false;
    if (amount <= 0) return true;

    final current = await _fetchParentBalance(parentId);
    if (current < amount) {
      emit(state.copyWith(error: 'Saldo do responsável insuficiente'));
      return false;
    }

    final updated = double.parse((current - amount).toStringAsFixed(2));
    await _supabase
        .from('responsaveis')
        .update({'balance': updated})
        .eq('id', parentId);

    emit(state.copyWith(walletBalance: updated));
    return true;
  }

  // Aprovar transação
  Future<void> approveTransaction(String transactionId) async {
    try {
      // Validar entrada
      if (transactionId.isEmpty) {
        emit(state.copyWith(error: 'ID da transação inválido'));
        return;
      }

      // Atualizar status no banco
      await _supabase
          .from('transactions')
          .update({
            'status': 'approved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId);

      // O trigger update_child_balance vai atualizar o saldo automaticamente
      // Recarregar dados para refletir mudanças
      await refresh();
    } catch (e) {
      debugPrint('❌ Erro ao aprovar transação: $e');
      emit(state.copyWith(error: 'Erro ao aprovar transação: ${e.toString()}'));
    }
  }

  // Rejeitar transação
  Future<void> rejectTransaction(String transactionId, String reason) async {
    try {
      // Validar entrada
      if (transactionId.isEmpty) {
        emit(state.copyWith(error: 'ID da transação inválido'));
        return;
      }

      if (reason.trim().isEmpty) {
        emit(state.copyWith(error: 'Motivo da rejeição é obrigatório'));
        return;
      }

      // Atualizar status no banco
      await _supabase
          .from('transactions')
          .update({
            'status': 'rejected',
            'rejection_reason': reason.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId);

      // O trigger update_child_balance vai reverter o saldo se necessário
      // Recarregar dados para refletir mudanças
      await refresh();
    } catch (e) {
      debugPrint('❌ Erro ao rejeitar transação: $e');
      emit(state.copyWith(error: 'Erro ao rejeitar transação: ${e.toString()}'));
    }
  }

  // Transferir dinheiro para criança
  Future<void> transferToChild(String childId, double amount) async {
    try {
      // Validar entrada
      if (childId.isEmpty) {
        emit(state.copyWith(error: 'ID da criança inválido'));
        return;
      }

      if (amount <= 0) {
        emit(state.copyWith(error: 'Valor deve ser maior que zero'));
        return;
      }

      final parentId = _parentId;
      if (parentId == null) {
        emit(state.copyWith(error: 'Responsável não identificado'));
        return;
      }

      // Verificar se a criança existe
      final childExists = await _supabase
          .from('children')
          .select('id')
          .eq('id', childId)
          .maybeSingle();

      if (childExists == null) {
        emit(state.copyWith(error: 'Criança não encontrada'));
        return;
      }

      final hasBalance = await _deductParentBalance(amount);
      if (!hasBalance) return;

      // Criar transação no banco
      await _supabase.from('transactions').insert({
        'child_id': childId,
        'parent_id': parentId,
        'amount': amount,
        'type': 'income',
        'description': 'Transferência do responsável',
        'category': 'Transferência',
        'status': 'approved', // Aprovada automaticamente
        'date': DateTime.now().toIso8601String(),
      });

      // O trigger update_child_balance vai atualizar o balance automaticamente
      // Recarregar dados para refletir mudanças
      await refresh();
    } catch (e) {
      debugPrint('❌ Erro ao transferir dinheiro: $e');
      emit(state.copyWith(error: 'Erro ao transferir dinheiro: ${e.toString()}'));
    }
  }

  Future<void> distributeAmount(double amount) async {
    if (amount <= 0 || state.children.isEmpty) {
      return;
    }
    await createDistributionToClaim(amount);
  }

  Future<void> createDistributionToClaim(double amount) async {
    try {
      if (amount <= 0) {
        emit(state.copyWith(error: 'Valor deve ser maior que zero'));
        return;
      }
      if (state.children.isEmpty) {
        emit(state.copyWith(error: 'Cadastre filhos para distribuir'));
        return;
      }
      final parentId = _parentId;
      if (parentId == null) {
        emit(state.copyWith(error: 'Responsável não identificado'));
        return;
      }

      final hasBalance = await _deductParentBalance(amount);
      if (!hasBalance) return;

      await _supabase
          .from('allowance_distributions')
          .update({
            'status': 'closed',
            'closed_at': DateTime.now().toIso8601String(),
          })
          .eq('parent_id', parentId)
          .eq('status', 'active');

      await _supabase.from('allowance_distributions').insert({
        'parent_id': parentId,
        'total_amount': amount,
        'status': 'active',
      });

      await refresh();
    } catch (e) {
      debugPrint('❌ Erro ao criar distribuição: $e');
      emit(state.copyWith(error: 'Erro ao criar distribuição: ${e.toString()}'));
    }
  }

  // Configurar mesada
  Future<void> setAllowance(String childId, double amount) async {
    try {
      // Validar entrada
      if (childId.isEmpty) {
        emit(state.copyWith(error: 'ID da criança inválido'));
        return;
      }

      if (amount < 0) {
        emit(state.copyWith(error: 'Valor da mesada não pode ser negativo'));
        return;
      }

      // Atualizar no banco
      await _supabase
          .from('children')
          .update({'allowance': amount})
          .eq('id', childId);

      // Atualizar estado local
      final childIndex = state.children.indexWhere((c) => c.id == childId);
      if (childIndex != -1) {
        final child = state.children[childIndex];
        final updatedChild = child.copyWith(allowance: amount);
        final updatedChildren = List<ChildEntity>.from(state.children);
        updatedChildren[childIndex] = updatedChild;
        emit(state.copyWith(children: updatedChildren));
      }
    } catch (e) {
      debugPrint('❌ Erro ao configurar mesada: $e');
      emit(state.copyWith(error: 'Erro ao configurar mesada: ${e.toString()}'));
    }
  }

  // Selecionar criança
  void selectChild(ChildEntity child) {
    emit(state.copyWith(selectedChild: child));
  }

  // Marcar notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Atualizar estado local
      final updatedNotifications = state.notifications.map((n) {
        return n.id == notificationId ? n.copyWith(isRead: true) : n;
      }).toList();

      emit(state.copyWith(notifications: updatedNotifications));

      // TODO: Implementar quando tiver tabela de notificações no banco
      // await _supabase
      //     .from('notifications')
      //     .update({'is_read': true})
      //     .eq('id', notificationId);
    } catch (e) {
      debugPrint('❌ Erro ao marcar notificação como lida: $e');
    }
  }

  // Buscar transações pendentes do banco
  Future<List<TransactionEntity>> _fetchPendingApprovals(
    String parentId,
    List<ChildEntity> children,
  ) async {
    try {
      if (children.isEmpty) return [];

      final childIds = children.map((c) => c.id).toList();

      // Usar .or() para filtrar múltiplos child_ids
      var query = _supabase
          .from('transactions')
          .select('*')
          .eq('status', 'pending');
      
      if (childIds.length == 1) {
        query = query.eq('child_id', childIds[0]);
      } else if (childIds.length > 1) {
        final orFilter = childIds.map((id) => 'child_id.eq.$id').join(',');
        query = query.or(orFilter);
      } else {
        return [];
      }

      final response = await query.order('created_at', ascending: false);

      return response.map<TransactionEntity>((row) {
        return TransactionEntity(
          id: row['id'] as String,
          userId: row['child_id'] as String,
          parentId: row['parent_id'] as String?,
          description: row['description'] as String,
          amount: (row['amount'] as num).toDouble(),
          type: _mapTransactionType(row['type'] as String),
          status: _mapTransactionStatus(row['status'] as String),
          category: row['category'] as String,
          date: _parseDate(row['date']),
          createdAt: _parseDate(row['created_at']),
          rejectionReason: row['rejection_reason'] as String?,
          metadata: row['metadata'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar transações pendentes: $e');
      return [];
    }
  }

  TransactionType _mapTransactionType(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'allowance':
        return TransactionType.allowance;
      case 'reward':
        return TransactionType.reward;
      default:
        return TransactionType.expense;
    }
  }

  TransactionStatus _mapTransactionStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'approved':
        return TransactionStatus.approved;
      case 'rejected':
        return TransactionStatus.rejected;
      case 'completed':
        return TransactionStatus.completed;
      default:
        return TransactionStatus.pending;
    }
  }

  List<NotificationEntity> _getMockNotifications(
    String parentId,
    List<ChildEntity> children,
  ) {
    if (children.isEmpty) return [];

    final child = children.first;
    return [
      NotificationEntity(
        id: 'notif_1',
        userId: parentId,
        fromUserId: child.id,
        type: NotificationType.requestPending,
        title: 'Nova solicitação',
        message: '${child.name} solicitou R\$ 60,00 para comprar um jogo',
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<Map<String, double>> _calculateSpending(List<ChildEntity> children) async {
    try {
      if (children.isEmpty) return {};

      final childIds = children.map((c) => c.id).toList();
      final spendingMap = <String, double>{};

      // Buscar gastos aprovados dos últimos 30 dias
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Usar .or() para filtrar múltiplos child_ids e status
      var query = _supabase
          .from('transactions')
          .select('child_id, amount')
          .eq('type', 'expense')
          .gte('date', thirtyDaysAgo.toIso8601String());
      
      if (childIds.length == 1) {
        query = query.eq('child_id', childIds[0]);
      } else if (childIds.length > 1) {
        final orFilter = childIds.map((id) => 'child_id.eq.$id').join(',');
        query = query.or(orFilter);
      }
      
      // Filtrar por status usando .or()
      query = query.or('status.eq.approved,status.eq.completed');

      final response = await query;

      for (final row in response) {
        final childId = row['child_id'] as String;
        final amount = (row['amount'] as num).toDouble();
        spendingMap[childId] = (spendingMap[childId] ?? 0.0) + amount;
      }

      return spendingMap;
    } catch (e) {
      debugPrint('❌ Erro ao calcular gastos: $e');
      return {};
    }
  }

  Future<List<MonthlySpendingPoint>> _fetchMonthlyTrend(
    String parentId,
    List<ChildEntity> children,
  ) async {
    try {
      if (children.isEmpty) return [];

      final childIds = children.map((c) => c.id).toList();
      final now = DateTime.now();
      final months = <String, Map<String, double>>{};

      // Buscar transações dos últimos 4 meses
      for (var i = 0; i < 4; i++) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
        final monthKey = '${monthStart.month}/${monthStart.year}';

        // Usar .or() para filtrar múltiplos child_ids e status
        var query = _supabase
            .from('transactions')
            .select('type, amount')
            .gte('date', monthStart.toIso8601String())
            .lte('date', monthEnd.toIso8601String());
        
        if (childIds.length == 1) {
          query = query.eq('child_id', childIds[0]);
        } else if (childIds.length > 1) {
          final orFilter = childIds.map((id) => 'child_id.eq.$id').join(',');
          query = query.or(orFilter);
        }
        
        // Filtrar por status usando .or()
        query = query.or('status.eq.approved,status.eq.completed');

        final response = await query;

        double income = 0.0;
        double expense = 0.0;

        for (final row in response) {
          final amount = (row['amount'] as num).toDouble();
          final type = row['type'] as String;

          if (type == 'expense') {
            expense += amount;
          } else if (['income', 'allowance', 'reward'].contains(type)) {
            income += amount;
          }
        }

        months[monthKey] = {'income': income, 'expense': expense};
      }

      // Converter para lista ordenada
      final monthNames = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
          'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
      final monthLabels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
          'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

      return months.entries.map((entry) {
        final parts = entry.key.split('/');
        final month = int.parse(parts[0]);
        final monthName = monthNames[month - 1];
        final monthLabel = monthLabels[month - 1];

        return MonthlySpendingPoint(
          month: monthName,
          monthLabel: monthLabel,
          income: entry.value['income'] ?? 0.0,
          expense: entry.value['expense'] ?? 0.0,
        );
      }).toList()
        ..sort((a, b) => a.month.compareTo(b.month));
    } catch (e) {
      debugPrint('❌ Erro ao buscar tendência mensal: $e');
      return [];
    }
  }

  Future<List<CategorySpendingData>> _fetchCategoryBreakdown(
    String parentId,
    List<ChildEntity> children,
  ) async {
    try {
      if (children.isEmpty) return [];

      final childIds = children.map((c) => c.id).toList();
      final categoryMap = <String, double>{};

      // Buscar gastos aprovados dos últimos 30 dias
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Usar .or() para filtrar múltiplos child_ids e status
      var query = _supabase
          .from('transactions')
          .select('category, amount')
          .eq('type', 'expense')
          .gte('date', thirtyDaysAgo.toIso8601String());
      
      if (childIds.length == 1) {
        query = query.eq('child_id', childIds[0]);
      } else if (childIds.length > 1) {
        final orFilter = childIds.map((id) => 'child_id.eq.$id').join(',');
        query = query.or(orFilter);
      }
      
      // Filtrar por status usando .or()
      query = query.or('status.eq.approved,status.eq.completed');

      final response = await query;

      double total = 0.0;
      for (final row in response) {
        final category = row['category'] as String;
        final amount = (row['amount'] as num).toDouble();
        categoryMap[category] = (categoryMap[category] ?? 0.0) + amount;
        total += amount;
      }

      if (total == 0) return [];

      // Converter para lista e calcular percentuais
      final colors = [
        const Color(AppConstants.primaryBlue),
        const Color(AppConstants.accentOrange),
        const Color(AppConstants.purple),
        const Color(AppConstants.successGreen),
        const Color(AppConstants.textSecondary),
      ];

      final entries = categoryMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return entries.asMap().entries.map((entry) {
        final index = entry.key;
        final categoryEntry = entry.value;
        final percentage = (categoryEntry.value / total * 100).round().toDouble();

        return CategorySpendingData(
          category: categoryEntry.key,
          value: categoryEntry.value,
          percentage: percentage,
          color: colors[index % colors.length],
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Erro ao buscar breakdown de categorias: $e');
      return [];
    }
  }

  Future<List<ChildGoalSummary>> _fetchGoalSummaries(List<ChildEntity> children) async {
    try {
      if (children.isEmpty) return [];

      final summaries = <ChildGoalSummary>[];

      for (final child in children) {
        final goalsResponse = await _supabase
            .from('goals')
            .select('status, target_amount, current_amount')
            .eq('child_id', child.id);

        final totalGoals = goalsResponse.length;
        final completedGoals = goalsResponse
            .where((g) => g['status'] == 'completed')
            .length;

        double totalProgress = 0.0;
        int activeGoals = 0;

        for (final goal in goalsResponse) {
          if (goal['status'] == 'active') {
            final target = (goal['target_amount'] as num).toDouble();
            final current = (goal['current_amount'] as num).toDouble();
            if (target > 0) {
              totalProgress += current / target;
              activeGoals++;
            }
          }
        }

        final averageProgress = activeGoals > 0 ? totalProgress / activeGoals : 0.0;

        summaries.add(ChildGoalSummary(
          childId: child.id,
          childName: child.name,
          completedGoals: completedGoals,
          totalGoals: totalGoals,
          averageProgress: averageProgress,
        ));
      }

      return summaries;
    } catch (e) {
      debugPrint('❌ Erro ao buscar resumo de metas: $e');
      return [];
    }
  }
}
