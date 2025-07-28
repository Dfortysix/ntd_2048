import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'localization_helper.dart';
import 'rating_service.dart';
import 'rating_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.getLocalizedString(context, 'settings')),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Language Section
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        LocalizationHelper.getLocalizedString(context, 'language'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Text('🇺🇸'),
                      title: const Text('English'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'en'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('en'),
                    ),
                    ListTile(
                      leading: const Text('🇻🇳'),
                      title: const Text('Tiếng Việt'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'vi'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('vi'),
                    ),
                    ListTile(
                      leading: const Text('🇫🇷'),
                      title: const Text('Français'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'fr'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('fr'),
                    ),
                    ListTile(
                      leading: const Text('🇯🇵'),
                      title: const Text('日本語'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'ja'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('ja'),
                    ),
                    ListTile(
                      leading: const Text('🇪🇸'),
                      title: const Text('Español'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'es'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('es'),
                    ),
                    ListTile(
                      leading: const Text('🇵🇹'),
                      title: const Text('Português'),
                      trailing: languageProvider.getCurrentLanguageCode() == 'pt'
                          ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                          : null,
                      onTap: () => languageProvider.setLanguage('pt'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Support Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Support',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Color(0xFFFFD700)),
                  title: Text(LocalizationHelper.getLocalizedString(context, 'rateAppTitle')),
                  subtitle: Text(LocalizationHelper.getLocalizedString(context, 'rateAppMessage')),
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const RatingDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // About Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    LocalizationHelper.getLocalizedString(context, 'about'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(LocalizationHelper.getLocalizedString(context, 'version')),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(LocalizationHelper.getLocalizedString(context, 'developer')),
                  subtitle: const Text('Nguyen Tri Dung'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 