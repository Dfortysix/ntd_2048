// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'Score';

  @override
  String get bestScore => 'Meilleur';

  @override
  String get gameOver => '🍂 Plus de fruits !';

  @override
  String gameOverMessage(int score) {
    return 'Vous avez collecté $score fruits ! 🍎';
  }

  @override
  String get playAgain => 'Rejouer';

  @override
  String get swipeToMerge => 'Glissez pour fusionner les fruits similaires 🍎';

  @override
  String get undoHelp => 'Annuler le dernier coup';

  @override
  String undoHelpTooltip(int count) {
    return 'Annuler le dernier coup ($count restants)';
  }

  @override
  String get watchAdForHelp => 'Regarder une pub pour de l\'aide';

  @override
  String get removeCherryHelp => 'Supprimer toutes les cerises (2)';

  @override
  String get removeCherryHelpTooltip => 'Supprimer toutes les cerises (2)';

  @override
  String get addHelpMove => 'Ajouter un coup d\'aide';

  @override
  String get addHelpMoveMessage => 'Vous n\'avez plus de coups d\'aide !';

  @override
  String get freeMoveUsed => '• 1 coup gratuit utilisé';

  @override
  String get watchAdForMove => '• Regarder une pub pour 1 coup supplémentaire';

  @override
  String get adInfo => 'La pub s\'affichera pendant 15-30 secondes';

  @override
  String get cancel => 'Annuler';

  @override
  String get watchAd => 'Regarder la pub';

  @override
  String get helpMoveAdded => '🎉 Vous avez reçu 1 coup d\'aide supplémentaire !';

  @override
  String get addCherryHelp => 'Ajouter l\'aide de suppression de cerises';

  @override
  String get addCherryHelpMessage => 'Vous n\'avez plus d\'aide de suppression de cerises !';

  @override
  String get watchAdForCherry => '• Regarder une pub pour 1 suppression de cerise supplémentaire';

  @override
  String get cherryHelpAdded => '🎉 Vous avez reçu 1 aide de suppression de cerise supplémentaire !';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get music => 'Musique';

  @override
  String get sound => 'Son';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Développeur';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'Guide des fruits';

  @override
  String get cherry => 'Cerise';

  @override
  String get strawberry => 'Fraise';

  @override
  String get grape => 'Raisin';

  @override
  String get orange => 'Orange';

  @override
  String get apple => 'Pomme';

  @override
  String get pear => 'Poire';

  @override
  String get peach => 'Pêche';

  @override
  String get mango => 'Mangue';

  @override
  String get pineapple => 'Ananas';

  @override
  String get watermelon => 'Pastèque';

  @override
  String get melon => 'Melon';

  @override
  String get coconut => 'Noix de coco';

  @override
  String get magicBasket => 'Panier magique';
}
