import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/checklist.dart';

/// Persists [Checklist]s as JSON strings in a Hive box, one entry per
/// checklist. No TypeAdapters/codegen — the models own their own
/// (de)serialization, so this stays a thin key-value layer.
class ChecklistRepository {
  static const boxName = 'checklists';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  Box<String> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('ChecklistRepository.init() must be called first.');
    }
    return box;
  }

  List<Checklist> getAll() {
    return _requireBox.values
        .map((raw) => Checklist.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> save(Checklist checklist) {
    return _requireBox.put(checklist.id, jsonEncode(checklist.toJson()));
  }

  Future<void> delete(String id) {
    return _requireBox.delete(id);
  }

  Future<void> close() async {
    final box = _box;
    _box = null;
    if (box != null && box.isOpen) {
      await box.close();
    }
  }
}
