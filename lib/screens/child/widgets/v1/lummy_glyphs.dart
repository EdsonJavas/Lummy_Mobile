// ARQUIVO GERADO pelo arquiteto (VINGADORES) a partir do mockup aprovado.
// Não edite à mão sem necessidade: para incluir um ícone novo, copie o corpo
// do SVG Lucide (viewBox 0 0 24 24) e acrescente uma constante no mesmo formato.
//
// Origem de cada corpo:
// - "mockup": paths copiados LITERALMENTE dos arquivos *.dc.html aprovados
//   (alguns são versões antigas do desenho Lucide; o mockup manda).
// - "pacote": paths do lucide_icons_flutter 4.0.3 (ícones que o mockup não tem).

import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Um ícone Lucide: o corpo SVG (para desenhar com traço e preenchimento
/// exatos do mockup) e o [IconData] equivalente do pacote (para APIs que só
/// aceitam [IconData], como `Icon` ou `SnackBar`).
@immutable
class LummyGlyph {
  const LummyGlyph(this.name, this.iconData, this.svgBody);

  /// Nome Lucide (kebab-case), só para depuração e documentação.
  final String name;

  /// Mesmo ícone na fonte do pacote `lucide_icons_flutter` (traço fixo 2).
  final IconData iconData;

  /// Elementos internos do `<svg viewBox="0 0 24 24">`, sem cor nem traço.
  final String svgBody;
}

/// Catálogo de ícones da área da criança (redesenho V1).
abstract final class LummyGlyphs {
  /// `x` (mockup)
  static const x = LummyGlyph(
    'x',
    LucideIcons.x,
    r'<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  );

  /// `utensils` (mockup)
  static const utensils = LummyGlyph(
    'utensils',
    LucideIcons.utensils,
    r'<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"/>',
  );

  /// `gamepad-2` (mockup)
  static const gamepad2 = LummyGlyph(
    'gamepad-2',
    LucideIcons.gamepad2,
    r'<line x1="6" x2="10" y1="11" y2="11"/><line x1="8" x2="8" y1="9" y2="13"/><line x1="15" x2="15.01" y1="12" y2="12"/><line x1="18" x2="18.01" y1="10" y2="10"/><path d="M17.32 5H6.68a4 4 0 0 0-3.978 3.59c-.006.052-.01.101-.017.152C2.604 9.416 2 14.456 2 16a3 3 0 0 0 3 3c1 0 1.5-.5 2-1l1.414-1.414A2 2 0 0 1 9.828 16h4.344a2 2 0 0 1 1.414.586L17 18c.5.5 1 1 2 1a3 3 0 0 0 3-3c0-1.545-.604-6.584-.685-7.258-.007-.05-.011-.1-.017-.151A4 4 0 0 0 17.32 5z"/>',
  );

  /// `graduation-cap` (mockup)
  static const graduationCap = LummyGlyph(
    'graduation-cap',
    LucideIcons.graduationCap,
    r'<path d="M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z"/><path d="M22 10v6"/><path d="M6 12.5V16a6 3 0 0 0 12 0v-3.5"/>',
  );

  /// `shirt` (mockup)
  static const shirt = LummyGlyph(
    'shirt',
    LucideIcons.shirt,
    r'<path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/>',
  );

  /// `puzzle` (mockup)
  static const puzzle = LummyGlyph(
    'puzzle',
    LucideIcons.puzzle,
    r'<path d="M19.439 7.85c-.049.322.059.648.289.878l1.568 1.568c.47.47.706 1.087.706 1.704s-.235 1.233-.706 1.704l-1.611 1.611a.98.98 0 0 1-.837.276c-.47-.07-.802-.48-.968-.925a2.501 2.501 0 1 0-3.214 3.214c.446.166.855.497.925.968a.979.979 0 0 1-.276.837l-1.61 1.61a2.404 2.404 0 0 1-1.705.707 2.402 2.402 0 0 1-1.704-.706l-1.568-1.568a1.026 1.026 0 0 0-.877-.29c-.493.074-.84.504-1.02.968a2.5 2.5 0 1 1-3.237-3.237c.464-.18.894-.527.967-1.02a1.026 1.026 0 0 0-.289-.877l-1.568-1.568A2.402 2.402 0 0 1 1.998 12c0-.617.236-1.234.706-1.704L4.23 8.77c.24-.24.581-.353.917-.303.515.077.877.528 1.073 1.01a2.5 2.5 0 1 0 3.259-3.259c-.482-.196-.933-.558-1.01-1.073-.05-.336.062-.676.303-.917l1.525-1.525A2.402 2.402 0 0 1 12 1.998c.617 0 1.234.236 1.704.706l1.568 1.568c.23.23.556.338.877.29.493-.074.84-.504 1.02-.968a2.5 2.5 0 1 1 3.237 3.237c-.464.18-.894.527-.967 1.02Z"/>',
  );

  /// `ticket` (mockup)
  static const ticket = LummyGlyph(
    'ticket',
    LucideIcons.ticket,
    r'<path d="M2 9a3 3 0 0 1 0 6v2a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-2a3 3 0 0 1 0-6V7a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2Z"/><path d="M13 5v2"/><path d="M13 17v2"/><path d="M13 11v2"/>',
  );

  /// `volleyball` (mockup)
  static const volleyball = LummyGlyph(
    'volleyball',
    LucideIcons.volleyball,
    r'<path d="M11.1 7.1a16.55 16.55 0 0 1 10.9 4"/><path d="M12 12a12.6 12.6 0 0 1-8.7 5"/><path d="M16.8 13.6a16.55 16.55 0 0 1-9 7.5"/><path d="M20.7 17a12.8 12.8 0 0 0-8.7-5 13.3 13.3 0 0 1 0-10"/><path d="M6.3 3.8a16.55 16.55 0 0 0 1.9 11.5"/><circle cx="12" cy="12" r="10"/>',
  );

  /// `ellipsis` (mockup)
  static const ellipsis = LummyGlyph(
    'ellipsis',
    LucideIcons.ellipsis,
    r'<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>',
  );

  /// `delete` (mockup)
  static const delete = LummyGlyph(
    'delete',
    LucideIcons.delete,
    r'<path d="M10 5a2 2 0 0 0-1.344.519l-6.328 5.74a1 1 0 0 0 0 1.481l6.328 5.741A2 2 0 0 0 10 19h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2z"/><path d="m12 9 6 6"/><path d="m18 9-6 6"/>',
  );

  /// `chevron-right` (mockup)
  static const chevronRight = LummyGlyph(
    'chevron-right',
    LucideIcons.chevronRight,
    r'<path d="m9 18 6-6-6-6"/>',
  );

  /// `list-checks` (mockup)
  static const listChecks = LummyGlyph(
    'list-checks',
    LucideIcons.listChecks,
    r'<path d="m3 17 2 2 4-4"/><path d="m3 7 2 2 4-4"/><path d="M13 6h8"/><path d="M13 12h8"/><path d="M13 18h8"/>',
  );

  /// `trophy` (mockup)
  static const trophy = LummyGlyph(
    'trophy',
    LucideIcons.trophy,
    r'<path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/>',
  );

  /// `coins` (mockup)
  static const coins = LummyGlyph(
    'coins',
    LucideIcons.coins,
    r'<circle cx="8" cy="8" r="6"/><path d="M18.09 10.37A6 6 0 1 1 10.34 18"/><path d="M7 6h1v4"/><path d="m16.71 13.88.7.71-2.82 2.82"/>',
  );

  /// `bell` (mockup)
  static const bell = LummyGlyph(
    'bell',
    LucideIcons.bell,
    r'<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
  );

  /// `settings` (mockup)
  static const settings = LummyGlyph(
    'settings',
    LucideIcons.settings,
    r'<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/>',
  );

  /// `check` (mockup)
  static const check = LummyGlyph(
    'check',
    LucideIcons.check,
    r'<path d="M20 6 9 17l-5-5"/>',
  );

  /// `log-out` (mockup)
  static const logOut = LummyGlyph(
    'log-out',
    LucideIcons.logOut,
    r'<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/>',
  );

  /// `house` (mockup)
  static const house = LummyGlyph(
    'house',
    LucideIcons.house,
    r'<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M9 22V12h6v10"/>',
  );

  /// `receipt` (mockup)
  static const receipt = LummyGlyph(
    'receipt',
    LucideIcons.receipt,
    r'<path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1Z"/><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"/><path d="M12 17.5v-11"/>',
  );

  /// `flag` (mockup)
  static const flag = LummyGlyph(
    'flag',
    LucideIcons.flag,
    r'<path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><path d="M4 22v-7"/>',
  );

  /// `book-open` (mockup)
  static const bookOpen = LummyGlyph(
    'book-open',
    LucideIcons.bookOpen,
    r'<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  );

  /// `shopping-bag` (mockup)
  static const shoppingBag = LummyGlyph(
    'shopping-bag',
    LucideIcons.shoppingBag,
    r'<path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><path d="M3 6h18"/><path d="M16 10a4 4 0 0 1-8 0"/>',
  );

  /// `trending-down` (mockup)
  static const trendingDown = LummyGlyph(
    'trending-down',
    LucideIcons.trendingDown,
    r'<path d="M16 17h6v-6"/><path d="m22 17-8.5-8.5-5 5L2 7"/>',
  );

  /// `flame` (mockup)
  static const flame = LummyGlyph(
    'flame',
    LucideIcons.flame,
    r'<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>',
  );

  /// `star` (mockup)
  static const star = LummyGlyph(
    'star',
    LucideIcons.star,
    r'<path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>',
  );

  /// `target` (mockup)
  static const target = LummyGlyph(
    'target',
    LucideIcons.target,
    r'<circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/>',
  );

  /// `gift` (mockup)
  static const gift = LummyGlyph(
    'gift',
    LucideIcons.gift,
    r'<rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13"/><path d="M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7"/><path d="M7.5 8a2.5 2.5 0 0 1 0-5A4.8 8 0 0 1 12 8a4.8 8 0 0 1 4.5-5 2.5 2.5 0 0 1 0 5"/>',
  );

  /// `zap` (mockup)
  static const zap = LummyGlyph(
    'zap',
    LucideIcons.zap,
    r'<path d="M13 2 3 14h9l-1 8 10-12h-9l1-8z"/>',
  );

  /// `play` (mockup)
  static const play = LummyGlyph(
    'play',
    LucideIcons.play,
    r'<path d="M6 3 20 12 6 21Z"/>',
  );

  /// `lock` (mockup)
  static const lock = LummyGlyph(
    'lock',
    LucideIcons.lock,
    r'<rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
  );

  /// `rocket` (mockup)
  static const rocket = LummyGlyph(
    'rocket',
    LucideIcons.rocket,
    r'<path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/><path d="m12 15-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/><path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"/><path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"/>',
  );

  /// `bike` (mockup)
  static const bike = LummyGlyph(
    'bike',
    LucideIcons.bike,
    r'<circle cx="18.5" cy="17.5" r="3.5"/><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="15" cy="5" r="1"/><path d="M12 17.5V14l-3-3 4-3 2 3h2"/>',
  );

  /// `calendar` (mockup)
  static const calendar = LummyGlyph(
    'calendar',
    LucideIcons.calendar,
    r'<path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/>',
  );

  /// `info` (mockup)
  static const info = LummyGlyph(
    'info',
    LucideIcons.info,
    r'<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>',
  );

  /// `headphones` (mockup)
  static const headphones = LummyGlyph(
    'headphones',
    LucideIcons.headphones,
    r'<path d="M3 14h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a9 9 0 0 1 18 0v7a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3"/>',
  );

  /// `pen` (mockup)
  static const pen = LummyGlyph(
    'pen',
    LucideIcons.pen,
    r'<path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/>',
  );

  /// `trash` (mockup)
  static const trash = LummyGlyph(
    'trash',
    LucideIcons.trash,
    r'<path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/>',
  );

  /// `hand-coins` (pacote)
  static const handCoins = LummyGlyph(
    'hand-coins',
    LucideIcons.handCoins,
    r'<path d="M11 15h2a2 2 0 1 0 0-4h-3c-.6 0-1.1.2-1.4.6L3 17"/><path d="m7 21 1.6-1.4c.3-.4.8-.6 1.4-.6h4c1.1 0 2.1-.4 2.8-1.2l4.6-4.4a2 2 0 0 0-2.75-2.91l-4.2 3.9"/><path d="m2 16 6 6"/><circle cx="16" cy="9" r="2.9"/><circle cx="6" cy="5" r="3"/>',
  );

  /// `circle-plus` (pacote)
  static const circlePlus = LummyGlyph(
    'circle-plus',
    LucideIcons.circlePlus,
    r'<circle cx="12" cy="12" r="10"/><path d="M8 12h8"/><path d="M12 8v8"/>',
  );

  /// `trending-up` (pacote)
  static const trendingUp = LummyGlyph(
    'trending-up',
    LucideIcons.trendingUp,
    r'<path d="M16 7h6v6"/><path d="m22 7-8.5 8.5-5-5L2 17"/>',
  );

  /// `smartphone` (pacote)
  static const smartphone = LummyGlyph(
    'smartphone',
    LucideIcons.smartphone,
    r'<rect width="14" height="20" x="5" y="2" rx="2" ry="2"/><path d="M12 18h.01"/>',
  );

  /// `laptop` (pacote)
  static const laptop = LummyGlyph(
    'laptop',
    LucideIcons.laptop,
    r'<path d="M18 5a2 2 0 0 1 2 2v8.526a2 2 0 0 0 .212.897l1.068 2.127a1 1 0 0 1-.9 1.45H3.62a1 1 0 0 1-.9-1.45l1.068-2.127A2 2 0 0 0 4 15.526V7a2 2 0 0 1 2-2z"/><path d="M20.054 15.987H3.946"/>',
  );

  /// `guitar` (pacote)
  static const guitar = LummyGlyph(
    'guitar',
    LucideIcons.guitar,
    r'<path d="m11.9 12.1 4.514-4.514"/><path d="M20.1 2.3a1 1 0 0 0-1.4 0l-1.114 1.114A2 2 0 0 0 17 4.828v1.344a2 2 0 0 1-.586 1.414A2 2 0 0 1 17.828 7h1.344a2 2 0 0 0 1.414-.586L21.7 5.3a1 1 0 0 0 0-1.4z"/><path d="m6 16 2 2"/><path d="M8.23 9.85A3 3 0 0 1 11 8a5 5 0 0 1 5 5 3 3 0 0 1-1.85 2.77l-.92.38A2 2 0 0 0 12 18a4 4 0 0 1-4 4 6 6 0 0 1-6-6 4 4 0 0 1 4-4 2 2 0 0 0 1.85-1.23z"/>',
  );

  /// `palette` (pacote)
  static const palette = LummyGlyph(
    'palette',
    LucideIcons.palette,
    r'<path d="M12 22a1 1 0 0 1 0-20 10 9 0 0 1 10 9 5 5 0 0 1-5 5h-2.25a1.75 1.75 0 0 0-1.4 2.8l.3.4a1.75 1.75 0 0 1-1.4 2.8z"/><circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/><circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/><circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/><circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/>',
  );

  /// `footprints` (pacote)
  static const footprints = LummyGlyph(
    'footprints',
    LucideIcons.footprints,
    r'<path d="M4 16v-2.38C4 11.5 2.97 10.5 3 8c.03-2.72 1.49-6 4.5-6C9.37 2 10 3.8 10 5.5c0 3.11-2 5.66-2 8.68V16a2 2 0 1 1-4 0Z"/><path d="M20 20v-2.38c0-2.12 1.03-3.12 1-5.62-.03-2.72-1.49-6-4.5-6C14.63 6 14 7.8 14 9.5c0 3.11 2 5.66 2 8.68V20a2 2 0 1 0 4 0Z"/><path d="M16 17h4"/><path d="M4 13h4"/>',
  );

  /// `backpack` (pacote)
  static const backpack = LummyGlyph(
    'backpack',
    LucideIcons.backpack,
    r'<path d="M4 10a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><path d="M8 10h8"/><path d="M8 18h8"/><path d="M8 22v-6a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v6"/><path d="M9 6V4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v2"/>',
  );

  /// `banknote` (pacote)
  static const banknote = LummyGlyph(
    'banknote',
    LucideIcons.banknote,
    r'<rect width="20" height="12" x="2" y="6" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/>',
  );

  /// `briefcase` (pacote)
  static const briefcase = LummyGlyph(
    'briefcase',
    LucideIcons.briefcase,
    r'<path d="M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/><rect width="20" height="14" x="2" y="6" rx="2"/>',
  );

  /// `pencil` (pacote)
  static const pencil = LummyGlyph(
    'pencil',
    LucideIcons.pencil,
    r'<path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/><path d="m15 5 4 4"/>',
  );

  /// `user` (pacote)
  static const user = LummyGlyph(
    'user',
    LucideIcons.user,
    r'<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  );
}
