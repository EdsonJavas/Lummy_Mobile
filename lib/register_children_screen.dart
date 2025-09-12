import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsavel_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterChildrenScreen extends StatefulWidget {
  final Responsavel responsavel;

  const RegisterChildrenScreen({super.key, required this.responsavel});
  @override
  State<RegisterChildrenScreen> createState() => _RegisterChildrenScreenState();
}

class _RegisterChildrenScreenState extends State<RegisterChildrenScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _nameFocused = false;
  bool _cpfFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _ageFocused = false;

  String? _responsavelId; // 🔹 Para guardar o ID do responsável no Firestore

  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late AnimationController _starAnimationController;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    _criarResponsavelNoFirestore(); // 🔹 cria o responsável assim que entra na tela
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _starAnimationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    _starAnimationController.dispose();
    super.dispose();
  }

  // Função para formatar CPF
  String _formatCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9)
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  // Função para validar CPF
  bool _isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;

    return digit1 == int.parse(cpf[9]) && digit2 == int.parse(cpf[10]);
  }

  Future<void> _criarResponsavelNoFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final docRef = await firestore.collection("responsaveis").add({
        "nome": widget.responsavel.nome,
        "cpf": widget.responsavel.cpf,
        "email": widget.responsavel.email,
        "senha": widget.responsavel.senha, // ⚠️ não recomendado texto plano
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        _responsavelId = docRef.id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar responsável: $e")),
      );
    }
  }

  // 🔹 Agora o método principal volta a se chamar _handleRegisterChild
  Future<void> _handleRegisterChild() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione o sexo da criança")),
        );
        return;
      }

      if (_responsavelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Responsável ainda não foi criado")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance
            .collection("responsaveis")
            .doc(_responsavelId)
            .collection("children")
            .add({
          "nome": _nameController.text.trim(),
          "cpf": _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          "email": _emailController.text.trim(),
          "senha": _passwordController.text, // ⚠️ idem
          "idade": int.tryParse(_ageController.text.trim()) ?? 0,
          "sexo": _selectedGender,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Criança adicionada com sucesso!")),
        );

        // 🔹 limpar formulário
        _formKey.currentState?.reset();
        _nameController.clear();
        _cpfController.clear();
        _emailController.clear();
        _passwordController.clear();
        _ageController.clear();
        setState(() {
          _selectedGender = '';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao adicionar criança: $e")),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  // void _finalizarCadastro() {
  //   Navigator.pop(context); // ou push para home/dashboard
  // }

  // Future<void> _handleRegisterChild() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (_selectedGender.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Por favor, selecione o sexo da criança'),
  //           backgroundColor: Colors.orange,
  //           behavior: SnackBarBehavior.floating,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         ),
  //       );
  //       return;
  //     }

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       final firestore = FirebaseFirestore.instance;

  //       // 🔹 1. Criar documento do responsável
  //       final responsavelRef = await firestore.collection("responsaveis").add({
  //         "nome": widget.responsavel.nome,
  //         "cpf": widget.responsavel.cpf,
  //         "email": widget.responsavel.email,
  //         "senha": widget
  //             .responsavel.senha, // ⚠️ não recomendado salvar em texto plano
  //         "createdAt": FieldValue.serverTimestamp(),
  //       });

  //       // 🔹 2. Criar documento da criança dentro de "children"
  //       await firestore
  //           .collection("responsaveis")
  //           .doc(responsavelRef.id)
  //           .collection("children")
  //           .add({
  //         "nome": _nameController.text.trim(),
  //         "cpf": _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
  //         "email": _emailController.text.trim(),
  //         "senha": _passwordController.text, // ⚠️ idem
  //         "idade": int.tryParse(_ageController.text.trim()) ?? 0,
  //         "sexo": _selectedGender,
  //         "createdAt": FieldValue.serverTimestamp(),
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content:
  //               const Text('🎉 Responsável e criança cadastrados com sucesso!'),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //           shape:
  //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //         ),
  //       );

  //       // 🔹 Se quiser limpar os campos da criança
  //       _nameController.clear();
  //       _cpfController.clear();
  //       _emailController.clear();
  //       _passwordController.clear();
  //       _ageController.clear();
  //       setState(() {
  //         _selectedGender = '';
  //       });

  //       // 🔹 Pode navegar para próxima tela
  //       Navigator.pop(context); // ou push para home/dashboard
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erro ao salvar: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }

  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Text('🎉 '),
  //           const Text('Criança cadastrada com sucesso!'),
  //         ],
  //       ),
  //       backgroundColor: Colors.green,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //     ),
  //   );
  //   if (_selectedGender.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Por favor, selecione o sexo da criança'),
  //         backgroundColor: Colors.orange,
  //         behavior: SnackBarBehavior.floating,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //       ),
  //     );
  //   }
  // }

  Widget _buildGenderSelector() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenHeight < 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexo da criança',
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Masculino';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: _selectedGender == 'Masculino'
                        ? const LinearGradient(
                            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                          )
                        : null,
                    color: _selectedGender == 'Masculino'
                        ? null
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedGender == 'Masculino'
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: _selectedGender == 'Masculino'
                        ? [
                            BoxShadow(
                              color: const Color(0xFF4FC3F7).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👦',
                        style: TextStyle(fontSize: isVerySmallScreen ? 24 : 30),
                      ),
                      SizedBox(height: isVerySmallScreen ? 4 : 8),
                      Text(
                        'Menino',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 'Masculino'
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: isVerySmallScreen ? 12 : 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Feminino';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: _selectedGender == 'Feminino'
                        ? const LinearGradient(
                            colors: [Color(0xFFFF8A95), Color(0xFFFF6B7A)],
                          )
                        : null,
                    color: _selectedGender == 'Feminino'
                        ? null
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedGender == 'Feminino'
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: _selectedGender == 'Feminino'
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF8A95).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👧',
                        style: TextStyle(fontSize: isVerySmallScreen ? 24 : 30),
                      ),
                      SizedBox(height: isVerySmallScreen ? 4 : 8),
                      Text(
                        'Menina',
                        style: GoogleFonts.poppins(
                          fontSize: isVerySmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedGender == 'Feminino'
                              ? Colors.white
                              : Colors.black87,
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

  Widget _buildAnimatedInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isFocused,
    required Function(bool) onFocusChange,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isVerySmallScreen = screenHeight < 650;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: isFocused
            ? const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              )
            : null,
        color: isFocused ? null : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isFocused ? const Color(0xFFFF8C42) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8C42).withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Focus(
        onFocusChange: onFocusChange,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          textCapitalization: textCapitalization,
          style: GoogleFonts.poppins(
            fontSize: isVerySmallScreen ? 14 : 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: isVerySmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? const Color(0xFFFF8C42) : Colors.grey[500],
              size: isVerySmallScreen ? 20 : 22,
            ),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 16 : 20,
              vertical: isVerySmallScreen ? 14 : 18,
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: isVerySmallScreen ? 10 : 12,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Stack(
            children: [
              // Fundo com gradiente mais colorido e infantil
              Container(
                width: double.infinity,
                height: screenHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4FC3F7), // Azul claro
                      Color(0xFF29B6F6), // Azul médio
                      Color(0xFFFF8A95), // Rosa claro
                      Color(0xFFFFB74D), // Laranja claro
                    ],
                  ),
                ),
              ),

              // Estrelas animadas no fundo
              ...List.generate(8, (index) {
                return AnimatedBuilder(
                  animation: _starAnimation,
                  builder: (context, child) {
                    final offset = (_starAnimation.value + index * 0.2) % 1.0;
                    return Positioned(
                      top: (screenHeight * 0.1) + (index * 80) + (offset * 50),
                      left: (index % 2 == 0)
                          ? screenWidth * 0.1 + (offset * 30)
                          : screenWidth * 0.8 + (offset * 30),
                      child: Transform.rotate(
                        angle: _starAnimation.value * 6.28,
                        child: Text(
                          index % 4 == 0
                              ? '⭐'
                              : index % 4 == 1
                                  ? '🌟'
                                  : index % 4 == 2
                                      ? '✨'
                                      : '💫',
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 16 : 20,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Logo no topo
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    top: isVerySmallScreen ? 10 : 20,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Lu',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'm',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            TextSpan(
                              text: 'm',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'y',
                              style: GoogleFonts.paytoneOne(
                                fontSize: isVerySmallScreen ? 28 : 32,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Personagem infantil animado
              Positioned(
                top: isVerySmallScreen
                    ? screenHeight * 0.08
                    : screenHeight * 0.10,
                left: screenWidth * 0.2,
                right: screenWidth * 0.2,
                child: AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _bounceAnimation.value,
                      child: Center(
                        child: Container(
                          height: isVerySmallScreen
                              ? 200
                              : (isSmallScreen ? 250 : 300),
                          width: isVerySmallScreen
                              ? 200
                              : (isSmallScreen ? 250 : 300),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(150),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '👶',
                              style: TextStyle(
                                fontSize: isVerySmallScreen
                                    ? 80
                                    : (isSmallScreen ? 100 : 120),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Formulário na parte inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FormTopClipper(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: isVerySmallScreen
                          ? screenHeight * 0.7
                          : screenHeight * 0.65,
                      maxHeight: isVerySmallScreen
                          ? screenHeight * 0.9
                          : screenHeight * 0.85,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isVerySmallScreen ? 20.0 : 24.0,
                        right: isVerySmallScreen ? 20.0 : 24.0,
                        top: isVerySmallScreen ? 20.0 : 24.0,
                        bottom:
                            (isVerySmallScreen ? 20.0 : 24.0) + keyboardHeight,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: isVerySmallScreen
                                    ? 15
                                    : (isSmallScreen ? 25 : 35)),

                            // Título com emoji
                            Row(
                              children: [
                                Text(
                                  '🎈 ',
                                  style: TextStyle(
                                      fontSize: isVerySmallScreen ? 24 : 28),
                                ),
                                Text(
                                  'Cadastrar Criança',
                                  style: GoogleFonts.poppins(
                                    fontSize: isVerySmallScreen ? 24 : 28,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2E3A59),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Campo Nome
                            _buildAnimatedInputField(
                              controller: _nameController,
                              hintText: 'Nome da criança',
                              icon: Icons.child_care,
                              isFocused: _nameFocused,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _nameFocused = hasFocus;
                                });
                              },
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o nome da criança';
                                }
                                if (value.trim().length < 2) {
                                  return 'Nome deve ter pelo menos 2 caracteres';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 10 : 14),

                            // Seletor de sexo
                            _buildGenderSelector(),

                            SizedBox(height: isVerySmallScreen ? 10 : 14),

                            // Campo Idade
                            _buildAnimatedInputField(
                              controller: _ageController,
                              hintText: 'Idade da criança',
                              icon: Icons.cake,
                              isFocused: _ageFocused,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _ageFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira a idade da criança';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 1 || age > 17) {
                                  return 'Idade deve ser entre 1 e 17 anos';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 10 : 14),

                            // Campo CPF
                            _buildAnimatedInputField(
                              controller: _cpfController,
                              hintText: 'CPF da criança',
                              icon: Icons.badge,
                              isFocused: _cpfFocused,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  final formatted = _formatCPF(newValue.text);
                                  return TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length),
                                  );
                                }),
                              ],
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _cpfFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o CPF da criança';
                                }
                                if (!_isValidCPF(value)) {
                                  return 'Por favor, insira um CPF válido';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 10 : 14),

                            // Campo E-mail
                            _buildAnimatedInputField(
                              controller: _emailController,
                              hintText: 'E-mail da criança',
                              icon: Icons.email,
                              isFocused: _emailFocused,
                              keyboardType: TextInputType.emailAddress,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _emailFocused = hasFocus;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o e-mail da criança';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 10 : 14),

                            // Campo Senha
                            _buildAnimatedInputField(
                              controller: _passwordController,
                              hintText: 'Senha da criança',
                              icon: Icons.lock,
                              isFocused: _passwordFocused,
                              obscureText: !_isPasswordVisible,
                              onFocusChange: (hasFocus) {
                                setState(() {
                                  _passwordFocused = hasFocus;
                                });
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _passwordFocused
                                      ? const Color(0xFFFF8C42)
                                      : Colors.grey[500],
                                  size: isVerySmallScreen ? 20 : 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira a senha da criança';
                                }
                                if (value.length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: isVerySmallScreen ? 20 : 25),

                            // Botão Cadastrar Criança
                            Container(
                              width: double.infinity,
                              height: isVerySmallScreen ? 50 : 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C42),
                                    Color(0xFFFF6B7A),
                                    Color(0xFF4FC3F7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    isVerySmallScreen ? 25 : 28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C42)
                                        .withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _handleRegisterChild,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        isVerySmallScreen ? 25 : 28),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: isVerySmallScreen ? 18 : 20,
                                        width: isVerySmallScreen ? 18 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '🎉 ',
                                            style: TextStyle(
                                                fontSize: isVerySmallScreen
                                                    ? 16
                                                    : 18),
                                          ),
                                          Text(
                                            'Cadastrar Criança',
                                            style: GoogleFonts.poppins(
                                              fontSize:
                                                  isVerySmallScreen ? 16 : 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),

                            // Botão para adicionar mais crianças
                            Center(
                              child: TextButton(
                                onPressed: () async {
                                  await _handleRegisterChild(); // 🔹 salva no Firestore

                                  // 🔹 se quiser limpar manualmente além do que já tem no método
                                  _formKey.currentState?.reset();
                                  _nameController.clear();
                                  _cpfController.clear();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _ageController.clear();
                                  setState(() {
                                    _selectedGender = '';
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '➕ ',
                                      style: TextStyle(
                                          fontSize:
                                              isVerySmallScreen ? 14 : 16),
                                    ),
                                    Text(
                                      'Adicionar outra criança',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF4FC3F7),
                                        fontSize: isVerySmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: isVerySmallScreen ? 15 : 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 60);

    path.quadraticBezierTo(
      size.width * 0.75,
      20,
      size.width * 0.5,
      20,
    );

    path.quadraticBezierTo(
      size.width * 0.25,
      20,
      0,
      60,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
