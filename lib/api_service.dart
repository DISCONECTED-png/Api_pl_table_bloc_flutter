import 'dart:convert';
import 'package:http/http.dart' as http;
import '/team.dart';
import 'knockout_bracket_widget.dart';
import 'player_stat.dart';

const String apiKey = '44631e0b4409429ca941476237bf073e';

class LeagueTableResult {
  final List<Team> teams;
  final List<MapEntry<String, List<Team>>>? groups;

  LeagueTableResult({required this.teams, this.groups});
}

Future<LeagueTableResult> fetchLeagueTable(String leagueCode) async {
  final url = 'https://api.football-data.org/v4/competitions/$leagueCode/standings';
  final response = await http.get(
    Uri.parse(url),
    headers: {'X-Auth-Token': apiKey}, 
  );

  if (response.statusCode == 200) {
    print('Response: ${response.body}');
    final Map<String, dynamic> decoded = json.decode(response.body);
    final List<dynamic> standings = decoded['standings'] ?? [];
    
    if (standings.isEmpty) {
      return LeagueTableResult(teams: []);
    }

    // Check if it's a cup competition with multiple groups
    // Standings will have group fields, e.g. "group": "GROUP_A"
    final hasGroups = standings.any((s) => s['group'] != null);

    if (hasGroups) {
      final List<MapEntry<String, List<Team>>> groupsList = [];
      final List<Team> allTeams = [];

      for (var standing in standings) {
        final String rawGroupName = standing['group'] ?? 'Group';
        // Format group name (e.g. GROUP_A -> Group A)
        final String groupName = rawGroupName
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
            
        final List<dynamic> tableData = standing['table'] ?? [];
        final List<Team> groupTeams = tableData.map((t) => Team.fromJson(t)).toList();
        
        groupsList.add(MapEntry(groupName, groupTeams));
        allTeams.addAll(groupTeams);
      }

      return LeagueTableResult(
        teams: allTeams,
        groups: groupsList,
      );
    } else {
      // Standard single league table
      final List<dynamic> tableData = standings[0]['table'] ?? [];
      final List<Team> teams = tableData.map((t) => Team.fromJson(t)).toList();
      return LeagueTableResult(teams: teams);
    }
  } else {
    print('Error: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to load league table');
  }
}

Future<List<String>> fetchTeamDetails(int teamId) async {
  final url = 'https://api.football-data.org/v4/teams/$teamId';
  final response = await http.get(
    Uri.parse(url),
    headers: {'X-Auth-Token': apiKey},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['squad'];
    return data.map((player) => player['name'].toString()).toList();
  } else {
    throw Exception('Failed to load team details');
  }
}

Future<List<MapEntry<String, List<BracketMatch>>>> fetchKnockoutMatchesFromApi(String leagueCode) async {
  final url = 'https://api.football-data.org/v4/competitions/$leagueCode/matches';
  final response = await http.get(
    Uri.parse(url),
    headers: {'X-Auth-Token': apiKey},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load matches from API');
  }

  final Map<String, dynamic> decoded = json.decode(response.body);
  final List<dynamic> matchesJson = decoded['matches'] ?? [];

  // Filter for knockout stages
  final knockoutStages = {'ROUND_OF_16', 'QUARTER_FINALS', 'SEMI_FINALS', 'FINAL'};
  final Map<String, List<dynamic>> matchesByStage = {};

  for (var match in matchesJson) {
    final String? stage = match['stage'];
    if (stage != null && knockoutStages.contains(stage)) {
      matchesByStage.putIfAbsent(stage, () => []).add(match);
    }
  }

  final List<MapEntry<String, List<BracketMatch>>> bracketData = [];

  // Define order of stages
  final stageOrder = ['ROUND_OF_16', 'QUARTER_FINALS', 'SEMI_FINALS', 'FINAL'];
  final stageNames = {
    'ROUND_OF_16': 'Round of 16',
    'QUARTER_FINALS': 'Quarter Finals',
    'SEMI_FINALS': 'Semi Finals',
    'FINAL': 'Grand Final',
  };

  for (var stageKey in stageOrder) {
    if (!matchesByStage.containsKey(stageKey)) continue;

    final stageMatchesJson = matchesByStage[stageKey]!;
    final List<BracketMatch> stageMatches = [];

    // Group two-legged ties
    final Map<String, List<dynamic>> ties = {};
    for (var match in stageMatchesJson) {
      final homeId = match['homeTeam']?['id'];
      final awayId = match['awayTeam']?['id'];
      if (homeId == null || awayId == null) continue;

      final tieKey = homeId < awayId ? '${homeId}_$awayId' : '${awayId}_$homeId';
      ties.putIfAbsent(tieKey, () => []).add(match);
    }

    for (var tieMatches in ties.values) {
      if (tieMatches.isEmpty) continue;

      if (tieMatches.length == 1 || stageKey == 'FINAL') {
        // Single leg (usually Grand Final)
        final match = tieMatches[0];
        final home = match['homeTeam'];
        final away = match['awayTeam'];
        final score = match['score'];
        final fullTime = score?['fullTime'];
        final isFinished = match['status'] == 'FINISHED';

        int winnerIndex = 0;
        if (isFinished) {
          if (score?['winner'] == 'HOME_TEAM') {
            winnerIndex = 1;
          } else if (score?['winner'] == 'AWAY_TEAM') {
            winnerIndex = 2;
          }
        }

        stageMatches.add(BracketMatch(
          team1Name: home?['name'] ?? 'TBD',
          team1Logo: home?['crest'] ?? '',
          team1Score: isFinished ? '${fullTime?['home'] ?? 0}' : '',
          team2Name: away?['name'] ?? 'TBD',
          team2Logo: away?['crest'] ?? '',
          team2Score: isFinished ? '${fullTime?['away'] ?? 0}' : '',
          isFinished: isFinished,
          winnerIndex: winnerIndex,
        ));
      } else {
        // Two legs
        // Sort by date to get first and second leg
        tieMatches.sort((a, b) {
          final aDate = DateTime.tryParse(a['utcDate'] ?? '') ?? DateTime.now();
          final bDate = DateTime.tryParse(b['utcDate'] ?? '') ?? DateTime.now();
          return aDate.compareTo(bDate);
        });

        final leg1 = tieMatches[0];
        final leg2 = tieMatches[1];

        final leg1Home = leg1['homeTeam'];
        final leg1Away = leg1['awayTeam'];

        final t1Name = leg1Home?['name'] ?? 'TBD';
        final t1Logo = leg1Home?['crest'] ?? '';
        final t2Name = leg1Away?['name'] ?? 'TBD';
        final t2Logo = leg1Away?['crest'] ?? '';

        final leg1Score = leg1['score']?['fullTime'];
        final leg2Score = leg2['score']?['fullTime'];

        final isFinished1 = leg1['status'] == 'FINISHED';
        final isFinished2 = leg2['status'] == 'FINISHED';
        final isFinished = isFinished1 && isFinished2;

        int t1Aggregate = 0;
        int t2Aggregate = 0;

        if (isFinished1) {
          t1Aggregate += (leg1Score?['home'] as num? ?? 0).toInt();
          t2Aggregate += (leg1Score?['away'] as num? ?? 0).toInt();
        }
        if (isFinished2) {
          t1Aggregate += (leg2Score?['away'] as num? ?? 0).toInt();
          t2Aggregate += (leg2Score?['home'] as num? ?? 0).toInt();
        }

        String t1ScoreStr = '';
        String t2ScoreStr = '';

        int winnerIndex = 0;

        if (isFinished) {
          final leg2Penalties = leg2['score']?['penalties'];
          if (leg2Penalties != null && (leg2Penalties['home'] != null || leg2Penalties['away'] != null)) {
            final penHome = (leg2Penalties['home'] as num? ?? 0).toInt();
            final penAway = (leg2Penalties['away'] as num? ?? 0).toInt();
            t1ScoreStr = '$t1Aggregate ($penAway)';
            t2ScoreStr = '$t2Aggregate ($penHome)';
            winnerIndex = penAway > penHome ? 1 : 2;
          } else {
            t1ScoreStr = '$t1Aggregate';
            t2ScoreStr = '$t2Aggregate';
            if (t1Aggregate > t2Aggregate) {
              winnerIndex = 1;
            } else if (t2Aggregate > t1Aggregate) {
              winnerIndex = 2;
            }
          }
        } else if (isFinished1) {
          t1ScoreStr = '${leg1Score?['home'] ?? 0}';
          t2ScoreStr = '${leg1Score?['away'] ?? 0}';
        }

        stageMatches.add(BracketMatch(
          team1Name: t1Name,
          team1Logo: t1Logo,
          team1Score: t1ScoreStr,
          team2Name: t2Name,
          team2Logo: t2Logo,
          team2Score: t2ScoreStr,
          isFinished: isFinished,
          winnerIndex: winnerIndex,
        ));
      }
    }

    if (stageMatches.isNotEmpty) {
      bracketData.add(MapEntry(stageNames[stageKey]!, stageMatches));
    }
  }

  return bracketData;
}

Future<List<PlayerStat>> fetchLeagueScorers(String leagueCode) async {
  final url = 'https://api.football-data.org/v4/competitions/$leagueCode/scorers';
  final response = await http.get(
    Uri.parse(url),
    headers: {'X-Auth-Token': apiKey},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded = json.decode(response.body);
    final List<dynamic> scorersJson = decoded['scorers'] ?? [];
    return scorersJson.map((s) => PlayerStat.fromJson(s)).toList();
  } else {
    throw Exception('Failed to load scorers');
  }
}
