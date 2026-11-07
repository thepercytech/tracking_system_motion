import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/checklist/models/checklist_item.dart';
import '../config/app_config.dart';

/// Thrown when the checklist-generation backend can't be reached or
/// returns something unusable.
class AiChecklistException implements Exception {
  AiChecklistException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Calls the Cloud Function backend that wraps the Anthropic API — never
/// call the Anthropic API directly from the app; see AppConfig.
class AiChecklistService {
  Future<List<ChecklistItem>> generate(String pastedText) async {
    if (AppConfig.checklistBackendUrl.isEmpty) {
      throw AiChecklistException(
        'No backend configured. Build with '
        '--dart-define=CHECKLIST_BACKEND_URL=<your Cloud Function URL>.',
      );
    }

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse(AppConfig.checklistBackendUrl),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.checklistBackendSecret.isNotEmpty)
            'Authorization': 'Bearer ${AppConfig.checklistBackendSecret}',
        },
        body: jsonEncode({'text': pastedText}),
      );
    } catch (_) {
      throw AiChecklistException('Could not reach the checklist backend.');
    }

    if (response.statusCode != 200) {
      throw AiChecklistException(
        'Checklist generation failed (HTTP ${response.statusCode}).',
      );
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AiChecklistException('Backend returned an unreadable response.');
    }

    final items = decoded['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
