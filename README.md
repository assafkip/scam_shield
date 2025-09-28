# ScamShield
Privacy-first, offline-only Flutter app that detects scam texts and trains users with short, gamified lessons.

## Quickstart
```bash
flutter pub get
flutter run -d ios   # or -d android
```

## Privacy

No analytics. No network. Detection and lessons are on-device.

## Netlify

ScamShield includes web exports for testing via Netlify static hosting:

### Deployment Types
- **Production**: `main` branch → Live production site
- **Deploy Previews**: Pull requests → Unique preview URLs
- **Branch Deploys**: Feature branches → Branch-specific URLs

### Publish Directory
- **Source**: GDevelop exports to `dist-web/`
- **Config**: Runtime feature flags in `dist-web/config/runtime.json`
- **Routing**: SPA fallback via `dist-web/_redirects`

### Testing Workflow
1. Export from GDevelop to `dist-web/`
2. Commit and push to feature branch
3. Open Pull Request for Deploy Preview
4. Test using preview URL with feature flags
5. Report bugs using `/docs/BUG_TEMPLATE.md`

**Documentation**: See `/docs/NETLIFY_TESTING.md` for complete testing guide

## Roadmap

See docs/ROADMAP.md