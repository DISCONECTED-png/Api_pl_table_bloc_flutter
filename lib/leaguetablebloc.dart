import 'package:flutter_bloc/flutter_bloc.dart';
import '../team.dart';
import '../api_service.dart';

// Events
abstract class LeagueTableEvent {}

class FetchLeagueTable extends LeagueTableEvent {}

// States
abstract class LeagueTableState {}

class LeagueTableLoading extends LeagueTableState {}

class LeagueTableLoaded extends LeagueTableState {
  final List<Team> teams;
  LeagueTableLoaded(this.teams);
}

class LeagueTableError extends LeagueTableState {}

// Bloc
class LeagueTableBloc extends Bloc<LeagueTableEvent, LeagueTableState> {
  LeagueTableBloc() : super(LeagueTableLoading()) {
    on<FetchLeagueTable>(_onFetchLeagueTable);
  }

  Future<void> _onFetchLeagueTable(
      FetchLeagueTable event, Emitter<LeagueTableState> emit) async {
    emit(LeagueTableLoading());
    try {
      final teams = await fetchLeagueTable();
      emit(LeagueTableLoaded(teams));
    } catch (e) {
      emit(LeagueTableError());
    }
  }
}
