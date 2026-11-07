part of 'checklist_cubit.dart';

/// Deliberately *not* Equatable: [Checklist]/[ChecklistItem] are mutated in
/// place (toggling/adding items doesn't replace the object), so structural
/// equality would see "same objects, new wrapper list" as no change and
/// Bloc would skip notifying listeners. Plain identity equality means every
/// [ChecklistCubit.emit] — always a fresh [ChecklistState] instance —
/// reliably triggers a rebuild.
class ChecklistState {
  const ChecklistState({
    this.checklists = const [],
    this.isGenerating = false,
    this.errorMessage,
  });

  final List<Checklist> checklists;
  final bool isGenerating;
  final String? errorMessage;

  ChecklistState copyWith({
    List<Checklist>? checklists,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChecklistState(
      checklists: checklists ?? this.checklists,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
