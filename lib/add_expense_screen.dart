import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'shared/widgets/money_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  double? _currentAmount;

  String _selectedType = 'expense';
  String _selectedCategory = 'Alimentação';

  final List<String> _expenseCategories = [
    'Alimentação',
    'Transporte',
    'Diversão',
    'Roupas',
    'Outros',
  ];

  final List<String> _incomeCategories = [
    'Mesada',
    'Presente',
    'Trabalho',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedType == 'expense' ? 'Registrar Gasto' : 'Adicionar Dinheiro',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? AppConstants.spacingMedium : AppConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(context, isSmallScreen),
              const Gap(24),
              _buildDescriptionField(context, isSmallScreen),
              const Gap(20),
              _buildAmountField(isSmallScreen),
              const Gap(20),
              _buildCategorySelector(context, isSmallScreen),
              const Gap(32),
              _buildSaveButton(context, isSmallScreen),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final surface = theme.cardTheme.color ?? theme.colorScheme.surface;
    final textColor = theme.textTheme.titleMedium?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'expense';
                    _selectedCategory = _expenseCategories.first;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: _selectedType == 'expense'
                        ? const Color(AppConstants.errorRed).withValues(alpha: 0.12)
                        : surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: _selectedType == 'expense'
                          ? const Color(AppConstants.errorRed)
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.remove_circle_outline_rounded,
                        color: const Color(AppConstants.errorRed),
                        size: isSmallScreen ? 32 : 36,
                      ),
                      const Gap(8),
                      Text(
                        'Gasto',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'income';
                    _selectedCategory = _incomeCategories.first;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: _selectedType == 'income'
                        ? const Color(AppConstants.successGreen).withValues(alpha: 0.12)
                        : surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: _selectedType == 'income'
                          ? const Color(AppConstants.successGreen)
                          : theme.dividerColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: const Color(AppConstants.successGreen),
                        size: isSmallScreen ? 32 : 36,
                      ),
                      const Gap(8),
                      Text(
                        'Ganho',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: _descriptionController,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: _selectedType == 'expense'
                ? 'Ex: Lanche na escola'
                : 'Ex: Mesada da semana',
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardTheme.color ?? theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite uma descrição';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(bool isSmallScreen) {
    return MoneyTextField(
      label: 'Valor',
      controller: _amountController,
      onChanged: (value) {
        setState(() {
          _currentAmount = value;
        });
      },
      isSmallScreen: isSmallScreen,
      fontSize: isSmallScreen ? 16 : 18,
      fontWeight: FontWeight.w600,
      textAlign: TextAlign.start,
    );
  }

  Widget _buildCategorySelector(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    final categories = _selectedType == 'expense'
        ? _expenseCategories
        : _incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const Gap(8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: theme.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isSmallScreen) {
    final isExpense = _selectedType == 'expense';
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _saveTransaction,
        style: FilledButton.styleFrom(
          backgroundColor: isExpense
              ? const Color(AppConstants.errorRed)
              : const Color(AppConstants.successGreen),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          elevation: 0,
        ),
        child: Text(
          isExpense ? 'Registrar Gasto' : 'Adicionar Dinheiro',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = _currentAmount ?? 0.0;

      Navigator.pop(context, {
        'description': _descriptionController.text,
        'amount': amount,
        'type': _selectedType,
        'category': _selectedCategory,
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
