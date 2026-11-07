import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A single checkable item. Supports one level of subtasks — matches the
/// bounded-depth JSON schema the AI backend is asked to produce.
class ChecklistItem {
  ChecklistItem({
    String? id,
    required this.title,
    this.done = false,
    List<ChecklistItem>? subtasks,
  })  : id = id ?? _uuid.v4(),
        subtasks = subtasks ?? [];

  final String id;
  String title;
  bool done;
  final List<ChecklistItem> subtasks;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'subtasks': subtasks.map((e) => e.toJson()).toList(),
      };

  /// Depth-first search for the item with [targetId] within this subtree.
  ChecklistItem? findById(String targetId) {
    if (id == targetId) return this;
    for (final subtask in subtasks) {
      final found = subtask.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  /// Removes the descendant with [targetId] from this item's subtasks.
  /// Returns true if it was found and removed.
  bool removeById(String targetId) {
    final index = subtasks.indexWhere((item) => item.id == targetId);
    if (index != -1) {
      subtasks.removeAt(index);
      return true;
    }
    for (final subtask in subtasks) {
      if (subtask.removeById(targetId)) return true;
    }
    return false;
  }
}
