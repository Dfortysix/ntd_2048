import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'🍎 Fruits 2048'**
  String get appTitle;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestScore;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'🍂 No more fruits!'**
  String get gameOver;

  /// No description provided for @gameOverMessage.
  ///
  /// In en, this message translates to:
  /// **'You collected {score} fruits! 🍎'**
  String gameOverMessage(int score);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @swipeToMerge.
  ///
  /// In en, this message translates to:
  /// **'Swipe to merge similar fruits 🍎'**
  String get swipeToMerge;

  /// No description provided for @undoHelp.
  ///
  /// In en, this message translates to:
  /// **'Undo last move'**
  String get undoHelp;

  /// No description provided for @undoHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo last move ({count} left)'**
  String undoHelpTooltip(int count);

  /// No description provided for @watchAdForHelp.
  ///
  /// In en, this message translates to:
  /// **'Watch ad for help'**
  String get watchAdForHelp;

  /// No description provided for @removeCherryHelp.
  ///
  /// In en, this message translates to:
  /// **'Remove all Cherry tiles (2)'**
  String get removeCherryHelp;

  /// No description provided for @removeCherryHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove all Cherry tiles (2)'**
  String get removeCherryHelpTooltip;

  /// No description provided for @addHelpMove.
  ///
  /// In en, this message translates to:
  /// **'Add help move'**
  String get addHelpMove;

  /// No description provided for @addHelpMoveMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of help moves!'**
  String get addHelpMoveMessage;

  /// No description provided for @freeMoveUsed.
  ///
  /// In en, this message translates to:
  /// **'• 1 free move used'**
  String get freeMoveUsed;

  /// No description provided for @watchAdForMove.
  ///
  /// In en, this message translates to:
  /// **'• Watch ad to get 1 more move'**
  String get watchAdForMove;

  /// No description provided for @adInfo.
  ///
  /// In en, this message translates to:
  /// **'Ad will show for 15-30 seconds'**
  String get adInfo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @helpMoveAdded.
  ///
  /// In en, this message translates to:
  /// **'🎉 You got 1 more help move!'**
  String get helpMoveAdded;

  /// No description provided for @addCherryHelp.
  ///
  /// In en, this message translates to:
  /// **'Add Cherry removal help'**
  String get addCherryHelp;

  /// No description provided for @addCherryHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of Cherry removal help!'**
  String get addCherryHelpMessage;

  /// No description provided for @watchAdForCherry.
  ///
  /// In en, this message translates to:
  /// **'• Watch ad to get 1 more Cherry removal'**
  String get watchAdForCherry;

  /// No description provided for @cherryHelpAdded.
  ///
  /// In en, this message translates to:
  /// **'🎉 You got 1 more Cherry removal help!'**
  String get cherryHelpAdded;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @fruits2048.
  ///
  /// In en, this message translates to:
  /// **'Fruits 2048'**
  String get fruits2048;

  /// No description provided for @fruitGuide.
  ///
  /// In en, this message translates to:
  /// **'Fruit Guide'**
  String get fruitGuide;

  /// No description provided for @cherry.
  ///
  /// In en, this message translates to:
  /// **'Cherry'**
  String get cherry;

  /// No description provided for @strawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get strawberry;

  /// No description provided for @grape.
  ///
  /// In en, this message translates to:
  /// **'Grape'**
  String get grape;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @pear.
  ///
  /// In en, this message translates to:
  /// **'Pear'**
  String get pear;

  /// No description provided for @peach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get peach;

  /// No description provided for @mango.
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get mango;

  /// No description provided for @pineapple.
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get pineapple;

  /// No description provided for @watermelon.
  ///
  /// In en, this message translates to:
  /// **'Watermelon'**
  String get watermelon;

  /// No description provided for @melon.
  ///
  /// In en, this message translates to:
  /// **'Melon'**
  String get melon;

  /// No description provided for @coconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get coconut;

  /// No description provided for @magicBasket.
  ///
  /// In en, this message translates to:
  /// **'Magic Basket'**
  String get magicBasket;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate Fruits 2048'**
  String get rateAppTitle;

  /// No description provided for @rateAppMessage.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy playing, please rate us 5 stars!'**
  String get rateAppMessage;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get rateNow;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @thankYouForRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating! 🎉'**
  String get thankYouForRating;

  /// No description provided for @ratingError.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store'**
  String get ratingError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr', 'ja', 'pt', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
