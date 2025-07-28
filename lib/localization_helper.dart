import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_en.dart';
import 'l10n/app_localizations_vi.dart';
import 'l10n/app_localizations_fr.dart';
import 'l10n/app_localizations_ja.dart';
import 'l10n/app_localizations_es.dart';
import 'l10n/app_localizations_pt.dart';

class LocalizationHelper {
  static AppLocalizations _getLocalizations(String languageCode) {
    switch (languageCode) {
      case 'vi': return AppLocalizationsVi();
      case 'fr': return AppLocalizationsFr();
      case 'ja': return AppLocalizationsJa();
      case 'es': return AppLocalizationsEs();
      case 'pt': return AppLocalizationsPt();
      default: return AppLocalizationsEn();
    }
  }

  static String getLocalizedString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final localizations = _getLocalizations(locale);
    
    switch (key) {
      case 'appTitle': return localizations.appTitle;
      case 'score': return localizations.score;
      case 'bestScore': return localizations.bestScore;
      case 'gameOver': return localizations.gameOver;
      case 'playAgain': return localizations.playAgain;
      case 'swipeToMerge': return localizations.swipeToMerge;
      case 'undoHelp': return localizations.undoHelp;
      case 'watchAdForHelp': return localizations.watchAdForHelp;
      case 'removeCherryHelp': return localizations.removeCherryHelp;
      case 'removeCherryHelpTooltip': return localizations.removeCherryHelpTooltip;
      case 'addHelpMove': return localizations.addHelpMove;
      case 'addHelpMoveMessage': return localizations.addHelpMoveMessage;
      case 'freeMoveUsed': return localizations.freeMoveUsed;
      case 'watchAdForMove': return localizations.watchAdForMove;
      case 'adInfo': return localizations.adInfo;
      case 'cancel': return localizations.cancel;
      case 'watchAd': return localizations.watchAd;
      case 'helpMoveAdded': return localizations.helpMoveAdded;
      case 'addCherryHelp': return localizations.addCherryHelp;
      case 'addCherryHelpMessage': return localizations.addCherryHelpMessage;
      case 'watchAdForCherry': return localizations.watchAdForCherry;
      case 'cherryHelpAdded': return localizations.cherryHelpAdded;
      case 'settings': return localizations.settings;
      case 'language': return localizations.language;
      case 'music': return localizations.music;
      case 'sound': return localizations.sound;
      case 'about': return localizations.about;
      case 'version': return localizations.version;
      case 'developer': return localizations.developer;
      case 'fruits2048': return localizations.fruits2048;
      case 'fruitGuide': return localizations.fruitGuide;
      case 'cherry': return localizations.cherry;
      case 'strawberry': return localizations.strawberry;
      case 'grape': return localizations.grape;
      case 'orange': return localizations.orange;
      case 'apple': return localizations.apple;
      case 'pear': return localizations.pear;
      case 'peach': return localizations.peach;
      case 'mango': return localizations.mango;
      case 'pineapple': return localizations.pineapple;
      case 'watermelon': return localizations.watermelon;
      case 'melon': return localizations.melon;
      case 'coconut': return localizations.coconut;
      case 'magicBasket': return localizations.magicBasket;
      default: return key;
    }
  }

  static String gameOverMessage(BuildContext context, int score) {
    final locale = Localizations.localeOf(context).languageCode;
    final localizations = _getLocalizations(locale);
    return localizations.gameOverMessage(score);
  }

  static String undoHelpTooltip(BuildContext context, int count) {
    final locale = Localizations.localeOf(context).languageCode;
    final localizations = _getLocalizations(locale);
    return localizations.undoHelpTooltip(count);
  }
} 