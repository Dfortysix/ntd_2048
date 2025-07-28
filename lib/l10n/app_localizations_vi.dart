// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => '🍎 Fruits 2048';

  @override
  String get score => 'Điểm';

  @override
  String get bestScore => 'Cao nhất';

  @override
  String get gameOver => '🍂 Hết trái cây rồi!';

  @override
  String gameOverMessage(int score) {
    return 'Bạn đã thu thập được $score trái cây! 🍎';
  }

  @override
  String get playAgain => 'Chơi lại';

  @override
  String get swipeToMerge => 'Vuốt để gộp các trái cây giống nhau 🍎';

  @override
  String get undoHelp => 'Quay lại nước đi trước';

  @override
  String undoHelpTooltip(int count) {
    return 'Quay lại nước đi trước ($count lượt còn lại)';
  }

  @override
  String get watchAdForHelp => 'Xem quảng cáo để nhận lượt trợ giúp';

  @override
  String get removeCherryHelp => 'Xóa tất cả ô Cherry (2)';

  @override
  String get removeCherryHelpTooltip => 'Xóa tất cả ô Cherry (2)';

  @override
  String get addHelpMove => 'Thêm lượt trợ giúp';

  @override
  String get addHelpMoveMessage => 'Bạn đã hết lượt trợ giúp!';

  @override
  String get freeMoveUsed => '• 1 lượt miễn phí đã sử dụng';

  @override
  String get watchAdForMove => '• Xem quảng cáo để nhận thêm 1 lượt';

  @override
  String get adInfo => 'Quảng cáo sẽ hiển thị trong 15-30 giây';

  @override
  String get cancel => 'Hủy';

  @override
  String get watchAd => 'Xem quảng cáo';

  @override
  String get helpMoveAdded => '🎉 Bạn đã nhận thêm 1 lượt trợ giúp!';

  @override
  String get addCherryHelp => 'Thêm lượt xóa Cherry';

  @override
  String get addCherryHelpMessage => 'Bạn đã hết lượt xóa Cherry!';

  @override
  String get watchAdForCherry => '• Xem quảng cáo để nhận thêm 1 lượt xóa Cherry';

  @override
  String get cherryHelpAdded => '🎉 Bạn đã nhận thêm 1 lượt xóa Cherry!';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get music => 'Âm nhạc';

  @override
  String get sound => 'Âm thanh';

  @override
  String get about => 'Thông tin';

  @override
  String get version => 'Phiên bản';

  @override
  String get developer => 'Nhà phát triển';

  @override
  String get fruits2048 => 'Fruits 2048';

  @override
  String get fruitGuide => 'Hướng dẫn trái cây';

  @override
  String get cherry => 'Anh đào';

  @override
  String get strawberry => 'Dâu tây';

  @override
  String get grape => 'Nho';

  @override
  String get orange => 'Quýt';

  @override
  String get apple => 'Táo';

  @override
  String get pear => 'Lê';

  @override
  String get peach => 'Đào';

  @override
  String get mango => 'Xoài';

  @override
  String get pineapple => 'Dứa';

  @override
  String get watermelon => 'Dưa hấu';

  @override
  String get melon => 'Dưa gang';

  @override
  String get coconut => 'Dừa';

  @override
  String get magicBasket => 'Giỏ thần kỳ';
}
