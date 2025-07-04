import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game_screen.dart';
import 'game_state_provider.dart';
import 'remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await RemoteConfigService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: const Fruits2048App(),
    ),
  );
}

class Fruits2048App extends StatelessWidget {
  const Fruits2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruits 2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const Fruits2048Screen(),
    );
  }
}
