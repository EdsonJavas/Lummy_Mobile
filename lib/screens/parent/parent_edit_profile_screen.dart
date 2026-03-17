import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';

class ParentEditProfileScreen extends StatefulWidget {
  final String parentId;
  final String initialName;
  final String initialEmail;
  final String? initialAvatarUrl;

  const ParentEditProfileScreen({
    super.key,
    required this.parentId,
    required this.initialName,
    required this.initialEmail,
    this.initialAvatarUrl,
  });

  @override
  State<ParentEditProfileScreen> createState() => _ParentEditProfileScreenState();
}

class _ParentEditProfileScreenState extends State<ParentEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isLoading = false;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;

  static const _purple = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _avatarUrl = widget.initialAvatarUrl;
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (file == null || !mounted) return;

      setState(() => _isUploadingAvatar = true);
      final supabase = Supabase.instance.client;
      final ext = file.path.split('.').last;
      final path = '${widget.parentId}.$ext';

      await supabase.storage.from('avatars').upload(
        path,
        File(file.path),
        fileOptions: const FileOptions(upsert: true),
      );
      final url = supabase.storage.from('avatars').getPublicUrl(path);

      await supabase.from('responsaveis').update({'avatar_url': url}).eq('id', widget.parentId);

      if (mounted) {
        setState(() {
          _avatarUrl = url;
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Foto atualizada!', style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao enviar foto. Verifique se o bucket "avatars" existe no Supabase.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final currentEmail = supabase.auth.currentUser?.email ?? '';

      final updateData = <String, dynamic>{'nome': newName, 'email': newEmail};
      await supabase.from('responsaveis').update(updateData).eq('id', widget.parentId);

      // Se o e-mail mudou, atualizar no Auth (pode exigir confirmação no Supabase)
      if (newEmail != currentEmail && newEmail.isNotEmpty) {
        await supabase.auth.updateUser(UserAttributes(email: newEmail));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                'Perfil atualizado com sucesso.',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message.contains('already') ? 'Este e-mail já está em uso.' : e.message,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar. Tente novamente.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Editar perfil',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _isUploadingAvatar ? null : _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? CachedAvatar(
                              imageUrl: _avatarUrl!,
                              size: 100,
                              borderColor: _purple,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: _purple.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _purple, width: 2),
                              ),
                              child: const Icon(Icons.person_rounded, size: 48, color: _purple),
                            ),
                      if (_isUploadingAvatar)
                        const Positioned.fill(
                          child: Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _purple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _purple.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Altere seu nome e e-mail. O e-mail é usado para login.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Seu nome completo',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Insira seu nome';
                  if (v.trim().length < 2) return 'Nome muito curto';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'seu@email.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Insira seu e-mail';
                  if (!RegExp(r'^[\w-\.]+@[\w-]+\.[\w-]{2,4}$').hasMatch(v.trim())) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Salvar alterações',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
