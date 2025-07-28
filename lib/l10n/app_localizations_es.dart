// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'Puntuación';

  @override
  String get bestScore => 'Mejor';

  @override
  String get gameOver => '🍂 ¡No hay más frutas!';

  @override
  String gameOverMessage(int score) {
    return '¡Has recolectado $score frutas! 🍎';
  }

  @override
  String get playAgain => 'Jugar de nuevo';

  @override
  String get swipeToMerge => 'Desliza para fusionar frutas similares 🍎';

  @override
  String get undoHelp => 'Deshacer último movimiento';

  @override
  String undoHelpTooltip(int count) {
    return 'Deshacer último movimiento ($count restantes)';
  }

  @override
  String get watchAdForHelp => 'Ver anuncio para ayuda';

  @override
  String get removeCherryHelp => 'Eliminar todas las cerezas (2)';

  @override
  String get removeCherryHelpTooltip => 'Eliminar todas las cerezas (2)';

  @override
  String get addHelpMove => 'Agregar movimiento de ayuda';

  @override
  String get addHelpMoveMessage => '¡Te has quedado sin movimientos de ayuda!';

  @override
  String get freeMoveUsed => '• 1 movimiento gratuito usado';

  @override
  String get watchAdForMove => '• Ver anuncio para 1 movimiento más';

  @override
  String get adInfo => 'El anuncio se mostrará durante 15-30 segundos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get watchAd => 'Ver anuncio';

  @override
  String get helpMoveAdded => '🎉 ¡Has recibido 1 movimiento de ayuda más!';

  @override
  String get addCherryHelp => 'Agregar ayuda de eliminación de cerezas';

  @override
  String get addCherryHelpMessage => '¡Te has quedado sin ayuda de eliminación de cerezas!';

  @override
  String get watchAdForCherry => '• Ver anuncio para 1 eliminación de cereza más';

  @override
  String get cherryHelpAdded => '🎉 ¡Has recibido 1 ayuda de eliminación de cereza más!';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get music => 'Música';

  @override
  String get sound => 'Sonido';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollador';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'Guía de frutas';

  @override
  String get cherry => 'Cereza';

  @override
  String get strawberry => 'Fresa';

  @override
  String get grape => 'Uva';

  @override
  String get orange => 'Naranja';

  @override
  String get apple => 'Manzana';

  @override
  String get pear => 'Pera';

  @override
  String get peach => 'Melocotón';

  @override
  String get mango => 'Mango';

  @override
  String get pineapple => 'Piña';

  @override
  String get watermelon => 'Sandía';

  @override
  String get melon => 'Melón';

  @override
  String get coconut => 'Coco';

  @override
  String get magicBasket => 'Cesta mágica';
}
