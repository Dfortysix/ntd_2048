import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingService {
  static const String _hasRatedKey = 'has_rated_app';
  static const String _lastPlayCountKey = 'last_play_count';
  static const String _ratingPromptShownKey = 'rating_prompt_shown';
  
  // Google Play Store URL cho ứng dụng
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.company.Fruits2048';
  
  // Kiểm tra xem người dùng đã đánh giá chưa
  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasRatedKey) ?? false;
  }
  
  // Đánh dấu đã đánh giá
  static Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }
  
  // Lưu số lần chơi hiện tại
  static Future<void> savePlayCount(int playCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPlayCountKey, playCount);
  }
  
  // Lấy số lần chơi cuối cùng
  static Future<int> getLastPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPlayCountKey) ?? 0;
  }
  
  // Kiểm tra xem đã hiển thị prompt đánh giá chưa
  static Future<bool> hasShownRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ratingPromptShownKey) ?? false;
  }
  
  // Đánh dấu đã hiển thị prompt đánh giá
  static Future<void> markRatingPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ratingPromptShownKey, true);
  }
  
  // Kiểm tra xem có nên hiển thị prompt đánh giá không
  static Future<bool> shouldShowRatingPrompt(int currentPlayCount) async {
    final hasRated = await RatingService.hasRated();
    final hasShownPrompt = await RatingService.hasShownRatingPrompt();
    final lastPlayCount = await RatingService.getLastPlayCount();
    
    // Chỉ hiển thị nếu:
    // 1. Chưa đánh giá
    // 2. Chưa hiển thị prompt
    // 3. Đã chơi ít nhất 5 lần
    // 4. Số lần chơi tăng ít nhất 3 lần so với lần cuối
    return !hasRated && 
           !hasShownPrompt && 
           currentPlayCount >= 5 && 
           (currentPlayCount - lastPlayCount) >= 3;
  }
  
  // Mở Google Play Store để đánh giá
  static Future<void> openPlayStoreForRating() async {
    final Uri url = Uri.parse(_playStoreUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        // Đánh dấu đã đánh giá
        await markAsRated();
      }
    } catch (e) {
      // Fallback: mở trình duyệt
      try {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        await markAsRated();
      } catch (e) {
        // Không thể mở được
        print('Could not open Play Store: $e');
      }
    }
  }
  
  // Reset trạng thái đánh giá (cho testing)
  static Future<void> resetRatingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasRatedKey);
    await prefs.remove(_lastPlayCountKey);
    await prefs.remove(_ratingPromptShownKey);
  }
} 