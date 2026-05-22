import 'package:flutter/material.dart';
import 'api_service.dart';
import 'league_config.dart';

class TeamDetailsScreen extends StatelessWidget {
  final int teamId;
  final String name;
  final int played;
  final int won;
  final int lost;
  final int draw;
  final int goalDifference;
  final CompetitionInfo leagueInfo;

  const TeamDetailsScreen({
    required this.teamId,
    required this.draw,
    required this.won,
    required this.lost,
    required this.name,
    required this.played,
    required this.goalDifference,
    required this.leagueInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: leagueInfo.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: leagueInfo.gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<String>>(
          future: fetchTeamDetails(teamId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(leagueInfo.accentColor),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Failed to load team details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Squad details could not be retrieved from the API.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final squad = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Stats Overview Card
                    _buildStatsCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Squad List Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups,
                            color: leagueInfo.accentColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SQUAD LIST',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: leagueInfo.accentColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${squad.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Squad Members List
                    Expanded(
                      child: squad.isEmpty
                          ? Center(
                              child: Text(
                                'No squad details available.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: squad.length,
                              itemBuilder: (context, index) {
                                final playerName = squad[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.04),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 2,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: leagueInfo.primaryColor.withOpacity(0.4),
                                      child: Text(
                                        playerName.substring(0, 1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: leagueInfo.accentColor,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      playerName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Played', '$played', Colors.white.withOpacity(0.5)),
              _buildStatItem('Won', '$won', Colors.greenAccent),
              _buildStatItem('Draw', '$draw', Colors.orangeAccent),
              _buildStatItem('Lost', '$lost', Colors.redAccent),
              _buildStatItem(
                'GD',
                goalDifference > 0 ? '+$goalDifference' : '$goalDifference',
                goalDifference > 0 ? Colors.greenAccent : (goalDifference < 0 ? Colors.redAccent : Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
