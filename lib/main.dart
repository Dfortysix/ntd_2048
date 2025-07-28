import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'game_screen.dart';
import 'game_state_provider.dart';
import 'language_provider.dart';
import 'remote_config_service.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await RemoteConfigService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const Fruits2048App(),
    ),
  );
}

class Fruits2048App extends StatelessWidget {
  const Fruits2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Fruits 2048',
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('vi'),
            Locale('fr'),
            Locale('ja'),
            Locale('es'),
            Locale('pt'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4CAF50),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const Fruits2048Screen(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}
