import 'package:flutter/material.dart';
import 'league_config.dart';
import 'api_service.dart';

class BracketMatch {
  final String team1Name;
  final String team1Logo;
  final String team1Score;
  final String team2Name;
  final String team2Logo;
  final String team2Score;
  final bool isFinished;
  final int winnerIndex;

  const BracketMatch({
    required this.team1Name,
    required this.team1Logo,
    required this.team1Score,
    required this.team2Name,
    required this.team2Logo,
    required this.team2Score,
    required this.isFinished,
    required this.winnerIndex,
  });
}

class KnockoutBracketWidget extends StatelessWidget {
  final CompetitionInfo competition;

  const KnockoutBracketWidget({super.key, required this.competition});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MapEntry<String, List<BracketMatch>>>>(
      future: fetchKnockoutMatchesFromApi(competition.code),
      builder: (context, snapshot) {
        List<MapEntry<String, List<BracketMatch>>> stages;
        bool isFromApi = false;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(competition.accentColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fetching live bracket data...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          stages = _getBracketData();
          isFromApi = false;
        } else {
          stages = snapshot.data!;
          isFromApi = true;
        }

        return Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
              child: SizedBox(
                height: 640,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(stages.length, (stageIndex) {
                    final stageName = stages[stageIndex].key;
                    final matches = stages[stageIndex].value;

                    return Container(
                      width: 240,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          // Stage Header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              stageName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: competition.accentColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Column of Matches
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(matches.length, (matchIndex) {
                                final match = matches[matchIndex];
                                return _buildMatchCard(match);
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Dynamic Data Badge (Live vs Local/Cached)
            Positioned(
              top: 8,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFromApi 
                      ? Colors.greenAccent.withOpacity(0.12)
                      : Colors.orangeAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFromApi 
                        ? Colors.greenAccent.withOpacity(0.4)
                        : Colors.orangeAccent.withOpacity(0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isFromApi ? Colors.greenAccent : Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFromApi ? 'LIVE API DATA' : 'OFFICIAL HISTORICAL DATA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isFromApi ? Colors.greenAccent : Colors.orangeAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(BracketMatch match) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTeamRow(
            match.team1Name,
            match.team1Logo,
            match.team1Score,
            match.winnerIndex == 1,
            match.isFinished,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(
              color: Colors.white10,
              height: 1,
            ),
          ),
          _buildTeamRow(
            match.team2Name,
            match.team2Logo,
            match.team2Score,
            match.winnerIndex == 2,
            match.isFinished,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(
    String name,
    String logo,
    String score,
    bool isWinner,
    bool isFinished,
  ) {
    return Row(
      children: [
        // Logo
        Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: logo.isNotEmpty
              ? Image.network(
                  logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield,
                    size: 14,
                    color: Colors.grey,
                  ),
                )
              : const Icon(
                  Icons.shield,
                  size: 14,
                  color: Colors.grey,
                ),
        ),
        const SizedBox(width: 8),

        // Team Name
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
              color: isWinner
                  ? Colors.white
                  : (isFinished ? Colors.white38 : Colors.white70),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Score Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isWinner
                ? competition.accentColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            score,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isWinner ? FontWeight.w900 : FontWeight.w600,
              color: isWinner ? competition.accentColor : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, List<BracketMatch>>> _getBracketData() {
    if (competition.code == 'EL') {
      // Europa League Bracket (2023-2024 Real Data)
      return const [
        MapEntry('Round of 16', [
          BracketMatch(
            team1Name: 'Bayer Leverkusen',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png',
            team1Score: '5',
            team2Name: 'Qarabağ FK',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/b/b8/Qaraba%C4%9F_FK_logo.svg/256px-Qaraba%C4%9F_FK_logo.svg.png',
            team2Score: '4',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'West Ham United',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/7wubv81603584824.png',
            team1Score: '5',
            team2Name: 'SC Freiburg',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/tuqtwy1508244222.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'AS Roma',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png',
            team1Score: '4',
            team2Name: 'Brighton',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/f/fd/Brighton_%26_Hove_Albion_F.C._logo.svg/256px-Brighton_%26_Hove_Albion_F.C._logo.svg.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'AC Milan',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rrqxtp1473525287.png',
            team1Score: '7',
            team2Name: 'Slavia Praha',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/SK_Slavia_Praha_logo.svg/256px-SK_Slavia_Praha_logo.svg.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Atalanta BC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png',
            team1Score: '3',
            team2Name: 'Sporting CP',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wspxwt1473531422.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Liverpool FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/uv1xpa1599818816.png',
            team1Score: '11',
            team2Name: 'Sparta Praha',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/AC_Sparta_Praha_logo.svg/256px-AC_Sparta_Praha_logo.svg.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Olympique Marseille',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png',
            team1Score: '5',
            team2Name: 'Villarreal CF',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/8tw5951620834164.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'SL Benfica',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vwuqsq1473531477.png',
            team1Score: '3',
            team2Name: 'Rangers FC',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/0/08/Rangers_FC_crest.svg/256px-Rangers_FC_crest.svg.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Quarter Finals', [
          BracketMatch(
            team1Name: 'Bayer Leverkusen',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png',
            team1Score: '3',
            team2Name: 'West Ham United',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/7wubv81603584824.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'AS Roma',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png',
            team1Score: '3',
            team2Name: 'AC Milan',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rrqxtp1473525287.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Atalanta BC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png',
            team1Score: '3',
            team2Name: 'Liverpool FC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/uv1xpa1599818816.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Olympique Marseille',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png',
            team1Score: '2 (4)',
            team2Name: 'SL Benfica',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vwuqsq1473531477.png',
            team2Score: '2 (2)',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Semi Finals', [
          BracketMatch(
            team1Name: 'Bayer Leverkusen',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png',
            team1Score: '4',
            team2Name: 'AS Roma',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/sywtwz1508244432.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Atalanta BC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png',
            team1Score: '4',
            team2Name: 'Olympique Marseille',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/qvqpvy1473525895.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Grand Final', [
          BracketMatch(
            team1Name: 'Bayer Leverkusen',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png',
            team1Score: '0',
            team2Name: 'Atalanta BC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxxvxq1473525147.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 2,
          ),
        ]),
      ];
    } else if (competition.code == 'ECL') {
      // Conference League Bracket (2023-2024 Real Data)
      return const [
        MapEntry('Round of 16', [
          BracketMatch(
            team1Name: 'Aston Villa FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png',
            team1Score: '4',
            team2Name: 'Ajax Amsterdam',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/7/79/Ajax_Amsterdam.svg/256px-Ajax_Amsterdam.svg.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Club Brugge KV',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png',
            team1Score: '4',
            team2Name: 'Molde FK',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/3/3f/Molde_FK_logo.svg/256px-Molde_FK_logo.svg.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Lille OSC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png',
            team1Score: '4',
            team2Name: 'Sturm Graz',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/SK_Sturm_Graz_logo.svg/256px-SK_Sturm_Graz_logo.svg.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Olympiacos FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxuqxw1473531123.png',
            team1Score: '7',
            team2Name: 'Maccabi Tel Aviv',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wvyuqp1473530948.png',
            team2Score: '5',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Fenerbahce SK',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vruqtt1473530867.png',
            team1Score: '3',
            team2Name: 'Union SG',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/en/thumb/1/14/Royale_Union_Saint-Gilloise_logo.svg/256px-Royale_Union_Saint-Gilloise_logo.svg.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'ACF Fiorentina',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png',
            team1Score: '5',
            team2Name: 'Maccabi Haifa',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Maccabi_Haifa_FC_logo.svg/256px-Maccabi_Haifa_FC_logo.svg.png',
            team2Score: '4',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'PAOK FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/tuxptv1473531191.png',
            team1Score: '5',
            team2Name: 'Dinamo Zagreb',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/GNK_Dinamo_Zagreb_logo.svg/256px-GNK_Dinamo_Zagreb_logo.svg.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Viktoria Plzen',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wsqqsw1473531602.png',
            team1Score: '0 (3)',
            team2Name: 'Servette FC',
            team2Logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Servette_FC_logo.svg/256px-Servette_FC_logo.svg.png',
            team2Score: '0 (1)',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Quarter Finals', [
          BracketMatch(
            team1Name: 'Aston Villa FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png',
            team1Score: '3 (4)',
            team2Name: 'Lille OSC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png',
            team2Score: '3 (3)',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Olympiacos FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxuqxw1473531123.png',
            team1Score: '3 (3)',
            team2Name: 'Fenerbahce SK',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vruqtt1473530867.png',
            team2Score: '3 (2)',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'ACF Fiorentina',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png',
            team1Score: '2',
            team2Name: 'Viktoria Plzen',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wsqqsw1473531602.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Club Brugge KV',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png',
            team1Score: '3',
            team2Name: 'PAOK FC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/tuxptv1473531191.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Semi Finals', [
          BracketMatch(
            team1Name: 'Aston Villa FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png',
            team1Score: '2',
            team2Name: 'Olympiacos FC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxuqxw1473531123.png',
            team2Score: '6',
            isFinished: true,
            winnerIndex: 2,
          ),
          BracketMatch(
            team1Name: 'ACF Fiorentina',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png',
            team1Score: '4',
            team2Name: 'Club Brugge KV',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Grand Final', [
          BracketMatch(
            team1Name: 'Olympiacos FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vxuqxw1473531123.png',
            team1Score: '1',
            team2Name: 'ACF Fiorentina',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
      ];
    } else {
      // Default: Champions League Bracket (2023-2024 Real Data)
      return const [
        MapEntry('Round of 16', [
          BracketMatch(
            team1Name: 'Arsenal FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png',
            team1Score: '1 (4)',
            team2Name: 'FC Porto',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/xqpuyt1473531557.png',
            team2Score: '1 (2)',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'FC Barcelona',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/e4c34a1614088939.png',
            team1Score: '4',
            team2Name: 'SSC Napoli',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/vrypvt1473525381.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Real Madrid CF',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png',
            team1Score: '2',
            team2Name: 'RB Leipzig',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/15v7041508244249.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Manchester City FC',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/eat4851599824248.png',
            team1Score: '6',
            team2Name: 'FC Copenhagen',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/swqtuu1473530267.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'FC Bayern Munich',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png',
            team1Score: '3',
            team2Name: 'SS Lazio',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/9y7hve1508244586.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Paris Saint-Germain',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rwqqvq1473526017.png',
            team1Score: '4',
            team2Name: 'Real Sociedad',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/twuqts1508243859.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Atletico Madrid',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/pvyqxq1508243577.png',
            team1Score: '2 (3)',
            team2Name: 'Inter Milan',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/42079q1621617457.png',
            team2Score: '2 (2)',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Borussia Dortmund',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/97v0o41692120077.png',
            team1Score: '3',
            team2Name: 'PSV Eindhoven',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/yqwuyt1473531402.png',
            team2Score: '1',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Quarter Finals', [
          BracketMatch(
            team1Name: 'Bayern Munich',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png',
            team1Score: '3',
            team2Name: 'Arsenal FC',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png',
            team2Score: '2',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Real Madrid CF',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png',
            team1Score: '4 (4)',
            team2Name: 'Manchester City',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/eat4851599824248.png',
            team2Score: '4 (3)',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Paris Saint-Germain',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rwqqvq1473526017.png',
            team1Score: '6',
            team2Name: 'FC Barcelona',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/e4c34a1614088939.png',
            team2Score: '4',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Borussia Dortmund',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/97v0o41692120077.png',
            team1Score: '5',
            team2Name: 'Atletico Madrid',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/pvyqxq1508243577.png',
            team2Score: '4',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Semi Finals', [
          BracketMatch(
            team1Name: 'Real Madrid CF',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png',
            team1Score: '4',
            team2Name: 'Bayern Munich',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/4vns4f1692120042.png',
            team2Score: '3',
            isFinished: true,
            winnerIndex: 1,
          ),
          BracketMatch(
            team1Name: 'Borussia Dortmund',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/97v0o41692120077.png',
            team1Score: '2',
            team2Name: 'Paris Saint-Germain',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rwqqvq1473526017.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
        MapEntry('Grand Final', [
          BracketMatch(
            team1Name: 'Real Madrid CF',
            team1Logo: 'https://crests.thesportsdb.com/images/media/team/badge/rhyqvx1508243689.png',
            team1Score: '2',
            team2Name: 'Borussia Dortmund',
            team2Logo: 'https://crests.thesportsdb.com/images/media/team/badge/97v0o41692120077.png',
            team2Score: '0',
            isFinished: true,
            winnerIndex: 1,
          ),
        ]),
      ];
    }
  }
}
