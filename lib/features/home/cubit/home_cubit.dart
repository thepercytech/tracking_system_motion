import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

/// Holds the entries the user has logged.
///
/// This is a minimal placeholder cubit wired up to prove the Bloc pattern
/// end-to-end; swap it out once real persistence/backend is decided.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void addEntry(String entry) {
    final trimmed = entry.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(entries: [...state.entries, trimmed]));
  }

  void removeEntryAt(int index) {
    final updated = [...state.entries]..removeAt(index);
    emit(state.copyWith(entries: updated));
  }
}
