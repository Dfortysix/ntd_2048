// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'Score';

  @override
  String get bestScore => 'Best';

  @override
  String get gameOver => '🍂 No more fruits!';

  @override
  String gameOverMessage(int score) {
    return 'You collected $score fruits! 🍎';
  }

  @override
  String get playAgain => 'Play Again';

  @override
  String get swipeToMerge => 'Swipe to merge similar fruits 🍎';

  @override
  String get undoHelp => 'Undo last move';

  @override
  String undoHelpTooltip(int count) {
    return 'Undo last move ($count left)';
  }

  @override
  String get watchAdForHelp => 'Watch ad for help';

  @override
  String get removeCherryHelp => 'Remove all Cherry tiles (2)';

  @override
  String get removeCherryHelpTooltip => 'Remove all Cherry tiles (2)';

  @override
  String get addHelpMove => 'Add help move';

  @override
  String get addHelpMoveMessage => 'You\'re out of help moves!';

  @override
  String get freeMoveUsed => '• 1 free move used';

  @override
  String get watchAdForMove => '• Watch ad to get 1 more move';

  @override
  String get adInfo => 'Ad will show for 15-30 seconds';

  @override
  String get cancel => 'Cancel';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get helpMoveAdded => '🎉 You got 1 more help move!';

  @override
  String get addCherryHelp => 'Add Cherry removal help';

  @override
  String get addCherryHelpMessage => 'You\'re out of Cherry removal help!';

  @override
  String get watchAdForCherry => '• Watch ad to get 1 more Cherry removal';

  @override
  String get cherryHelpAdded => '🎉 You got 1 more Cherry removal help!';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get music => 'Music';

  @override
  String get sound => 'Sound';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'Fruit Guide';

  @override
  String get cherry => 'Cherry';

  @override
  String get strawberry => 'Strawberry';

  @override
  String get grape => 'Grape';

  @override
  String get orange => 'Orange';

  @override
  String get apple => 'Apple';

  @override
  String get pear => 'Pear';

  @override
  String get peach => 'Peach';

  @override
  String get mango => 'Mango';

  @override
  String get pineapple => 'Pineapple';

  @override
  String get watermelon => 'Watermelon';

  @override
  String get melon => 'Melon';

  @override
  String get coconut => 'Coconut';

  @override
  String get magicBasket => 'Magic Basket';
}
