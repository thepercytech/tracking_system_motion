# Checklist generation backend

A single Cloud Function that holds the Anthropic API key and proxies
checklist-generation requests from the Flutter app. The app never talks to
`api.anthropic.com` directly.

## One-time setup

1. Install the Firebase CLI if you don't have it: `npm install -g firebase-tools`.
2. `firebase login`
3. From the repo root, link this folder to a Firebase project:
   `firebase use --add` (pick or create a project when prompted). This writes
   `.firebaserc` — it's gitignored-by-convention here, so add it yourself if
   you want it checked in.
4. Install function dependencies: `cd functions && npm install`.
5. Set the two secrets Cloud Functions will read at runtime:
   - `firebase functions:secrets:set ANTHROPIC_API_KEY` (paste your Anthropic API key)
   - `firebase functions:secrets:set SHARED_SECRET` (make up a random string —
     this is a lightweight deterrent against randoms calling your function, not
     real auth; see the note in `lib/core/config/app_config.dart`)
6. Deploy: `npm run deploy` (from `functions/`).
7. Copy the HTTPS URL Firebase prints (looks like
   `https://<region>-<project-id>.cloudfunctions.net/generateChecklist`).

## Running the Flutter app against it

```
flutter run \
  --dart-define=CHECKLIST_BACKEND_URL=https://<region>-<project-id>.cloudfunctions.net/generateChecklist \
  --dart-define=CHECKLIST_BACKEND_SECRET=<the SHARED_SECRET value>
```

Without `CHECKLIST_BACKEND_URL` set, the "Generate from text" flow will show
an error explaining it isn't configured — manual checklist creation still
works fully offline.

## Local testing

`npm run serve` runs the function in the Firebase emulator. Point
`CHECKLIST_BACKEND_URL` at the emulator's local URL (printed on startup) to
test end-to-end without deploying.
