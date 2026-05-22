import 'package:flutter/material.dart';

class CompetitionInfo {
  final String code;
  final String name;
  final String logoUrl;
  final String country;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final bool isCup;

  const CompetitionInfo({
    required this.code,
    required this.name,
    required this.logoUrl,
    required this.country,
    required this.primaryColor,
    required this.accentColor,
    required this.gradientColors,
    this.isCup = false,
  });
}

class LeagueConfig {
  static const List<CompetitionInfo> leagues = [
    CompetitionInfo(
      code: 'PL',
      name: 'Premier League',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/eng.1.png',
      country: 'England',
      primaryColor: Color(0xFF3D195B),
      accentColor: Color(0xFF00FF87),
      gradientColors: [
        Color(0xFF3D195B),
        Color(0xFF0F0619),
      ],
    ),
    CompetitionInfo(
      code: 'PD',
      name: 'La Liga',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/esp.1.png',
      country: 'Spain',
      primaryColor: Color(0xFFE30613),
      accentColor: Color(0xFFFFCC00),
      gradientColors: [
        Color(0xFFE30613),
        Color(0xFF220102),
      ],
    ),
    CompetitionInfo(
      code: 'SA',
      name: 'Serie A',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/ita.1.png',
      country: 'Italy',
      primaryColor: Color(0xFF002F6C),
      accentColor: Color(0xFF00E1FF),
      gradientColors: [
        Color(0xFF002F6C),
        Color(0xFF000E22),
      ],
    ),
    CompetitionInfo(
      code: 'BL1',
      name: 'Bundesliga',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/ger.1.png',
      country: 'Germany',
      primaryColor: Color(0xFFD3010C),
      accentColor: Color(0xFFFFFFFF),
      gradientColors: [
        Color(0xFFD3010C),
        Color(0xFF1F0002),
      ],
    ),
    CompetitionInfo(
      code: 'FL1',
      name: 'Ligue 1',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/fra.1.png',
      country: 'France',
      primaryColor: Color(0xFF091C3E),
      accentColor: Color(0xFFDAE025),
      gradientColors: [
        Color(0xFF091C3E),
        Color(0xFF020712),
      ],
    ),
  ];

  static const List<CompetitionInfo> cups = [
    CompetitionInfo(
      code: 'CL',
      name: 'Champions League',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/uefa.champions.png',
      country: 'Europe',
      primaryColor: Color(0xFF0B1437),
      accentColor: Color(0xFF00E5FF),
      gradientColors: [
        Color(0xFF0F1A44),
        Color(0xFF03071A),
      ],
      isCup: true,
    ),
    CompetitionInfo(
      code: 'EL',
      name: 'Europa League',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/uefa.europa.png',
      country: 'Europe',
      primaryColor: Color(0xFF3B1504),
      accentColor: Color(0xFFFF7300),
      gradientColors: [
        Color(0xFF3B1504),
        Color(0xFF0E0501),
      ],
      isCup: true,
    ),
    CompetitionInfo(
      code: 'ECL',
      name: 'Conference League',
      logoUrl: 'https://a.espncdn.com/i/leaguelogos/soccer/500/uefa.europa.conf.png',
      country: 'Europe',
      primaryColor: Color(0xFF042E1B),
      accentColor: Color(0xFF00FF87),
      gradientColors: [
        Color(0xFF042E1B),
        Color(0xFF010C07),
      ],
      isCup: true,
    ),
  ];

  static const List<CompetitionInfo> allCompetitions = [...leagues, ...cups];

  static CompetitionInfo getCompetitionByCode(String code) {
    return allCompetitions.firstWhere(
      (comp) => comp.code == code,
      orElse: () => leagues.first,
    );
  }
}
