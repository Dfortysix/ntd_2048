// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'Pontuação';

  @override
  String get bestScore => 'Melhor';

  @override
  String get gameOver => '🍂 Sem mais frutas!';

  @override
  String gameOverMessage(int score) {
    return 'Você coletou $score frutas! 🍎';
  }

  @override
  String get playAgain => 'Jogar novamente';

  @override
  String get swipeToMerge => 'Deslize para fundir frutas similares 🍎';

  @override
  String get undoHelp => 'Desfazer último movimento';

  @override
  String undoHelpTooltip(int count) {
    return 'Desfazer último movimento ($count restantes)';
  }

  @override
  String get watchAdForHelp => 'Assistir anúncio para ajuda';

  @override
  String get removeCherryHelp => 'Remover todas as cerejas (2)';

  @override
  String get removeCherryHelpTooltip => 'Remover todas as cerejas (2)';

  @override
  String get addHelpMove => 'Adicionar movimento de ajuda';

  @override
  String get addHelpMoveMessage => 'Você ficou sem movimentos de ajuda!';

  @override
  String get freeMoveUsed => '• 1 movimento gratuito usado';

  @override
  String get watchAdForMove => '• Assistir anúncio para 1 movimento mais';

  @override
  String get adInfo => 'O anúncio será exibido por 15-30 segundos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get watchAd => 'Assistir anúncio';

  @override
  String get helpMoveAdded => '🎉 Você recebeu 1 movimento de ajuda a mais!';

  @override
  String get addCherryHelp => 'Adicionar ajuda de remoção de cerejas';

  @override
  String get addCherryHelpMessage => 'Você ficou sem ajuda de remoção de cerejas!';

  @override
  String get watchAdForCherry => '• Assistir anúncio para 1 remoção de cereja a mais';

  @override
  String get cherryHelpAdded => '🎉 Você recebeu 1 ajuda de remoção de cereja a mais!';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get music => 'Música';

  @override
  String get sound => 'Som';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get developer => 'Desenvolvedor';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'Guia de frutas';

  @override
  String get cherry => 'Cereja';

  @override
  String get strawberry => 'Morango';

  @override
  String get grape => 'Uva';

  @override
  String get orange => 'Laranja';

  @override
  String get apple => 'Maçã';

  @override
  String get pear => 'Pera';

  @override
  String get peach => 'Pêssego';

  @override
  String get mango => 'Manga';

  @override
  String get pineapple => 'Abacaxi';

  @override
  String get watermelon => 'Melancia';

  @override
  String get melon => 'Melão';

  @override
  String get coconut => 'Coco';

  @override
  String get magicBasket => 'Cesta mágica';
}
