import 'dart:convert';
import 'package:http/http.dart' as http;
import '/team.dart';

const String apiKey = '44631e0b4409429ca941476237bf073e';

Future<List<Team>> fetchLeagueTable() async {
  const url = 'https://api.football-data.org/v4/competitions/PL/standings';
  final response = await http.get(
    Uri.parse(url),
    headers: {'X-Auth-Token': '44631e0b4409429ca941476237bf073e'}, 
  );

  if (response.statusCode == 200) {
    print('Response: ${response.body}'); 
    final List<dynamic> data = json.decode(response.body)['standings'][0]['table'];
    return data.map((team) => Team.fromJson(team)).toList();
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
