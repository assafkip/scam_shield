# Web Export Directory

This directory should contain the GDevelop web export for ScamShield.

## Setup Instructions

1. Open ScamShield project in GDevelop
2. Go to File > Export or publish a game
3. Select "Web (HTML5)" platform
4. Set export path to this `dist-web/` directory
5. Click "EXPORT"

## Expected Structure After Export

```
dist-web/
├── index.html              # Main entry point
├── resources/               # Game assets and JSON scenarios
│   ├── *.json              # Scenario data files
│   ├── *.png               # Image assets
│   └── ...
├── gdevelop-js-platform/    # GDevelop runtime
├── config/                  # Runtime configuration
│   └── runtime.json         # Feature flags (managed by Netlify)
├── _redirects              # SPA routing
├── _headers                # Security headers
└── health.txt              # Build timestamp
```

## Testing Locally

After export, you can test locally with:

```bash
cd dist-web
python3 -m http.server 8000
# Visit http://localhost:8000
```

## Deployment

Changes to this directory are automatically deployed to Netlify:
- **Production**: Main branch → Live site
- **Deploy Previews**: Pull requests → Unique preview URLs
- **Branch Deploys**: Feature branches → Branch-specific URLs

See `/docs/NETLIFY_TESTING.md` for complete testing workflow.