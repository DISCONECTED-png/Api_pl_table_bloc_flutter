import 'package:flutter_bloc/flutter_bloc.dart';
import 'team.dart';
import 'api_service.dart';
import 'player_stat.dart';

// Events
abstract class LeagueTableEvent {}

class FetchLeagueTable extends LeagueTableEvent {
  final String leagueCode;
  FetchLeagueTable(this.leagueCode);
}

// States
abstract class LeagueTableState {
  final String leagueCode;
  LeagueTableState(this.leagueCode);
}

class LeagueTableLoading extends LeagueTableState {
  LeagueTableLoading(super.leagueCode);
}

class LeagueTableLoaded extends LeagueTableState {
  final List<Team> teams;
  final List<MapEntry<String, List<Team>>>? groups;
  final LeagueStats stats;
  LeagueTableLoaded(this.teams, super.leagueCode, {this.groups, required this.stats});
}

class LeagueTableError extends LeagueTableState {
  final String errorMessage;
  LeagueTableError(super.leagueCode, [this.errorMessage = 'Failed to load league table']);
}

// Bloc
class LeagueTableBloc extends Bloc<LeagueTableEvent, LeagueTableState> {
  LeagueTableBloc() : super(LeagueTableLoading('PL')) {
    on<FetchLeagueTable>(_onFetchLeagueTable);
  }

  Future<void> _onFetchLeagueTable(
      FetchLeagueTable event, Emitter<LeagueTableState> emit) async {
    emit(LeagueTableLoading(event.leagueCode));
    try {
      final result = await fetchLeagueTable(event.leagueCode);
      
      // Fetch stats with fallback
      LeagueStats stats;
      try {
        final scorers = await fetchLeagueScorers(event.leagueCode);
        final mockStats = LeagueStats.getMockStats(event.leagueCode);
        if (scorers.isNotEmpty) {
          // Merge API top scorers with mock assists and mock yellow cards
          stats = LeagueStats(
            topScorers: scorers,
            topAssists: mockStats.topAssists,
            topYellowCards: mockStats.topYellowCards,
          );
        } else {
          stats = mockStats;
        }
      } catch (e) {
        print('Scorers fetch failed or rate-limited: $e. Using mock stats.');
        stats = LeagueStats.getMockStats(event.leagueCode);
      }

      emit(LeagueTableLoaded(result.teams, event.leagueCode, groups: result.groups, stats: stats));
    } catch (e) {
      emit(LeagueTableError(event.leagueCode, e.toString()));
    }
  }
}
