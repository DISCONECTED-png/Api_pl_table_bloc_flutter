class PlayerStat {
  final String playerName;
  final String teamName;
  final String teamCrest;
  final int value;
  final String? extra;

  PlayerStat({
    required this.playerName,
    required this.teamName,
    required this.teamCrest,
    required this.value,
    this.extra,
  });

  factory PlayerStat.fromJson(Map<String, dynamic> json) {
    // Standard mapper for football-data.org scorers endpoint
    final player = json['player'] ?? {};
    final team = json['team'] ?? {};
    final goals = json['goals'] as int? ?? 0;
    final penalties = json['penalties'] as int? ?? 0;
    final assists = json['assists'] as int? ?? 0;

    return PlayerStat(
      playerName: player['name'] ?? 'Unknown Player',
      teamName: team['shortName'] ?? team['name'] ?? 'Unknown Team',
      teamCrest: team['crest'] ?? '',
      value: goals,
      extra: penalties > 0 ? '$penalties penalties' : (assists > 0 ? '$assists assists' : null),
    );
  }
}

class LeagueStats {
  final List<PlayerStat> topScorers;
  final List<PlayerStat> topAssists;
  final List<PlayerStat> topYellowCards;

  LeagueStats({
    required this.topScorers,
    required this.topAssists,
    required this.topYellowCards,
  });

  factory LeagueStats.getMockStats(String leagueCode) {
    switch (leagueCode) {
      case 'PL':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Erling Haaland', teamName: 'Man City', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 27, extra: '7 penalties'),
            PlayerStat(playerName: 'Cole Palmer', teamName: 'Chelsea', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/yqsqrv1473525178.png', value: 22, extra: '9 penalties'),
            PlayerStat(playerName: 'Alexander Isak', teamName: 'Newcastle', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/567vrr1473525287.png', value: 21, extra: '5 penalties'),
            PlayerStat(playerName: 'Ollie Watkins', teamName: 'Aston Villa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', value: 19, extra: 'No penalties'),
            PlayerStat(playerName: 'Phil Foden', teamName: 'Man City', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 19, extra: 'No penalties'),
            PlayerStat(playerName: 'Mohamed Salah', teamName: 'Liverpool', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uv1xpa1599818816.png', value: 18, extra: '5 penalties'),
            PlayerStat(playerName: 'Bukayo Saka', teamName: 'Arsenal', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 16, extra: '6 penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Cole Palmer', teamName: 'Chelsea', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/yqsqrv1473525178.png', value: 11),
            PlayerStat(playerName: 'Ollie Watkins', teamName: 'Aston Villa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', value: 13),
            PlayerStat(playerName: 'Kevin De Bruyne', teamName: 'Man City', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 10),
            PlayerStat(playerName: 'Mohamed Salah', teamName: 'Liverpool', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uv1xpa1599818816.png', value: 10),
            PlayerStat(playerName: 'Anthony Gordon', teamName: 'Newcastle', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/567vrr1473525287.png', value: 10),
            PlayerStat(playerName: 'Bukayo Saka', teamName: 'Arsenal', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 9),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'João Palhinha', teamName: 'Fulham', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vwuqsq1473531477.png', value: 13),
            PlayerStat(playerName: 'Marcos Senesi', teamName: 'Bournemouth', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/7wubv81603584824.png', value: 13),
            PlayerStat(playerName: 'Edson Álvarez', teamName: 'West Ham', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/7wubv81603584824.png', value: 11),
            PlayerStat(playerName: 'Bruno Guimarães', teamName: 'Newcastle', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/567vrr1473525287.png', value: 9),
            PlayerStat(playerName: 'Nicolas Jackson', teamName: 'Chelsea', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/yqsqrv1473525178.png', value: 10),
          ],
        );

      case 'PD':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Artem Dovbyk', teamName: 'Girona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 24, extra: '7 penalties'),
            PlayerStat(playerName: 'Alexander Sørloth', teamName: 'Villarreal', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/8tw5951620834164.png', value: 23, extra: 'No penalties'),
            PlayerStat(playerName: 'Jude Bellingham', teamName: 'Real Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png', value: 19, extra: '1 penalty'),
            PlayerStat(playerName: 'Robert Lewandowski', teamName: 'Barcelona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 19, extra: '4 penalties'),
            PlayerStat(playerName: 'Ante Budimir', teamName: 'Osasuna', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/1kexj11620834241.png', value: 17, extra: '3 penalties'),
            PlayerStat(playerName: 'Antoine Griezmann', teamName: 'Atlético Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 16, extra: '4 penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Álex Baena', teamName: 'Villarreal', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/8tw5951620834164.png', value: 14),
            PlayerStat(playerName: 'Nico Williams', teamName: 'Athletic Club', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/txwuwx1473525425.png', value: 11),
            PlayerStat(playerName: 'Savinho', teamName: 'Girona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 10),
            PlayerStat(playerName: 'İlkay Gündoğan', teamName: 'Barcelona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 9),
            PlayerStat(playerName: 'Robert Lewandowski', teamName: 'Barcelona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 8),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Iván Alejo', teamName: 'Cádiz CF', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/1kexj11620834241.png', value: 17),
            PlayerStat(playerName: 'Djené Dakonam', teamName: 'Getafe CF', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/8tw5951620834164.png', value: 13),
            PlayerStat(playerName: 'Chimy Ávila', teamName: 'Real Betis', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/1kexj11620834241.png', value: 11),
            PlayerStat(playerName: 'Antonio Raíllo', teamName: 'RCD Mallorca', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/1kexj11620834241.png', value: 10),
          ],
        );

      case 'SA':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Lautaro Martínez', teamName: 'Inter Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/x0t96j1617719602.png', value: 24, extra: '2 penalties'),
            PlayerStat(playerName: 'Dušan Vlahović', teamName: 'Juventus', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vwuqsq1473531477.png', value: 16, extra: '2 penalties'),
            PlayerStat(playerName: 'Victor Osimhen', teamName: 'Napoli', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vrypvt1473525381.png', value: 15, extra: '3 penalties'),
            PlayerStat(playerName: 'Albert Guðmundsson', teamName: 'Genoa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vrypvt1473525381.png', value: 14, extra: '4 penalties'),
            PlayerStat(playerName: 'Hakan Çalhanoğlu', teamName: 'Inter Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/x0t96j1617719602.png', value: 13, extra: '10 penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Rafael Leão', teamName: 'AC Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rrqxtp1473525287.png', value: 9),
            PlayerStat(playerName: 'Paulo Dybala', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 9),
            PlayerStat(playerName: 'Henrikh Mkhitaryan', teamName: 'Inter Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/x0t96j1617719602.png', value: 8),
            PlayerStat(playerName: 'Olivier Giroud', teamName: 'AC Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rrqxtp1473525287.png', value: 8),
            PlayerStat(playerName: 'Weston McKennie', teamName: 'Juventus', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vwuqsq1473531477.png', value: 7),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Leandro Paredes', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 15),
            PlayerStat(playerName: 'Marten de Roon', teamName: 'Atalanta', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png', value: 10),
            PlayerStat(playerName: 'Gianluca Mancini', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 9),
            PlayerStat(playerName: 'Theo Hernández', teamName: 'AC Milan', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rrqxtp1473525287.png', value: 9),
          ],
        );

      case 'BL1':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Harry Kane', teamName: 'FC Bayern', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png', value: 36, extra: '5 penalties'),
            PlayerStat(playerName: 'Serhou Guirassy', teamName: 'Stuttgart', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 28, extra: '4 penalties'),
            PlayerStat(playerName: 'Loïs Openda', teamName: 'RB Leipzig', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 24, extra: '4 penalties'),
            PlayerStat(playerName: 'Deniz Undav', teamName: 'Stuttgart', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 18, extra: 'No penalties'),
            PlayerStat(playerName: 'Ermedin Demirović', teamName: 'Augsburg', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 15, extra: '3 penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Alejandro Grimaldo', teamName: 'Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 13),
            PlayerStat(playerName: 'Florian Wirtz', teamName: 'Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 11),
            PlayerStat(playerName: 'Xavi Simons', teamName: 'RB Leipzig', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 11),
            PlayerStat(playerName: 'Leroy Sané', teamName: 'FC Bayern', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png', value: 11),
            PlayerStat(playerName: 'Julian Brandt', teamName: 'Dortmund', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rwrwqv1473525206.png', value: 11),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Dominik Kohr', teamName: 'Mainz 05', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 13),
            PlayerStat(playerName: 'Kevin Stöger', teamName: 'VfL Bochum', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 9),
            PlayerStat(playerName: 'Manu Koné', teamName: 'Gladbach', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png', value: 8),
            PlayerStat(playerName: 'Granit Xhaka', teamName: 'Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 7),
          ],
        );

      case 'FL1':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Kylian Mbappé', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 27, extra: '6 penalties'),
            PlayerStat(playerName: 'Jonathan David', teamName: 'Lille OSC', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 19, extra: '2 penalties'),
            PlayerStat(playerName: 'Alexandre Lacazette', teamName: 'Lyon', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 19, extra: '2 penalties'),
            PlayerStat(playerName: 'Pierre-Emerick Aubameyang', teamName: 'Marseille', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png', value: 17, extra: '4 penalties'),
            PlayerStat(playerName: 'Wissam Ben Yedder', teamName: 'Monaco', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/yvvvtu1473525425.png', value: 16, extra: '1 penalty'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Ousmane Dembélé', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 8),
            PlayerStat(playerName: 'Angel Gomes', teamName: 'Lille OSC', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 8),
            PlayerStat(playerName: 'Romain Del Castillo', teamName: 'Brest', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 8),
            PlayerStat(playerName: 'Pierre-Emerick Aubameyang', teamName: 'Marseille', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png', value: 8),
            PlayerStat(playerName: 'Kylian Mbappé', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 7),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Pierre Lees-Melou', teamName: 'Brest', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 10),
            PlayerStat(playerName: 'Denis Zakaria', teamName: 'Monaco', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/yvvvtu1473525425.png', value: 9),
            PlayerStat(playerName: 'Facundo Medina', teamName: 'RC Lens', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vqytrr1473525287.png', value: 9),
            PlayerStat(playerName: 'Bradley Locko', teamName: 'Brest', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 8),
          ],
        );

      case 'CL':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Harry Kane', teamName: 'FC Bayern', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png', value: 8, extra: '3 penalties'),
            PlayerStat(playerName: 'Kylian Mbappé', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 8, extra: '3 penalties'),
            PlayerStat(playerName: 'Erling Haaland', teamName: 'Man City', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 6, extra: '2 penalties'),
            PlayerStat(playerName: 'Antoine Griezmann', teamName: 'Atlético Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 6, extra: '1 penalty'),
            PlayerStat(playerName: 'Vinícius Júnior', teamName: 'Real Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png', value: 6, extra: '1 penalty'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Jude Bellingham', teamName: 'Real Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png', value: 5),
            PlayerStat(playerName: 'Marcel Sabitzer', teamName: 'Dortmund', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rwrwqv1473525206.png', value: 5),
            PlayerStat(playerName: 'Vinícius Júnior', teamName: 'Real Madrid', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png', value: 5),
            PlayerStat(playerName: 'Bukayo Saka', teamName: 'Arsenal', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', value: 4),
            PlayerStat(playerName: 'Ilkay Gündogan', teamName: 'Barcelona', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', value: 4),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Emre Can', teamName: 'Dortmund', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/rwrwqv1473525206.png', value: 4),
            PlayerStat(playerName: 'Ousmane Dembélé', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 4),
            PlayerStat(playerName: 'Warren Zaïre-Emery', teamName: 'PSG', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 3),
            PlayerStat(playerName: 'Leon Goretzka', teamName: 'FC Bayern', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png', value: 3),
          ],
        );

      case 'EL':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Pierre-Emerick Aubameyang', teamName: 'Marseille', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png', value: 10, extra: '2 penalties'),
            PlayerStat(playerName: 'Romelu Lukaku', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 7, extra: 'No penalties'),
            PlayerStat(playerName: 'Gianluca Scamacca', teamName: 'Atalanta BC', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png', value: 6, extra: 'No penalties'),
            PlayerStat(playerName: 'Victor Boniface', teamName: 'Bayer Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 5, extra: '1 penalty'),
            PlayerStat(playerName: 'Patrik Schick', teamName: 'Bayer Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 5, extra: 'No penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Amine Harit', teamName: 'Marseille', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png', value: 6),
            PlayerStat(playerName: 'Jonathan Clauss', teamName: 'Marseille', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png', value: 6),
            PlayerStat(playerName: 'Stephan El Shaarawy', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 5),
            PlayerStat(playerName: 'Alejandro Grimaldo', teamName: 'Bayer Leverkusen', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', value: 4),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'Leandro Paredes', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 5),
            PlayerStat(playerName: 'Nemanja Matić', teamName: 'Rennes', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', value: 4),
            PlayerStat(playerName: 'Bryan Cristante', teamName: 'AS Roma', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png', value: 4),
          ],
        );

      case 'ECL':
        return LeagueStats(
          topScorers: [
            PlayerStat(playerName: 'Ayoub El Kaabi', teamName: 'Olympiacos', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuxptv1473531191.png', value: 11, extra: '1 penalty'),
            PlayerStat(playerName: 'Eran Zahavi', teamName: 'Maccabi Tel Aviv', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/wvyuqp1473530948.png', value: 8, extra: '2 penalties'),
            PlayerStat(playerName: 'Bruno Petković', teamName: 'Dinamo Zagreb', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/tuxptv1473531191.png', value: 7, extra: '3 penalties'),
            PlayerStat(playerName: 'Hans Vanaken', teamName: 'Club Brugge KV', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png', value: 6, extra: 'No penalties'),
          ],
          topAssists: [
            PlayerStat(playerName: 'Leon Bailey', teamName: 'Aston Villa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', value: 5),
            PlayerStat(playerName: 'Hans Vanaken', teamName: 'Club Brugge KV', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png', value: 4),
            PlayerStat(playerName: 'Thiago', teamName: 'Club Brugge KV', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png', value: 4),
            PlayerStat(playerName: 'John McGinn', teamName: 'Aston Villa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', value: 3),
          ],
          topYellowCards: [
            PlayerStat(playerName: 'John McGinn', teamName: 'Aston Villa', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', value: 4),
            PlayerStat(playerName: 'Thiago', teamName: 'Club Brugge KV', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png', value: 3),
            PlayerStat(playerName: 'Cristiano Biraghi', teamName: 'ACF Fiorentina', teamCrest: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png', value: 3),
          ],
        );

      default:
        return LeagueStats(topScorers: [], topAssists: [], topYellowCards: []);
    }
  }
}
