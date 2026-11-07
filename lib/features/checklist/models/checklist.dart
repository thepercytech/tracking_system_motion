import 'package:uuid/uuid.dart';

import 'checklist_item.dart';

const _uuid = Uuid();

/// A named collection of [ChecklistItem]s — either typed manually or
/// produced in one shot from pasted text via the AI backend.
class Checklist {
  Checklist({
    String? id,
    required this.name,
    DateTime? createdAt,
    List<ChecklistItem>? items,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];

  final String id;
  String name;
  final DateTime createdAt;
  final List<ChecklistItem> items;

  int get totalCount => _countAll(items);
  int get doneCount => _countDone(items);

  static int _countAll(List<ChecklistItem> items) {
    var count = items.length;
    for (final item in items) {
      count += _countAll(item.subtasks);
    }
    return count;
  }

  static int _countDone(List<ChecklistItem> items) {
    var count = items.where((item) => item.done).length;
    for (final item in items) {
      count += _countDone(item.subtasks);
    }
    return count;
  }

  ChecklistItem? findById(String targetId) {
    for (final item in items) {
      final found = item.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  void removeById(String targetId) {
    final index = items.indexWhere((item) => item.id == targetId);
    if (index != -1) {
      items.removeAt(index);
      return;
    }
    for (final item in items) {
      if (item.removeById(targetId)) return;
    }
  }

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Untitled',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}
