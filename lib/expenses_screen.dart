import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String selectedPeriod = 'Este mês';
  String selectedCategory = 'Todas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Meus Gastos',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe onde você gasta seu dinheiro',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),

              // Resumo dos gastos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3695F4), Color(0xFF62C370)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3695F4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Gasto',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ 1.247,50',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'de R\$ 2.000,00 disponíveis',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gráfico de gastos - Reduzindo o tamanho do gráfico
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastos por Categoria',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Gráfico estilizado
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: PieChart(
                            PieChartData(
                              startDegreeOffset: -90,
                              sectionsSpace: 2,
                              centerSpaceRadius: 48,
                              borderData: FlBorderData(show: false),
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF8B5CF6),
                                  value: 35,
                                  title: '',
                                  radius: 32,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF3B82F6),
                                  value: 25,
                                  title: '',
                                  radius: 32,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFF472B6),
                                  value: 20,
                                  title: '',
                                  radius: 32,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFFB923C),
                                  value: 15,
                                  title: '',
                                  radius: 32,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFCBD5E1),
                                  value: 5,
                                  title: '',
                                  radius: 32,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Legenda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem('Metas', const Color(0xFF8B5CF6),
                                  'R\$ 436,63'),
                              _buildLegendItem('Transporte',
                                  const Color(0xFF3B82F6), 'R\$ 311,88'),
                              _buildLegendItem('Jogos e Brinquedos',
                                  const Color(0xFFF472B6), 'R\$ 249,50'),
                              _buildLegendItem('Alimentação',
                                  const Color(0xFFFB923C), 'R\$ 187,13'),
                              _buildLegendItem('Outros',
                                  const Color(0xFFCBD5E1), 'R\$ 62,36'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Filtros
              Row(
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      'Período',
                      selectedPeriod,
                      ['Este mês', 'Última semana', 'Últimos 3 meses'],
                      (value) => setState(() => selectedPeriod = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterButton(
                      'Categoria',
                      selectedCategory,
                      ['Todas', 'Metas', 'Transporte', 'Alimentação'],
                      (value) => setState(() => selectedCategory = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Lista de transações
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transações Recentes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionItem('Lanche na escola', 'Alimentação',
                        'R\$ 15,50', const Color(0xFFFCA5A5)),
                    _buildTransactionItem('Ônibus', 'Transporte', 'R\$ 4,50',
                        const Color(0xFFFF66B3)),
                    _buildTransactionItem('Jogo novo', 'Jogos e Brinquedos',
                        'R\$ 29,90', const Color(0xFFFF8D15)),
                    _buildTransactionItem('Mesada guardada', 'Metas',
                        'R\$ 50,00', const Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, List<String> options,
      Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF1E293B),
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String title, String category, String amount, Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Jogos e Brinquedos':
        return Icons.sports_esports;
      case 'Metas':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }
}
