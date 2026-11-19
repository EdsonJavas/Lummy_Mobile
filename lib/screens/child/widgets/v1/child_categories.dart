import 'lummy_glyphs.dart';

/// Categoria de gasto como a criança vê (DECISOES 10).
///
/// O [id] é o valor gravado em `transactions.category` e em
/// `children.allowed_categories`; NÃO mude. Só o nome e o ícone são novos.
class ChildExpenseCategory {
  const ChildExpenseCategory(this.id, this.nome, this.glyph);

  /// Id no banco (`food`, `games`, ...).
  final String id;

  /// Nome mostrado ("Comida", "Jogos", ...). Também é a descrição gravada
  /// no gasto feito pelo painel (DECISOES 19).
  final String nome;

  /// Ícone Lucide.
  final LummyGlyph glyph;

  /// Traço do ícone. "Outros" (três pontos) usa 2.4 no mockup; os demais
  /// usam [base] (2 normal, 2.1 na categoria escolhida do painel).
  double traco(double base) => id == 'other' ? 2.4 : base;

  @override
  bool operator ==(Object other) =>
      other is ChildExpenseCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Catálogo de categorias de gasto, na ordem do painel "Anotar gasto".
abstract final class ChildCategories {
  static const food = ChildExpenseCategory('food', 'Comida', LummyGlyphs.utensils);
  static const games = ChildExpenseCategory('games', 'Jogos', LummyGlyphs.gamepad2);
  static const education =
      ChildExpenseCategory('education', 'Educação', LummyGlyphs.graduationCap);
  static const clothes = ChildExpenseCategory('clothes', 'Roupas', LummyGlyphs.shirt);
  static const toys = ChildExpenseCategory('toys', 'Brinquedos', LummyGlyphs.puzzle);
  static const entertainment =
      ChildExpenseCategory('entertainment', 'Diversão', LummyGlyphs.ticket);
  static const sports =
      ChildExpenseCategory('sports', 'Esportes', LummyGlyphs.volleyball);
  static const other = ChildExpenseCategory('other', 'Outros', LummyGlyphs.ellipsis);

  /// Todas, na ordem da tabela do DECISOES 10.
  static const todas = <ChildExpenseCategory>[
    food,
    games,
    education,
    clothes,
    toys,
    entertainment,
    sports,
    other,
  ];

  /// Categoria pelo id do banco. Id desconhecido (dado antigo) vira uma
  /// categoria com o próprio id como nome e o ícone de "Outros".
  static ChildExpenseCategory porId(String? id) {
    final limpo = (id ?? '').trim();
    for (final c in todas) {
      if (c.id == limpo) return c;
    }
    if (limpo.isEmpty) return other;
    return ChildExpenseCategory(limpo, limpo, LummyGlyphs.ellipsis);
  }

  /// As categorias que a criança pode usar, na ordem de [todas].
  ///
  /// Mesma regra de hoje (`expenses_screen.dart`): lista vazia/nula, ou
  /// nenhuma coincidência, libera as 8.
  static List<ChildExpenseCategory> permitidas(Iterable<String>? allowedIds) {
    final ids = (allowedIds ?? const <String>[]).map((e) => e.trim()).toSet();
    if (ids.isEmpty) return List.of(todas);
    final filtradas = todas.where((c) => ids.contains(c.id)).toList();
    return filtradas.isEmpty ? List.of(todas) : filtradas;
  }
}

/// Origem do dinheiro ganho (painel "Registrar dinheiro que ganhei", D18).
///
/// O [id] é o valor que a tela antiga grava em `transactions.category` para
/// ganhos (`add_expense_screen.dart`, `_incomeCategories`): o próprio nome.
class ChildIncomeOrigin {
  const ChildIncomeOrigin(this.id, this.nome, this.glyph);

  /// Valor gravado em `transactions.category` (igual à tela antiga).
  final String id;

  /// Nome mostrado.
  final String nome;

  /// Ícone Lucide (escolha do arquiteto; a tela antiga usava emoji).
  final LummyGlyph glyph;

  double traco(double base) => id == 'Outros' ? 2.4 : base;
}

/// Origens de ganho, na ordem da tela antiga.
abstract final class ChildIncomeOrigins {
  static const todas = <ChildIncomeOrigin>[
    ChildIncomeOrigin('Mesada', 'Mesada', LummyGlyphs.banknote),
    ChildIncomeOrigin('Presente', 'Presente', LummyGlyphs.gift),
    ChildIncomeOrigin('Trabalho', 'Trabalho', LummyGlyphs.briefcase),
    ChildIncomeOrigin('Outros', 'Outros', LummyGlyphs.ellipsis),
  ];
}
