import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../shared/widgets/money_text_field.dart';

class RequestMoneyScreen extends StatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  State<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends State<RequestMoneyScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  double? _currentAmount;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _qrController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _qrScaleAnimation;
  
  String _generatedLink = '';
  bool _isGenerating = false;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _amountController.addListener(() {
      if (_hasGenerated) {
        setState(() {
          _hasGenerated = false;
          _generatedLink = '';
        });
      }
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _qrController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _qrScaleAnimation = CurvedAnimation(
      parent: _qrController,
      curve: Curves.elasticOut,
    );

    _fadeController.forward();
    _slideController.forward();
  }

  void _onAmountChanged(double? value) {
    setState(() {
      _currentAmount = value;
    });
    
    if (_hasGenerated) {
      setState(() {
        _hasGenerated = false;
        _generatedLink = '';
      });
    }
  }

  void _generateRequest() async {
    if (_currentAmount == null || _currentAmount! <= 0) {
      _showSnackBar('Digite um valor válido para pedir dinheiro', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simular geração do link (aqui você integraria com seu backend)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Gerar link único baseado no valor e timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final link = 'https://lummy.app/request/$timestamp/${_currentAmount!.toStringAsFixed(2)}';
    
    setState(() {
      _generatedLink = link;
      _hasGenerated = true;
      _isGenerating = false;
    });

    _qrController.forward();
    _showSnackBar('Link gerado com sucesso! 🎉');
  }

  void _copyToClipboard() async {
    if (_generatedLink.isEmpty) return;
    
    await Clipboard.setData(ClipboardData(text: _generatedLink));
    _showSnackBar('Link copiado para a área de transferência! 📋');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError 
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _qrController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 8 : 12),
                    // Header
                    _buildHeader(isSmallScreen),
                    
                    const SizedBox(height: 32),
                    
                    // Input de valor
                    _buildAmountInput(isSmallScreen),
                    
                    const SizedBox(height: 32),
                    
                    // Botão gerar
                    _buildGenerateButton(isSmallScreen),
                    
                    if (_hasGenerated) ...[
                      const SizedBox(height: 40),
                      
                      // QR Code
                      _buildQRCodeSection(isSmallScreen),
                      
                      const SizedBox(height: 32),
                      
                      // Link copiável
                      _buildLinkSection(isSmallScreen),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Dicas educativas
                    _buildEducationalTips(isSmallScreen),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2D3748)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF8B5CF6)],
                ).createShader(bounds),
                child: Text(
                  'Pedir Dinheiro',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Peça dinheiro ao seu responsável de forma fácil',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quanto você precisa?',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Digite o valor que você quer pedir',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          MoneyTextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            onChanged: _onAmountChanged,
            isSmallScreen: isSmallScreen,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateRequest,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.qr_code_2_rounded, size: 24),
        label: Text(
          _isGenerating ? 'Gerando...' : 'Gerar QR Code',
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 16 : 20,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildQRCodeSection(bool isSmallScreen) {
    return ScaleTransition(
      scale: _qrScaleAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF7C3AED),
              Color(0xFF6D28D9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
              size: 28,
            ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Code Gerado',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mostre este código para seu responsável',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _generatedLink,
                version: QrVersions.auto,
                size: isSmallScreen ? 200.0 : 240.0,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E293B),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _currentAmount != null 
                  ? 'R\$ ${_currentAmount!.toStringAsFixed(2).replaceAll('.', ',')}'
                  : 'R\$ 0,00',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Valor solicitado',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.link_rounded,
                color: Color(0xFF3B82F6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Link para Compartilhar',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _generatedLink,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _copyToClipboard,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF3B82F6),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toque no botão para copiar o link ou selecione o texto',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalTips(bool isSmallScreen) {
    final tips = [
      {
        'title': 'Dica Importante',
        'content': 'Sempre explique para seus pais por que você precisa desse dinheiro!',
        'emoji': '💡',
      },
      {
        'title': 'Seja Específico',
        'content': 'Diga exatamente para que vai usar o dinheiro. Isso mostra responsabilidade!',
        'emoji': '🎯',
      },
      {
        'title': 'Mostre Gratidão',
        'content': 'Agradeça seus pais pelo dinheiro e mostre que você valoriza o esforço deles!',
        'emoji': '🙏',
      },
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFFF8C42),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas para Pedir Dinheiro',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C42).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tip['emoji']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['content']!,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
