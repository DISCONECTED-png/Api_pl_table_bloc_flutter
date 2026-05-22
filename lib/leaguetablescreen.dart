import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'league_config.dart';
import 'leaguetablebloc.dart';
import 'teamdetailsscreen.dart';
import 'knockout_bracket_widget.dart';
import 'team.dart';
import 'player_stat.dart';

class LeagueTableScreen extends StatelessWidget {
  final CompetitionInfo initialLeague;

  const LeagueTableScreen({super.key, required this.initialLeague});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeagueTableBloc, LeagueTableState>(
      builder: (context, state) {
        final activeLeague = LeagueConfig.getCompetitionByCode(state.leagueCode);
        final isCup = activeLeague.isCup;

        final tabCount = isCup ? 3 : 2;

        return DefaultTabController(
          length: tabCount,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: activeLeague.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'logo_${activeLeague.code}',
                    child: Image.network(
                      activeLeague.logoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    activeLeague.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.06),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: TabBar(
                    indicatorColor: activeLeague.accentColor,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    tabs: isCup
                        ? const [
                            Tab(text: 'STANDINGS & GROUPS'),
                            Tab(text: 'KNOCKOUT BRACKET'),
                            Tab(text: 'PLAYER STATS'),
                          ]
                        : const [
                            Tab(text: 'STANDINGS'),
                            Tab(text: 'PLAYER STATS'),
                          ],
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: activeLeague.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // 1. Inline League Switcher (Navigation Buttons)
                  _buildInlineLeagueSwitcher(context, activeLeague),

                  // 2. Standings & Stats Area
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: isCup
                          ? [
                              // Tab 1: Group Standings
                              _buildCupGroupsContent(context, state, activeLeague),

                              // Tab 2: Knockout Bracket Tree
                              KnockoutBracketWidget(competition: activeLeague),

                              // Tab 3: Stats
                              _buildStatsTabContent(context, state, activeLeague),
                            ]
                          : [
                              // Tab 1: Standard Standings
                              Column(
                                children: [
                                  _buildTableHeader(activeLeague),
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: _buildStandingsContent(context, state, activeLeague),
                                    ),
                                  ),
                                ],
                              ),

                              // Tab 2: Stats
                              _buildStatsTabContent(context, state, activeLeague),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineLeagueSwitcher(BuildContext context, CompetitionInfo activeLeague) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
            width: 1.0,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        physics: const BouncingScrollPhysics(),
        itemCount: LeagueConfig.allCompetitions.length,
        itemBuilder: (context, index) {
          final comp = LeagueConfig.allCompetitions[index];
          final isSelected = comp.code == activeLeague.code;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Material(
                color: isSelected
                    ? comp.accentColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: isSelected
                      ? null
                      : () {
                          context.read<LeagueTableBloc>().add(
                                FetchLeagueTable(comp.code),
                              );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                comp.accentColor.withOpacity(0.25),
                                comp.accentColor.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: comp.accentColor.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                      border: Border.all(
                        color: isSelected
                            ? comp.accentColor.withOpacity(0.8)
                            : Colors.white.withOpacity(0.08),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          comp.logoUrl,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.sports_soccer,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comp.code == 'BL1'
                              ? 'Bundesliga'
                              : (comp.code == 'PD'
                                  ? 'La Liga'
                                  : comp.code == 'CL'
                                      ? 'UCL'
                                      : comp.code == 'EL'
                                          ? 'UEL'
                                          : comp.code == 'ECL'
                                              ? 'UECL'
                                              : comp.name.split(' ').first),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader(CompetitionInfo activeLeague) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      color: Colors.black.withOpacity(0.15),
      child: Row(
        children: [
          const SizedBox(
            width: 30,
            child: Text(
              '#',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'CLUB',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'GD',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'PTS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: activeLeague.accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsContent(
      BuildContext context, LeagueTableState state, CompetitionInfo activeLeague) {
    if (state is LeagueTableLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(activeLeague.accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Updating standings...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (state is LeagueTableLoaded) {
      if (state.teams.isEmpty) {
        return const Center(
          child: Text(
            'No teams found',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return ListView.builder(
        key: ValueKey<String>(state.leagueCode),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        physics: const BouncingScrollPhysics(),
        itemCount: state.teams.length,
        itemBuilder: (context, index) {
          final team = state.teams[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: activeLeague.primaryColor.withOpacity(0.3),
                  onTap: () {
                    Navigator.push(
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
                          leagueInfo: activeLeague,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    child: Row(
                      children: [
                        // Position
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${team.position}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Crest
                        Container(
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: team.crest.isNotEmpty
                              ? Image.network(
                                  team.crest,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.shield,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              : const Icon(
                                  Icons.shield,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 14),
                        // Team Name
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Goal Difference
                        SizedBox(
                          width: 60,
                          child: Text(
                            team.goaldifference > 0
                                ? '+${team.goaldifference}'
                                : '${team.goaldifference}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: team.goaldifference > 0
                                  ? Colors.greenAccent
                                  : (team.goaldifference < 0
                                      ? Colors.redAccent
                                      : Colors.white.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        // Points Badge
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: activeLeague.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: activeLeague.accentColor.withOpacity(0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            '${team.points}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: activeLeague.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
  } else {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to retrieve standings table.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection or API token and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LeagueTableBloc>().add(
                      FetchLeagueTable(activeLeague.code),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: activeLeague.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildCupGroupsContent(
      BuildContext context, LeagueTableState state, CompetitionInfo activeLeague) {
    if (state is LeagueTableLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(activeLeague.accentColor),
        ),
      );
    } else if (state is LeagueTableLoaded) {
      if (state.groups != null && state.groups!.isNotEmpty) {
        return _buildGroupsView(context, state.groups!, activeLeague, isFromApi: true);
      } else {
        return _buildGroupsView(context, _getMockGroups(activeLeague.code), activeLeague, isFromApi: false);
      }
    } else {
      return _buildGroupsView(context, _getMockGroups(activeLeague.code), activeLeague, isFromApi: false);
    }
  }

  Widget _buildGroupsView(
      BuildContext context,
      List<MapEntry<String, List<Team>>> groups,
      CompetitionInfo activeLeague,
      {required bool isFromApi}) {
    return Stack(
      children: [
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final entry = groups[groupIndex];
            final groupName = entry.key;
            final teams = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Header Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.06),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      groupName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: activeLeague.accentColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  // Mini Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                          child: Text(
                            '#',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'CLUB',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 32,
                          child: Text(
                            'PL',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 36,
                          child: Text(
                            'GD',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'PTS',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: activeLeague.accentColor.withOpacity(0.8), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  // Rows
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: List.generate(teams.length, (teamIndex) {
                        final team = teams[teamIndex];
                        final qualifies = team.position <= 2;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              Navigator.push(
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
                                    leagueInfo: activeLeague,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${team.position}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: qualifies ? Colors.white : Colors.white38,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: team.crest.isNotEmpty
                                        ? Image.network(
                                            team.crest,
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
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      team.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: qualifies ? FontWeight.bold : FontWeight.w500,
                                        color: qualifies ? Colors.white : Colors.white54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${team.matchesplayed}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      team.goaldifference > 0 ? '+${team.goaldifference}' : '${team.goaldifference}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: team.goaldifference > 0
                                            ? Colors.greenAccent
                                            : (team.goaldifference < 0 ? Colors.redAccent : Colors.white38),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: qualifies
                                          ? activeLeague.accentColor.withOpacity(0.12)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${team.points}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: qualifies ? activeLeague.accentColor : Colors.white38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Live vs Historical Badge
        Positioned(
          top: 10,
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
                    boxShadow: [
                      BoxShadow(
                        color: isFromApi 
                            ? Colors.greenAccent.withOpacity(0.6)
                            : Colors.orangeAccent.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isFromApi ? 'LIVE API DATA' : 'OFFICIAL HISTORICAL DATA',
                  style: TextStyle(
                    color: isFromApi ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, List<Team>>> _getMockGroups(String code) {
    if (code == 'EL') {
      return [
        MapEntry('League Phase', [
          Team(name: 'SS Lazio', position: 1, points: 13, id: 101, crest: 'https://crests.thesportsdb.com/images/media/team/badge/z3vxp51603585097.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 9, matcheswon: 4, matcheslost: 0),
          Team(name: 'Athletic Club', position: 2, points: 13, id: 102, crest: 'https://crests.thesportsdb.com/images/media/team/badge/txwuwx1473525425.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 7, matcheswon: 4, matcheslost: 0),
          Team(name: 'Eintracht Frankfurt', position: 3, points: 13, id: 103, crest: 'https://crests.thesportsdb.com/images/media/team/badge/vqqquw1473525206.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 7, matcheswon: 4, matcheslost: 0),
          Team(name: 'Galatasaray SK', position: 4, points: 11, id: 104, crest: 'https://crests.thesportsdb.com/images/media/team/badge/vupytw1473530894.png', matchesplayed: 5, matchesdrawn: 2, goaldifference: 4, matcheswon: 3, matcheslost: 0),
          Team(name: 'RSC Anderlecht', position: 5, points: 11, id: 105, crest: 'https://crests.thesportsdb.com/images/media/team/badge/uvwxqy1473530182.png', matchesplayed: 5, matchesdrawn: 2, goaldifference: 4, matcheswon: 3, matcheslost: 0),
          Team(name: 'Ajax Amsterdam', position: 6, points: 10, id: 106, crest: 'https://crests.thesportsdb.com/images/media/team/badge/vwrutv1473531388.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 9, matcheswon: 3, matcheslost: 1),
          Team(name: 'Tottenham Hotspur', position: 7, points: 10, id: 107, crest: 'https://crests.thesportsdb.com/images/media/team/badge/wsqvwq1473525164.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 6, matcheswon: 3, matcheslost: 1),
          Team(name: 'Fenerbahçe SK', position: 8, points: 9, id: 108, crest: 'https://crests.thesportsdb.com/images/media/team/badge/vruqtt1473530867.png', matchesplayed: 5, matchesdrawn: 3, goaldifference: 3, matcheswon: 2, matcheslost: 0),
        ]),
      ];
    } else if (code == 'ECL') {
      return [
        MapEntry('League Phase', [
          Team(name: 'Chelsea FC', position: 1, points: 12, id: 201, crest: 'https://crests.thesportsdb.com/images/media/team/badge/yqsqrv1473525178.png', matchesplayed: 4, matchesdrawn: 0, goaldifference: 14, matcheswon: 4, matcheslost: 0),
          Team(name: 'Legia Warszawa', position: 2, points: 12, id: 202, crest: 'https://crests.thesportsdb.com/images/media/team/badge/rrtuxu1473526017.png', matchesplayed: 4, matchesdrawn: 0, goaldifference: 11, matcheswon: 4, matcheslost: 0),
          Team(name: 'Jagiellonia', position: 3, points: 10, id: 203, crest: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png', matchesplayed: 4, matchesdrawn: 1, goaldifference: 6, matcheswon: 3, matcheslost: 0),
          Team(name: 'Rapid Wien', position: 4, points: 10, id: 204, crest: 'https://crests.thesportsdb.com/images/media/team/badge/qqqtuu1473525206.png', matchesplayed: 4, matchesdrawn: 1, goaldifference: 4, matcheswon: 3, matcheslost: 0),
          Team(name: 'Vitória SC', position: 5, points: 10, id: 205, crest: 'https://crests.thesportsdb.com/images/media/team/badge/wspxwt1473531422.png', matchesplayed: 4, matchesdrawn: 1, goaldifference: 4, matcheswon: 3, matcheslost: 0),
          Team(name: 'Heidenheim', position: 6, points: 9, id: 206, crest: 'https://crests.thesportsdb.com/images/media/team/badge/twqsrp1473525381.png', matchesplayed: 4, matchesdrawn: 0, goaldifference: 3, matcheswon: 3, matcheslost: 1),
          Team(name: 'Shamrock Rovers', position: 7, points: 8, id: 207, crest: 'https://crests.thesportsdb.com/images/media/team/badge/qtwuvx1473525791.png', matchesplayed: 4, matchesdrawn: 2, goaldifference: 3, matcheswon: 2, matcheslost: 0),
          Team(name: 'ACF Fiorentina', position: 8, points: 7, id: 208, crest: 'https://crests.thesportsdb.com/images/media/team/badge/wspqqv1473525232.png', matchesplayed: 4, matchesdrawn: 1, goaldifference: 2, matcheswon: 2, matcheslost: 1),
        ]),
      ];
    } else {
      return [
        MapEntry('League Phase', [
          Team(name: 'Liverpool FC', position: 1, points: 15, id: 301, crest: 'https://crests.thesportsdb.com/images/media/team/badge/uv1xpa1599818816.png', matchesplayed: 5, matchesdrawn: 0, goaldifference: 11, matcheswon: 5, matcheslost: 0),
          Team(name: 'Inter Milan', position: 2, points: 13, id: 302, crest: 'https://crests.thesportsdb.com/images/media/team/badge/x0t96j1617719602.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 7, matcheswon: 4, matcheslost: 0),
          Team(name: 'FC Barcelona', position: 3, points: 12, id: 303, crest: 'https://crests.thesportsdb.com/images/media/team/badge/xqwpup1473525206.png', matchesplayed: 5, matchesdrawn: 0, goaldifference: 13, matcheswon: 4, matcheslost: 1),
          Team(name: 'Borussia Dortmund', position: 4, points: 12, id: 304, crest: 'https://crests.thesportsdb.com/images/media/team/badge/rwrwqv1473525206.png', matchesplayed: 5, matchesdrawn: 0, goaldifference: 10, matcheswon: 4, matcheslost: 1),
          Team(name: 'Aston Villa FC', position: 5, points: 10, id: 305, crest: 'https://crests.thesportsdb.com/images/media/team/badge/84e49v1692120059.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 5, matcheswon: 3, matcheslost: 1),
          Team(name: 'Bayer Leverkusen', position: 6, points: 10, id: 306, crest: 'https://crests.thesportsdb.com/images/media/team/badge/vuyqvy1508244199.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 5, matcheswon: 3, matcheslost: 1),
          Team(name: 'Arsenal FC', position: 7, points: 10, id: 307, crest: 'https://crests.thesportsdb.com/images/media/team/badge/ux7zpt1559902640.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 4, matcheswon: 3, matcheslost: 1),
          Team(name: 'AS Monaco', position: 8, points: 10, id: 308, crest: 'https://crests.thesportsdb.com/images/media/team/badge/yvvvtu1473525425.png', matchesplayed: 5, matchesdrawn: 1, goaldifference: 4, matcheswon: 3, matcheslost: 1),
        ]),
      ];
    }
  }

  Widget _buildStatsTabContent(
      BuildContext context, LeagueTableState state, CompetitionInfo activeLeague) {
    if (state is LeagueTableLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(activeLeague.accentColor),
        ),
      );
    } else if (state is LeagueTableLoaded) {
      return PlayerStatsWidget(stats: state.stats, activeLeague: activeLeague);
    } else {
      return Center(
        child: Text(
          'Failed to load stats data.',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }
  }
}

class PlayerStatsWidget extends StatefulWidget {
  final LeagueStats stats;
  final CompetitionInfo activeLeague;

  const PlayerStatsWidget({
    super.key,
    required this.stats,
    required this.activeLeague,
  });

  @override
  State<PlayerStatsWidget> createState() => _PlayerStatsWidgetState();
}

class _PlayerStatsWidgetState extends State<PlayerStatsWidget> {
  int _selectedSubTab = 0; // 0 = Goals, 1 = Assists, 2 = Yellow Cards

  @override
  Widget build(BuildContext context) {
    final activeLeague = widget.activeLeague;
    List<PlayerStat> currentStats;
    String statLabel;
    IconData statIcon;

    if (_selectedSubTab == 0) {
      currentStats = widget.stats.topScorers;
      statLabel = 'GOALS';
      statIcon = Icons.sports_soccer;
    } else if (_selectedSubTab == 1) {
      currentStats = widget.stats.topAssists;
      statLabel = 'ASSISTS';
      statIcon = Icons.help_outline;
    } else {
      currentStats = widget.stats.topYellowCards;
      statLabel = 'CARDS';
      statIcon = Icons.style;
    }

    return Column(
      children: [
        // Pill Sub-tab Switcher
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          child: Row(
            children: [
              _buildSubTabButton(0, 'Goals', Icons.sports_soccer),
              const SizedBox(width: 8),
              _buildSubTabButton(1, 'Assists', Icons.help_outline),
              const SizedBox(width: 8),
              _buildSubTabButton(2, 'Cards', Icons.style),
            ],
          ),
        ),

        // List
        Expanded(
          child: currentStats.isEmpty
              ? Center(
                  child: Text(
                    'No stats available for this competition.',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: currentStats.length,
                  itemBuilder: (context, index) {
                    final player = currentStats[index];
                    final rank = index + 1;

                    // Rank themed color
                    Color rankBadgeColor = Colors.white.withOpacity(0.1);
                    Color rankTextColor = Colors.white70;
                    if (rank == 1) {
                      rankBadgeColor = const Color(0xFFFFD700); // Gold
                      rankTextColor = Colors.black87;
                    } else if (rank == 2) {
                      rankBadgeColor = const Color(0xFFC0C0C0); // Silver
                      rankTextColor = Colors.black87;
                    } else if (rank == 3) {
                      rankBadgeColor = const Color(0xFFCD7F32); // Bronze
                      rankTextColor = Colors.black87;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // Position Rank Badge
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: rankBadgeColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: rankTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Player Name & Team Short Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.playerName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (player.teamCrest.isNotEmpty) ...[
                                        Image.network(
                                          player.teamCrest,
                                          width: 14,
                                          height: 14,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.shield,
                                            size: 10,
                                            color: Colors.white30,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        player.teamName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Extra details if goals with penalties
                            if (player.extra != null) ...[
                              Text(
                                player.extra!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.35),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Stat Value Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedSubTab == 2
                                    ? Colors.amber.withOpacity(0.12)
                                    : activeLeague.accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedSubTab == 2
                                      ? Colors.amber.withOpacity(0.4)
                                      : activeLeague.accentColor.withOpacity(0.4),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statIcon,
                                    size: 12,
                                    color: _selectedSubTab == 2 ? Colors.amber : activeLeague.accentColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${player.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedSubTab == 2 ? Colors.amber : activeLeague.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(int index, String title, IconData icon) {
    final activeLeague = widget.activeLeague;
    final isSelected = _selectedSubTab == index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: isSelected
              ? (index == 2 ? Colors.amber.withOpacity(0.2) : activeLeague.accentColor.withOpacity(0.2))
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _selectedSubTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? (index == 2 ? Colors.amber.withOpacity(0.8) : activeLeague.accentColor.withOpacity(0.8))
                      : Colors.white.withOpacity(0.06),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected
                        ? (index == 2 ? Colors.amber : activeLeague.accentColor)
                        : Colors.white60,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
