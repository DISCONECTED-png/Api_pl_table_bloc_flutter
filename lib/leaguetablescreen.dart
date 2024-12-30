import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/leaguetablebloc.dart';
import '/teamdetailsscreen.dart';

class LeagueTableScreen extends StatelessWidget {
  const LeagueTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premier League Table'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.purple.shade800, Colors.cyan.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: BlocBuilder<LeagueTableBloc, LeagueTableState>(
          builder: (context, state) {
            if (state is LeagueTableLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LeagueTableLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.teams.length,
                itemBuilder: (context, index) {
                  final team = state.teams[index];
                  return Card(
                    color: Colors.transparent,
                    surfaceTintColor: Colors.cyan.shade800,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      splashColor: Colors.purple.shade800,
                      leading: team.crest.isNotEmpty
                          ? Image.network(
                              team.crest,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.error, size: 40),
                      title: Text(
                        '${team.position}. ${team.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Points: ${team.points}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.cyan,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamDetailsScreen(
                            teamId: team.id,
                            draw: team.matchesdrawn,
                            won: team.matcheswon,
                            lost: team.matcheslost,
                            played: team.matchesplayed,
                            name: team.name,
                            goalDifference: team.goaldifference,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Failed to load data'));
            }
          },
        ),
      ),
    );
  }
}
