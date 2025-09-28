# Netlify Testing Guide

This document explains how to use Netlify Deploy Previews to test ScamShield web builds without deploying to app stores.

## Overview

ScamShield uses Netlify for hosting web exports with automatic deployments:

- **Production Deploy**: `main` branch → Live production site
- **Deploy Previews**: Pull requests → Unique preview URLs
- **Branch Deploys**: Feature branches → Branch-specific URLs

## Exporting from GDevelop to Web

### Prerequisites
1. GDevelop 5 installed
2. ScamShield GDevelop project opened
3. All scenario JSON files added as **Resources** in GDevelop

### Export Steps
1. Open ScamShield project in GDevelop
2. Go to **File > Export or publish a game**
3. Select **Web (HTML5)** platform
4. Set export path to `dist-web/` directory in repo root
5. Configure export settings:
   - ✅ Minify code
   - ✅ Export for browsers supporting WebAssembly
   - ✅ Include all resources
6. Click **EXPORT**
7. Verify export created these files:
   ```
   dist-web/
   ├── index.html
   ├── resources/
   ├── gdevelop-js-platform/
   └── config/ (existing)
   ```

### Important: Resource Paths
- All JSON scenario files must be registered as **GDevelop Resources**
- Use **relative paths** only (no leading `/`)
- Maintain **exact case** - `Resources/scenario.json` ≠ `resources/scenario.json`
- Test locally before committing: `cd dist-web && python3 -m http.server 8000`

## Netlify Deployment Types

### 1. Production Deploy
- **Trigger**: Push to `main` branch
- **URL**: `https://scamshield-app.netlify.app` (example)
- **Caching**: Long-term for assets, no-store for HTML/JSON
- **Use**: Final testing before app store releases

### 2. Deploy Previews (PR Testing)
- **Trigger**: Open/update Pull Request
- **URL**: `https://deploy-preview-{PR#}--scamshield-app.netlify.app`
- **Caching**: No-store for easier testing
- **Use**: Feature testing, QA, stakeholder review

**Finding PR Preview URLs:**
1. Open your Pull Request on GitHub
2. Scroll to checks section at bottom
3. Look for "✅ Deploy Preview ready!" with Netlify link
4. Or check PR comments for Netlify bot

### 3. Branch Deploys
- **Trigger**: Push to feature branches (e.g., `feat/prd-03-adaptive`)
- **URL**: `https://{branch-name}--scamshield-app.netlify.app`
- **Caching**: No-store like previews
- **Use**: Continuous testing during development

## Runtime Configuration

### Feature Flags via JSON
ScamShield loads runtime config from `/config/runtime.json`:

```json
{
  "useUnifiedEngine": true,
  "whitelistScenarioIds": ["sample_001", "y06_tech_support"],
  "pressureMeterEnabled": true,
  "uiTheme": "whatsapp"
}
```

### Changing Flags in Deploy Previews
**⚠️ ONLY edit runtime.json in preview branches, NOT main!**

1. In your feature branch, edit `dist-web/config/runtime.json`
2. Change desired flags:
   ```json
   {
     "useUnifiedEngine": false,
     "pressureMeterEnabled": false,
     "debugMode": true
   }
   ```
3. Commit and push - Deploy Preview will update
4. Test behavior changes in preview URL
5. Reset flags before merging to main

### Available Feature Flags
- `useUnifiedEngine`: Enable PRD-01 unified conversation system
- `pressureMeterEnabled`: Show PRD-02 pressure tracking
- `implicitTrustSystem`: Enable trust score calculation
- `whitelistScenarioIds`: Array of allowed scenario IDs
- `uiTheme`: UI theme (`"whatsapp"`, `"default"`)
- `debugMode`: Enable debug logging and dev tools

## Testing Workflow

### 1. Basic Functionality Test
1. Open Deploy Preview URL
2. Check browser DevTools Console for errors
3. Verify these resources load (Network tab):
   - `index.html` (200)
   - `resources/*.json` (200)
   - `config/runtime.json` (200)
   - No 404s for images/audio

### 2. SPA Routing Test
1. Navigate to any scenario page
2. Refresh browser (F5)
3. ✅ Should load correctly (not 404)
4. ✅ URL should remain the same

### 3. Scenario Testing
1. Open scenario selector
2. Launch test scenario (e.g., "Sample Bank Scam")
3. Complete full conversation flow
4. Verify:
   - Messages display correctly
   - Choices are clickable
   - Pressure meter updates (if enabled)
   - Debrief shows trust/pressure analysis
   - No console errors

### 4. Feature Flag Testing
1. Check current flags: `fetch('/config/runtime.json').then(r=>r.json())`
2. Test different flag combinations
3. Verify behavior changes take effect
4. Test edge cases (disabled features still work)

## Common Issues & Solutions

### 404 Errors on Resources
**Problem**: `GET /resources/scenario.json 404`

**Solutions**:
- Verify JSON file is registered as GDevelop Resource
- Check case sensitivity: `scenario.json` vs `Scenario.json`
- Ensure relative paths (no leading `/`)
- Re-export from GDevelop with all resources

### SPA Routes 404 on Refresh
**Problem**: `GET /scenario/123 404`

**Solution**: Check `dist-web/_redirects` exists:
```
/* /index.html 200
```

### Runtime Config Not Loading
**Problem**: Feature flags don't work

**Debug**:
1. Check `/config/runtime.json` loads (Network tab)
2. Verify JSON syntax is valid
3. Check browser console for fetch errors
4. Test with: `fetch('/config/runtime.json')`

### Stale Cache in Previews
**Problem**: Changes not visible in Deploy Preview

**Solutions**:
- Hard refresh: Ctrl+F5 (Windows) / Cmd+Shift+R (Mac)
- Check `/health.txt` for new build timestamp
- Clear browser cache for preview domain
- Verify new commit triggered new deploy

## Password Protection (Optional)

For private testing, you can enable password protection:

1. Go to Netlify dashboard → Site settings → Access control
2. Enable "Password protect this site"
3. Set password, share with testers
4. **Note**: This protects entire site, not just previews

## Bug Reporting

When filing bugs from Netlify testing, use `/docs/BUG_TEMPLATE.md`:

**Required Info**:
- Full Deploy Preview URL
- Browser + version
- Console errors (copy first error)
- Steps to reproduce
- Expected vs actual behavior

**Example**:
```
Title: [Web/Netlify] Pressure meter not animating in Safari
URL: https://deploy-preview-42--scamshield-app.netlify.app
Browser: Safari 16.1
Console: ReferenceError: ResizeObserver is not defined
Steps: 1. Open scenario 2. Make choice 3. Watch pressure meter
Expected: Smooth animation
Actual: Instant jump
```

## Health Checks

Quick verification endpoints:
- `/health.txt` - Build timestamp, deployment status
- `/config/runtime.json` - Feature flags
- `/` - Main app loads
- `/scenario/test` - SPA routing works

## Advanced Testing

### Local Development Server
```bash
cd dist-web
python3 -m http.server 8000
# Visit http://localhost:8000
```

### Debugging Feature Flags
```javascript
// In browser console
fetch('/config/runtime.json')
  .then(r => r.json())
  .then(config => console.log('Runtime config:', config));

// Check what app loaded
console.log(window.scamshieldConfig);
```

### Network Analysis
1. Open DevTools → Network tab
2. Disable cache (checkbox)
3. Reload page
4. Sort by Status - look for 4xx/5xx errors
5. Check resource sizes - ensure no 0-byte files

## Support

For testing issues:
1. Check this guide first
2. Search existing GitHub issues
3. File new bug with `/docs/BUG_TEMPLATE.md`
4. Tag @infra team for Netlify-specific issues

For urgent production issues:
1. Check production site health: `/health.txt`
2. Compare with working Deploy Preview
3. File P1 bug with "PRODUCTION" in title