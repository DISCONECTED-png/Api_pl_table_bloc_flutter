class Team {
  final String name;
  final int position;
  final int points;
  final int id;
  final String crest;
  final int matchesplayed;
  final int matcheswon;
  final int matcheslost;
  final int matchesdrawn;
  final int goaldifference;

  Team({
    required this.name,
    required this.position,
    required this.points,
    required this.id,
    required this.crest,
    required this.matchesplayed,
    required this.matchesdrawn,
    required this.goaldifference,
    required this.matcheswon,
    required this.matcheslost
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['team']['name'],
      position: json['position'],
      points: json['points'],
      id: json['team']['id'],
      crest: json['team']['crest'],
      matchesplayed: json['playedGames'],
      matcheswon: json['won'],
      matchesdrawn: json['draw'],
      matcheslost: json['lost'],
      goaldifference: json['goalDifference']
    );
  }
}
