# Changelog

All notable changes to this project will be documented in this file.

## [26.2.24]

- **Fix**: Re-implemented `SupabaseAuth.recoverSession()` using the official `supabase_flutter` logic to properly read sessions from `localStorage` and trigger `AuthChangeEvent.initialSession` on page reload.
- **Refactor**: Removed all server-side `Context` and `Cookie` logic from `SharedPreferencesStorage`. The package is now strictly designed for client-side Single Page Applications (SPA), avoiding potential server-side race conditions when reading authentication states. 
- **Fix**: Corrected the `Supabase.initialize()` execution order to prevent `recoverSession` from being called before the internal HTTP client properties were ready.

## [26.2.20]
- **Feat**: Improved Supabase initialization. It now gracefully handles multiple calls by skipping if already initialized instead of throwing an assertion error.
- **Docs**: Updated README with repository links, repository homepage, and funding information. Simplified method signatures in documentation examples.
- **Chore**: Added standard `.gitignore` for Dart/Jaspr projects.

## [26.2.19] - 2026-02-19

- Initial release.
