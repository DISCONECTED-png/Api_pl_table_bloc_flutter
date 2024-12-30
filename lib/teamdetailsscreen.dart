import 'package:flutter/material.dart';
import '../api_service.dart';

class TeamDetailsScreen extends StatelessWidget {
  final int teamId;
  final String name;
  final int played;
  final int won;
  final int lost;
  final int draw;
  final int goalDifference;

  const TeamDetailsScreen(
      {required this.teamId,
      required this.draw,
      required this.won,
      required this.lost,
      required this.name,
      required this.played,
      required this.goalDifference,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Details'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade800,
              Colors.cyan.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<String>>(
          future: fetchTeamDetails(teamId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load team details'));
            } else {
              final topScorers = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "P",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "$played",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 218, 218, 218)),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "W",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "$won",
                                      style: TextStyle(fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 218, 218, 218)),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "D",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "$draw",
                                      style: TextStyle(fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 218, 218, 218)),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "L",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "$lost",
                                      style: TextStyle(fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 218, 218, 218)),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "GD",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      "$goalDifference",
                                      style: TextStyle(fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 218, 218, 218)),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Player List
                    Expanded(
                      child: ListView(
                        children: [
                          if (topScorers.isEmpty)
                            const Center(
                                child: Text('No top scorers available')),
                          ...topScorers
                              .map(
                                (scorer) => Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  elevation: 0.0,
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(5.0),
                                    title: Text(
                                      scorer,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
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
}
