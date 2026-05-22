import 'package:flutter/material.dart';
import 'league_selector_screen.dart';

void main() {
  runApp(const PremierLeagueApp());
}

class PremierLeagueApp extends StatelessWidget {
  const PremierLeagueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PitchSide',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LeagueSelectorScreen(),
    );
  }
}