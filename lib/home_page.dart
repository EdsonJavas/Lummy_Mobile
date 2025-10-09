import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/sceens/new_goal_screen.dart';
import 'profile_page.dart';
import 'add_expense_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados do usuário
  final String userName = "Edson Jr";
  final String userRole = "Pequeno Empreendedor";
  double currentBalance = 127.50;
  double savingsGoal = 200.00;
  String goalName = "Bicicleta Nova";
  String goalEmoji = "🚲";
  
  // Lista de transações
  List<Map<String, dynamic>> transactions = [];
  
  // Lista de conquistas
  List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_saving',
      'title': 'Primeira Economia',
      'description': 'Você guardou seu primeiro dinheiro!',
      'emoji': '🥇',
      'isCompleted': true,
    },
    {
      'id': 'expense_control',
      'title': 'Controle de Gastos',
      'description': 'Anotou gastos por 7 dias seguidos',
      'emoji': '📊',
      'isCompleted': true,
    },
    {
      'id': 'goal_reached',
      'title': 'Meta Alcançada',
      'description': 'Complete sua primeira meta de economia',
      'emoji': '🎯',
      'isCompleted': false,
    },
  ];
  
  // Lista de dicas educativas
  int currentTipIndex = 0;
  final List<EducationalTip> educationalTips = [
    EducationalTip(
      "Dica do Dia",
      "Que tal anotar todos os seus gastos por uma semana?",
      "📝",
    ),
    EducationalTip(
      "Você Sabia?",
      "Guardar 10% do que você ganha é um ótimo começo para suas metas!",
      "💡",
    ),
    EducationalTip(
      "Desafio",
      "Tente economizar R\$ 5,00 esta semana comprando menos doces!",
      "🎯",
    ),
    EducationalTip(
      "Aprenda",
      "Antes de comprar algo, pergunte: 'Eu realmente preciso disso?'",
      "🤔",
    ),
    EducationalTip(
      "Meta Inteligente",
      "Divida sua meta grande em metas menores. Fica mais fácil!",
      "🧠",
    ),
  ];

  void _nextTip() {
    setState(() {
      currentTipIndex = (currentTipIndex + 1) % educationalTips.length;
    });
  }

  void _addTransaction(String description, double amount, String type, String category) {
    setState(() {
      transactions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'description': description,
        'amount': amount,
        'type': type,
        'category': category,
        'date': DateTime.now(),
      });
      
      if (type == 'expense') {
        currentBalance -= amount;
      } else {
        currentBalance += amount;
      }
      
      _checkAchievements();
    });
  }

  void _setNewGoal(String name, String emoji, double amount) {
    setState(() {
      goalName = name;
      goalEmoji = emoji;
      savingsGoal = amount;
    });
  }

  void _checkAchievements() {
    setState(() {
      // Verificar meta alcançada
      if (currentBalance >= savingsGoal) {
        achievements = achievements.map((achievement) {
          if (achievement['id'] == 'goal_reached') {
            achievement['isCompleted'] = true;
          }
          return achievement;
        }).toList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header simples estilo Inter
              _buildSimpleHeader(screenWidth, isSmallScreen),
              
              // Saldo atual
              _buildBalanceCard(screenWidth, isSmallScreen),
              
              // Meta de economia
              _buildSavingsGoal(screenWidth, isSmallScreen),
              
              // Ações rápidas (estilo Inter)
              _buildQuickActionsInter(screenWidth, isSmallScreen),
              
              // Educação financeira
              _buildEducationSection(screenWidth, isSmallScreen),
              
              // Conquistas melhoradas
              _buildAchievementsImproved(screenWidth, isSmallScreen),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHeader(double screenWidth, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $userName',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Como estão suas finanças hoje?',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Botão do Perfil
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: Container(
                  width: isSmallScreen ? 50 : 56,
                  height: isSmallScreen ? 50 : 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E40AF),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E40AF).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Image.network(
                        'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E40AF).withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.person,
                              color: const Color(0xFF1E40AF),
                              size: isSmallScreen ? 24 : 28,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double screenWidth, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF1E3A8A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meu Cofrinho',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🐷',
                  style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'R\$ ${currentBalance.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 36 : 42,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+R\$ 15,00',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'esta semana',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsGoal(double screenWidth, bool isSmallScreen) {
    final progress = currentBalance / savingsGoal;
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  goalEmoji,
                  style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalName,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Meta de economia',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 1.0 ? 1.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Economizado',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'R\$ ${currentBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Falta',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'R\$ ${(savingsGoal - currentBalance).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsInter(double screenWidth, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que você quer fazer?',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    );
                    
                    if (result != null) {
                      _addTransaction(
                        result['description'],
                        result['amount'],
                        result['type'],
                        result['category'],
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['type'] == 'expense' 
                                ? 'Gasto registrado! 📝'
                                : 'Dinheiro adicionado! 💰',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  child: _buildActionCardInter(
                    'Registrar Gasto',
                    'Anote o que você gastou',
                    Icons.receipt_long_outlined,
                    const Color(0xFFEF4444),
                    isSmallScreen,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewGoalScreen(),
                      ),
                    );
                    
                    if (result != null) {
                      _setNewGoal(
                        result['name'],
                        result['emoji'],
                        result['amount'],
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Nova meta criada! 🎯',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: const Color(0xFF8B5CF6),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  child: _buildActionCardInter(
                    'Nova Meta',
                    'Defina um novo objetivo',
                    Icons.flag_outlined,
                    const Color(0xFF8B5CF6),
                    isSmallScreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardInter(String title, String subtitle, IconData icon, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(double screenWidth, bool isSmallScreen) {
    final currentTip = educationalTips[currentTipIndex];
    
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aprenda Brincando',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentTip.emoji,
                        style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currentTip.category,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currentTip.content,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextTip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    'Mais dicas',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsImproved(double screenWidth, bool isSmallScreen) {
    final completedAchievements = achievements.where((a) => a['isCompleted'] == true).length;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suas Conquistas',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                '$completedAchievements de ${achievements.length}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: achievements.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 16),
                    _buildAchievementItem(
                      achievement['emoji'],
                      achievement['title'],
                      achievement['description'],
                      achievement['isCompleted'],
                      isSmallScreen,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String description, bool isCompleted, bool isSmallScreen) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 48 : 56,
          height: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (isCompleted)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
      ],
    );
  }
}

class EducationalTip {
  final String category;
  final String content;
  final String emoji;

  EducationalTip(this.category, this.content, this.emoji);
}


