import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/app_log.dart';

/// As 3 cores de tema que a criança pode escolher (DECISOES 13).
enum ChildThemeColor {
  /// Azul Lummy, o padrão.
  lummy(LummyColors.themeLummy, 'Azul Lummy'),

  /// Índigo.
  indigo(LummyColors.themeIndigo, 'Índigo'),

  /// Azul-petróleo. No menu lateral o rótulo é "Petróleo" (texto do mockup).
  petroleo(LummyColors.themePetrol, 'Petróleo');

  const ChildThemeColor(this.color, this.label);

  /// A cor do tema.
  final Color color;

  /// Rótulo mostrado embaixo da bolinha no menu lateral e no Perfil.
  final String label;
}

/// Cor do tema da área da criança, escolhida por ela e salva por criança.
///
/// Provido na raiz do app (`lib/main.dart`), para valer também dentro de
/// painéis de baixo e diálogos (que são rotas acima da navegação da criança).
///
/// Como usar numa tela:
/// ```dart
/// final cores = context.watch<ChildThemeColorController>();
/// Container(color: cores.tema);            // azul do tema
/// Container(color: cores.spaceBase);       // fundo escuro do cartão espacial
/// RadialGradient(colors: [cores.spaceGlow, Colors.transparent]);
/// ```
/// Ou o atalho `ChildThemeColorController.of(context)` (equivale ao watch).
///
/// Persistência: SharedPreferences, chave `child_theme_color_<childId>`, com o
/// nome da opção (`lummy`, `indigo`, `petroleo`). Sem escolha salva = Azul Lummy.
class ChildThemeColorController extends ChangeNotifier {
  static const String _keyPrefix = 'child_theme_color_';

  ChildThemeColor _opcao = ChildThemeColor.lummy;
  String? _childId;

  /// Opção escolhida.
  ChildThemeColor get opcao => _opcao;

  /// As opções, na ordem do menu lateral.
  List<ChildThemeColor> get opcoes => ChildThemeColor.values;

  /// Cor do tema (`{{tema}}` do mockup).
  Color get tema => _opcao.color;

  /// Fundo escuro do cartão espacial (`{{spaceBase}}`): tema × 0,38.
  Color get spaceBase => spaceBaseOf(tema);

  /// Brilho atrás do astronauta (`{{spaceGlow}}`): tema com alfa 0,6.
  Color get spaceGlow => spaceGlowOf(tema);

  /// Atalho para `context.watch<ChildThemeColorController>()`.
  static ChildThemeColorController of(BuildContext context) =>
      context.watch<ChildThemeColorController>();

  /// Cada canal RGB × 0,38, arredondado como o `Math.round` do mockup.
  static Color spaceBaseOf(Color tema) {
    final argb = tema.toARGB32();
    int canal(int shift) => (((argb >> shift) & 0xFF) * 0.38).round();
    return Color.fromARGB(0xFF, canal(16), canal(8), canal(0));
  }

  /// A cor do tema com alfa 0,6.
  static Color spaceGlowOf(Color tema) => tema.withValues(alpha: 0.6);

  /// Carrega a cor salva da criança logada (chamado ao entrar na área da
  /// criança, em `MainNavigation`). Sem usuário logado, volta ao padrão.
  Future<void> loadForCurrentUser() async {
    final id = Supabase.instance.client.auth.currentUser?.id;
    if (id == null || id.isEmpty) {
      reset();
      return;
    }
    await loadForChild(id);
  }

  /// Carrega a cor salva para [childId].
  Future<void> loadForChild(String childId) async {
    _childId = childId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvo = prefs.getString('$_keyPrefix$childId');
      final opcao = ChildThemeColor.values.firstWhere(
        (o) => o.name == salvo,
        orElse: () => ChildThemeColor.lummy,
      );
      // A criança pode ter trocado de conta enquanto o await rodava.
      if (_childId != childId) return;
      if (opcao != _opcao) {
        _opcao = opcao;
        notifyListeners();
      }
    } catch (e) {
      appLog('⚠️ Cor do tema: não foi possível ler a preferência: $e');
    }
  }

  /// Troca a cor na hora e salva para a criança atual.
  Future<void> selecionar(ChildThemeColor opcao) async {
    if (opcao != _opcao) {
      _opcao = opcao;
      notifyListeners();
    }
    final id = _childId ?? Supabase.instance.client.auth.currentUser?.id;
    if (id == null || id.isEmpty) return;
    _childId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$id', opcao.name);
    } catch (e) {
      appLog('⚠️ Cor do tema: não foi possível salvar a preferência: $e');
    }
  }

  /// Volta ao Azul Lummy e esquece a criança (chamado ao sair da conta).
  void reset() {
    _childId = null;
    if (_opcao != ChildThemeColor.lummy) {
      _opcao = ChildThemeColor.lummy;
      notifyListeners();
    }
  }
}
