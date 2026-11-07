import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/ai_checklist_service.dart';
import '../data/checklist_repository.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';

part 'checklist_state.dart';

/// Owns all checklist state: loading from storage, manual CRUD, and
/// AI-assisted generation from pasted text.
class ChecklistCubit extends Cubit<ChecklistState> {
  ChecklistCubit(this._repository, this._aiService)
      : super(const ChecklistState());

  final ChecklistRepository _repository;
  final AiChecklistService _aiService;

  void load() {
    emit(state.copyWith(checklists: _repository.getAll(), clearError: true));
  }

  Future<void> createChecklist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final checklist = Checklist(name: trimmed);
    await _repository.save(checklist);
    emit(state.copyWith(checklists: [...state.checklists, checklist]));
  }

  Future<void> deleteChecklist(String checklistId) async {
    await _repository.delete(checklistId);
    emit(
      state.copyWith(
        checklists:
            state.checklists.where((c) => c.id != checklistId).toList(),
      ),
    );
  }

  Future<void> addItem(
    String checklistId,
    String title, {
    String? parentId,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final checklist = _findChecklist(checklistId);
    if (checklist == null) return;

    final newItem = ChecklistItem(title: trimmed);
    if (parentId == null) {
      checklist.items.add(newItem);
    } else {
      checklist.findById(parentId)?.subtasks.add(newItem);
    }
    await _persistAndRefresh(checklist);
  }

  Future<void> toggleItem(String checklistId, String itemId) async {
    final checklist = _findChecklist(checklistId);
    final item = checklist?.findById(itemId);
    if (checklist == null || item == null) return;
    item.done = !item.done;
    await _persistAndRefresh(checklist);
  }

  Future<void> deleteItem(String checklistId, String itemId) async {
    final checklist = _findChecklist(checklistId);
    if (checklist == null) return;
    checklist.removeById(itemId);
    await _persistAndRefresh(checklist);
  }

  Future<void> generateChecklist(String name, String pastedText) async {
    final trimmedName = name.trim();
    final trimmedText = pastedText.trim();
    if (trimmedName.isEmpty || trimmedText.isEmpty) {
      emit(
        state.copyWith(
          errorMessage:
              'Enter both a checklist name and some text to generate from.',
        ),
      );
      return;
    }

    emit(state.copyWith(isGenerating: true, clearError: true));
    try {
      final items = await _aiService.generate(trimmedText);
      final checklist = Checklist(name: trimmedName, items: items);
      await _repository.save(checklist);
      emit(
        state.copyWith(
          checklists: [...state.checklists, checklist],
          isGenerating: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isGenerating: false, errorMessage: e.toString()));
    }
  }

  Checklist? _findChecklist(String checklistId) {
    for (final checklist in state.checklists) {
      if (checklist.id == checklistId) return checklist;
    }
    return null;
  }

  Future<void> _persistAndRefresh(Checklist checklist) async {
    await _repository.save(checklist);
    emit(state.copyWith(checklists: [...state.checklists]));
  }
}
