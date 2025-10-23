import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedEmoji = '🚲';

  final List<String> _goalEmojis = [
    '🚲',
    '🎮',
    '📱',
    '👟',
    '🎸',
    '📚',
    '🏀',
    '🎨',
    '🧸',
    '🎯',
    '💻',
    '🎧',
    '⚽',
    '🛴',
    '🎪',
    '🎭',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header arredondado vindo de cima
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)]
                      : [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 20.0 : 24.0,
                MediaQuery.of(context).padding.top + 16,
                isSmallScreen ? 20.0 : 24.0,
                isSmallScreen ? 28.0 : 32.0,
              ),
              child: Column(
                children: [
                  // Botão voltar e título
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Nova Meta',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Preview da meta no header
                  _buildGoalPreviewInHeader(isSmallScreen),
                ],
              ),
            ),
            // Conteúdo
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Seletor de emoji
                    _buildEmojiSelector(isSmallScreen),
                    const SizedBox(height: 24),

                    // Campo de nome
                    _buildNameField(isSmallScreen),
                    const SizedBox(height: 20),

                    // Campo de valor
                    _buildAmountField(isSmallScreen),
                    const SizedBox(height: 32),

                    // Botão de salvar
                    _buildSaveButton(isSmallScreen),

                    // Espaço extra para o scroll
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPreviewInHeader(bool isSmallScreen) {
    return Column(
      children: [
        // Emoji grande
        Container(
          width: isSmallScreen ? 70 : 90,
          height: isSmallScreen ? 70 : 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Text(
              _selectedEmoji,
              style: TextStyle(fontSize: isSmallScreen ? 40 : 50),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Nome da meta
        Text(
          _nameController.text.isEmpty ? 'Nome da Meta' : _nameController.text,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Valor
        Text(
          _amountController.text.isEmpty
              ? 'R\$ 0,00'
              : 'R\$ ${_amountController.text}',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 28 : 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            'Preview da sua meta',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiSelector(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFFFF8C42), const Color(0xFF10B981)]
                : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
          ).createShader(bounds),
          child: Text(
            'Escolha um emoji',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).dividerColor
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _goalEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _goalEmojis[index];
              final isSelected = emoji == _selectedEmoji;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEmoji = emoji;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome da meta',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          onChanged: (value) => setState(() {}),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Bicicleta Nova',
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            prefixIcon: Icon(
              Icons.flag_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite o nome da meta';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor da meta',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          onChanged: (value) => setState(() {}),
          keyboardType: TextInputType.number,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 14 : 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '200,00',
            hintStyle: GoogleFonts.poppins(
              color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            prefixText: 'R\$ ',
            prefixStyle: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            prefixIcon: Icon(
              Icons.attach_money,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, digite o valor da meta';
            }
            if (double.tryParse(value.replaceAll(',', '.')) == null) {
              return 'Por favor, digite um valor válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Criar Meta',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));

      Navigator.pop(context, {
        'name': _nameController.text,
        'emoji': _selectedEmoji,
        'amount': amount,
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
