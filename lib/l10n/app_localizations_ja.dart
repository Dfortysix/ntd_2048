// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'スコア';

  @override
  String get bestScore => '最高';

  @override
  String get gameOver => '🍂 フルーツがなくなりました！';

  @override
  String gameOverMessage(int score) {
    return '$score個のフルーツを収集しました！🍎';
  }

  @override
  String get playAgain => 'もう一度プレイ';

  @override
  String get swipeToMerge => 'スワイプして同じフルーツを結合 🍎';

  @override
  String get undoHelp => '最後の手を元に戻す';

  @override
  String undoHelpTooltip(int count) {
    return '最後の手を元に戻す（残り$count回）';
  }

  @override
  String get watchAdForHelp => '広告を見てヘルプを取得';

  @override
  String get removeCherryHelp => 'すべてのチェリータイル（2）を削除';

  @override
  String get removeCherryHelpTooltip => 'すべてのチェリータイル（2）を削除';

  @override
  String get addHelpMove => 'ヘルプ手を追加';

  @override
  String get addHelpMoveMessage => 'ヘルプ手がなくなりました！';

  @override
  String get freeMoveUsed => '• 無料手1回使用済み';

  @override
  String get watchAdForMove => '• 広告を見て1手追加';

  @override
  String get adInfo => '広告は15-30秒間表示されます';

  @override
  String get cancel => 'キャンセル';

  @override
  String get watchAd => '広告を見る';

  @override
  String get helpMoveAdded => '🎉 ヘルプ手を1回追加しました！';

  @override
  String get addCherryHelp => 'チェリー削除ヘルプを追加';

  @override
  String get addCherryHelpMessage => 'チェリー削除ヘルプがなくなりました！';

  @override
  String get watchAdForCherry => '• 広告を見てチェリー削除を1回追加';

  @override
  String get cherryHelpAdded => '🎉 チェリー削除を1回追加しました！';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get music => '音楽';

  @override
  String get sound => '音';

  @override
  String get about => 'について';

  @override
  String get version => 'バージョン';

  @override
  String get developer => '開発者';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'フルーツガイド';

  @override
  String get cherry => 'チェリー';

  @override
  String get strawberry => 'イチゴ';

  @override
  String get grape => 'ブドウ';

  @override
  String get orange => 'オレンジ';

  @override
  String get apple => 'リンゴ';

  @override
  String get pear => 'ナシ';

  @override
  String get peach => 'モモ';

  @override
  String get mango => 'マンゴー';

  @override
  String get pineapple => 'パイナップル';

  @override
  String get watermelon => 'スイカ';

  @override
  String get melon => 'メロン';

  @override
  String get coconut => 'ココナッツ';

  @override
  String get magicBasket => '魔法のバスケット';

  @override
  String get rateAppTitle => 'Fruits 2048を評価';

  @override
  String get rateAppMessage => '楽しんでプレイしていたら、5つ星で評価してください！';

  @override
  String get rateNow => '今すぐ評価';

  @override
  String get maybeLater => 'また後で';

  @override
  String get thankYouForRating => '評価していただきありがとうございます！🎉';

  @override
  String get ratingError => 'Google Playを開けませんでした';
}
