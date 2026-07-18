# Muslim Ummah — iOS/Android app (Flutter)

A native Flutter app for the Muslim Ummah network (https://muslimummah.app).
It reuses the site's content and APIs:

- **Library** — 24 books, opened in an in-app reader (PDFs hosted on the site).
- **Curriculum** — 57 learning playlists across 9 sciences, with on-device progress tracking.
- **Ask the Library** — smart search that calls the site's `/api/ask` endpoint.
- **Rawdah** — live dhikr lessons read straight from Supabase, with the project's display rules.
- **Recommended accounts, About, Privacy** — bilingual (Arabic RTL / English), light + dark mode.

## How this gets built (cloud build path — no Mac toolchain needed)

The native `android/` and `ios/` folders are **not** committed; they are regenerated
during the build. Two automations do the work:

- **GitHub Actions** (`.github/workflows/verify.yml`) — on every push, compiles the
  app on Linux to catch errors early (free, fast).
- **Codemagic** (`codemagic.yaml`) — builds the iOS app on a cloud Mac. The
  `ios-verify` workflow does an unsigned compile check (no Apple account needed);
  a `ios-testflight` workflow is added later once the Apple Developer account and
  signing are set up.

Bundle identifier: `app.muslimummah` · App name: **Muslim Ummah**.

## Content

Static content lives in `assets/data/*.json` (ported from the site's
`lib/data.js`, `lib/curriculum.js`, `lib/wird.js`). The Supabase publishable
(anon) key in `lib/config.dart` is public and safe to ship, per the project notes.

*An ongoing charity (sadaqah jariyah) for Ali Abdulaziz Alseddiqi, may Allah have mercy on him.*
