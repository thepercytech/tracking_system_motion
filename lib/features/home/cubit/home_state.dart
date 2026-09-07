part of 'home_cubit.dart';

/// State for [HomeCubit]: the running list of logged entries.
class HomeState extends Equatable {
  const HomeState({this.entries = const []});

  final List<String> entries;

  HomeState copyWith({List<String>? entries}) {
    return HomeState(entries: entries ?? this.entries);
  }

  @override
  List<Object?> get props => [entries];
}
