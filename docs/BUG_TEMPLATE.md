# Bug Report Template

Use this template when reporting bugs discovered during Netlify testing, Flutter development, or production issues.

## Basic Information

**Title**: [Platform] Brief description of the issue
- Use platform tags: `[Web/Netlify]`, `[Flutter/iOS]`, `[Flutter/Android]`, `[GDevelop]`
- Example: `[Web/Netlify] Pressure meter not animating in Safari`

**Environment**:
- [ ] Production site: `https://scamshield-app.netlify.app`
- [ ] Deploy Preview: `https://deploy-preview-XX--scamshield-app.netlify.app`
- [ ] Branch Deploy: `https://BRANCH--scamshield-app.netlify.app`
- [ ] Flutter iOS App
- [ ] Flutter Android App
- [ ] Local Development

**Deploy/Build Information** (for web issues):
- **Full URL**:
- **Branch/PR**:
- **Build timestamp** (from `/health.txt`):
- **Runtime config** (from `/config/runtime.json`):

**Device/Browser**:
- **OS**:
- **Browser + Version**:
- **Device**:
- **Screen Size**:

## Bug Details

**Summary**: One-line description of what's broken

**Steps to Reproduce**:
1. Go to...
2. Click on...
3. Enter...
4. Observe...

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Screenshots/Video**: Attach if helpful

## Technical Details

**Console Errors** (F12 → Console tab):
```
Copy the first error message here, including stack trace
```

**Network Issues** (F12 → Network tab):
- [ ] No 404 errors
- [ ] No 5xx errors
- [ ] All resources load correctly
- [ ] Slow loading (>5s)

**Feature Flags** (run in console: `fetch('/config/runtime.json').then(r=>r.json())`):
```json
{
  "useUnifiedEngine": true,
  "pressureMeterEnabled": true
}
```

## Impact Assessment

**Severity**:
- [ ] **P0 - Production Down**: Site completely broken
- [ ] **P1 - Critical**: Core functionality broken
- [ ] **P2 - High**: Important feature broken
- [ ] **P3 - Medium**: Minor feature issue
- [ ] **P4 - Low**: Cosmetic or edge case

**User Impact**:
- [ ] Blocks all users
- [ ] Blocks specific scenarios
- [ ] Reduces user experience
- [ ] Cosmetic only

**Workaround Available**:
- [ ] Yes: [describe workaround]
- [ ] No

## Additional Context

**Related Issues**: Link to similar bugs or PRs

**Testing Notes**: What you tried to debug

**Suspected Cause**: Your theory about the root cause

---

## For Developers

**Components Affected**:
- [ ] Conversation Engine
- [ ] Pressure Meter
- [ ] Scenario Loading
- [ ] UI/UX
- [ ] Netlify Infrastructure
- [ ] GDevelop Export

**Investigation Checklist**:
- [ ] Reproduced locally
- [ ] Checked recent commits
- [ ] Reviewed console errors
- [ ] Tested in different browsers
- [ ] Verified feature flags
- [ ] Checked Netlify deploy logs

**Priority Tags**:
- Use `PRODUCTION` for issues affecting live users
- Use `@infra` for Netlify/deployment issues
- Use `@frontend` for Flutter/UI issues
- Use `@content` for scenario/GDevelop issues

---

## Examples

### Good Bug Report
```
Title: [Web/Netlify] Pressure meter animation breaks on iOS Safari

Environment: Deploy Preview https://deploy-preview-42--scamshield-app.netlify.app
Browser: Safari 16.1 on iPhone 14
Build: 2025-09-21 21:57:55 UTC

Summary: Pressure meter shows instant jumps instead of smooth animation

Steps:
1. Open scenario "Sample Bank Scam"
2. Make any choice that increases pressure
3. Watch pressure meter in top bar

Expected: Smooth animation over 500ms
Actual: Instant jump to new value

Console Error:
ReferenceError: ResizeObserver is not defined at PressureMeter.dart.js:1234

Impact: P3 - Reduces user experience but doesn't block functionality
```

### Bad Bug Report
```
Title: It's broken

The app doesn't work right. Fix it.
```

## Support

- **Urgent Production Issues**: Add `PRODUCTION` to title
- **Netlify/Infra Issues**: Tag `@infra` team
- **General Questions**: Check `/docs/NETLIFY_TESTING.md` first
- **Feature Requests**: Use feature request template instead