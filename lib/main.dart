import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'leaguetablebloc.dart';
import 'leaguetablescreen.dart';
import 'form_screen.dart'; // Import the form screen

void main() {
  runApp(const PremierLeagueApp());
}

class PremierLeagueApp extends StatelessWidget {
  const PremierLeagueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premier League',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return BlocProvider(
              create: (_) => LeagueTableBloc()..add(FetchLeagueTable()),
              child: const LeagueTableScreen(),
            );
          } else {
            return FormScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}