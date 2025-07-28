import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'localization_helper.dart';

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
          const SizedBox(height: 16),
          _buildLanguageSection(context),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
            ...['en', 'vi', 'fr', 'ja', 'es', 'pt'].map((languageCode) {
              final languageName = _getLanguageName(languageCode);
              final isSelected = languageProvider.getCurrentLanguageCode() == languageCode;
              
              return ListTile(
                leading: Icon(
                  Icons.language,
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                ),
                title: Text(languageName),
                trailing: isSelected 
                  ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                  : null,
                onTap: () {
                  languageProvider.setLanguage(languageCode);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $languageName'),
                      backgroundColor: const Color(0xFF4CAF50),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
          title: const Text('Version'),
          subtitle: const Text('1.0.2'),
        ),
        ListTile(
          leading: const Icon(Icons.person_outline, color: Color(0xFF4CAF50)),
          title: const Text('Developer'),
          subtitle: const Text('Fruits 2048 Team'),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_outline, color: Color(0xFF4CAF50)),
          title: const Text('Fruits 2048'),
          subtitle: const Text('A fun fruit-themed 2048 game'),
        ),
      ],
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en': return 'English';
      case 'vi': return 'Tiếng Việt';
      case 'fr': return 'Français';
      case 'ja': return '日本語';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      default: return 'English';
    }
  }
} 