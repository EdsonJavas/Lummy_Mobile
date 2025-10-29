import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    'Alimentação', 'Transporte', 'Diversão', 'Roupas', 'Outros'
  ];
  
  final List<String> _incomeCategories = [
    'Mesada', 'Presente', 'Trabalho', 'Outros'
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedType == 'expense' ? 'Registrar Gasto' : 'Adicionar Dinheiro',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // ✨ Scroll solto adicionado
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor de tipo
              _buildTypeSelector(isSmallScreen),
              const SizedBox(height: 24),
              
              // Campo de descrição
              _buildDescriptionField(isSmallScreen),
              const SizedBox(height: 20),
              
              // Campo de valor
              _buildAmountField(isSmallScreen),
              const SizedBox(height: 20),
              
              // Seletor de categoria
              _buildCategorySelector(isSmallScreen),
              const SizedBox(height: 32),
              
              // Botão de salvar
              _buildSaveButton(isSmallScreen),
              
              // Espaço extra para o scroll
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
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
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: BoxDecoration(
                    color: _selectedType == 'expense' 
                        ? const Color(0xFFEF4444).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == 'expense'
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        color: const Color(0xFFEF4444),
                        size: isSmallScreen ? 32 : 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gasto',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = 'income';
                    _selectedCategory = _incomeCategories.first;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                  decoration: BoxDecoration(
                    color: _selectedType == 'income' 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedType == 'income'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: const Color(0xFF10B981),
                        size: isSmallScreen ? 32 : 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ganho',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
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

  Widget _buildDescriptionField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: _selectedType == 'expense' 
                ? 'Ex: Lanche na escola'
                : 'Ex: Mesada da semana',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF64748B),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 2),
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

  Widget _buildCategorySelector(bool isSmallScreen) {
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
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      color: const Color(0xFF1E293B),
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

  Widget _buildSaveButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedType == 'expense' 
              ? const Color(0xFFEF4444)
              : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          _selectedType == 'expense' ? 'Registrar Gasto' : 'Adicionar Dinheiro',
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
