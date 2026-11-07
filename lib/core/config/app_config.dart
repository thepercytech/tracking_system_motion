/// Build-time configuration, injected via `--dart-define` so no secret
/// lives in source control. Neither value is a real security boundary —
/// anything baked into a compiled app can be extracted — but the backend
/// URL points at a Cloud Function that holds the real Anthropic API key
/// server-side, and the shared secret is a basic abuse deterrent on top
/// of that, not authentication.
class AppConfig {
  static const String checklistBackendUrl = String.fromEnvironment(
    'CHECKLIST_BACKEND_URL',
    defaultValue: '',
  );

  static const String checklistBackendSecret = String.fromEnvironment(
    'CHECKLIST_BACKEND_SECRET',
    defaultValue: '',
  );
}
