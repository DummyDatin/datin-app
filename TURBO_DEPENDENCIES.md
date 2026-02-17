# Turborepo Task Dependencies Explained

## Your Question Answered

> "Why isn't there any dependency also"

You were right to question this! Here's what we added and why:

## The Dependencies in turbo.json

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "build/**"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "lint": {
      "cache": false
    },
    "format": {
      "cache": false
    }
  }
}
```

## Understanding the Dependencies

### 1. `build` Task

```json
"build": {
  "dependsOn": ["^build"],
  "outputs": ["dist/**", ".next/**", "build/**"]
}
```

**What this means:**
- `^build` = "build dependencies first"
- Before building app A, build any workspaces that A depends on
- Outputs define what gets cached

**Example:**
```
If datin-web depends on @shared/utils:
1. Build @shared/utils first (if it exists)
2. Then build datin-web
```

**In our monorepo:**
```
datin-web: Next.js app (no internal dependencies)
  └─ Builds immediately

datin-api: Python service (standalone)
  └─ Builds immediately

datin-discovery: Python service (standalone)
  └─ Builds immediately
```

All build in parallel since none depend on each other.

### 2. `test` Task

```json
"test": {
  "dependsOn": ["^build"],
  "outputs": ["coverage/**"]
}
```

**What this means:**
- Tests depend on workspace builds (`^build`)
- Must build before testing
- Coverage files are cached

**Order:**
```
1. Run "build" task for all apps
2. Then run "test" task for all apps
3. Cache coverage results
```

**Example Flow:**
```
$ npm run test
  ├─ build:datin-web ✓
  ├─ build:datin-api ✓
  ├─ build:datin-discovery ✓
  ├─ test:datin-web ✓
  ├─ test:datin-api ✓ (passed with our fixes!)
  └─ test:datin-discovery ✓
```

### 3. `lint` Task

```json
"lint": {
  "outputs": [],
  "cache": false
}
```

**What this means:**
- No dependencies (runs independently)
- `cache: false` = always run fresh
- Don't cache results

**Why no cache?**
- Linting should always be fresh
- Code changes affect lint results
- Can't skip linting based on cached results

**Order:**
```
$ npm run lint
  ├─ lint:datin-web ✓ (parallel)
  ├─ lint:datin-api ✓ (parallel)
  └─ lint:datin-discovery ✓ (parallel)
```

All lint tasks run simultaneously (no dependencies).

### 4. `format` Task

```json
"format": {
  "outputs": [],
  "cache": false
}
```

**What this means:**
- No dependencies
- `cache: false` = always run fresh
- Modifies files directly

**Why no cache?**
- Formatting changes files
- Can't cache when files are being modified
- Should always run

**Order:**
```
$ npm run format
  ├─ format:datin-web ✓ (parallel)
  ├─ format:datin-api ✓ (parallel)
  └─ format:datin-discovery ✓ (parallel)
```

All format tasks run simultaneously.

### 5. `dev` Task

No explicit configuration needed.
```
$ npm run dev
  ├─ dev:datin-web (watches for changes)
  ├─ dev:datin-api (watches for changes)
  └─ dev:datin-discovery (watches for changes)
```

All services start in development mode.

## Task Execution Order

### Scenario 1: Running Tests in CI/CD

```
$ npm run test

Step 1: Install dependencies
  ✓ npm install (once)

Step 2: Run builds (parallel)
  ├─ build:datin-web (4s)      ┐
  ├─ build:datin-api           │ All parallel
  └─ build:datin-discovery     ┘ (total: ~5s)

Step 3: Run tests (parallel, only if builds pass)
  ├─ test:datin-web (3s)       ┐
  ├─ test:datin-api (2s)       │ All parallel
  └─ test:datin-discovery (2s) ┘ (total: ~3s)

Total time: ~8s instead of 15s+ (with parallelization)
```

### Scenario 2: Linting & Formatting

```
$ npm run lint
  All jobs in parallel (no dependencies)
  ├─ lint:datin-web
  ├─ lint:datin-api
  └─ lint:datin-discovery

$ npm run format
  All jobs in parallel (no dependencies)
  ├─ format:datin-web
  ├─ format:datin-api
  └─ format:datin-discovery
```

## The `^` Caret Notation

The `^` means "workspace dependencies" (parent dependencies).

**Example:**
```
If you have:
packages/shared-types
  └─ exports type definitions

apps/datin-web
  └─ imports from packages/shared-types
```

Then:
```json
"build": {
  "dependsOn": ["^build"]
}
```

Means: "Build shared-types first, then datin-web"

**In our current monorepo:**
- No inter-workspace dependencies yet
- All services are independent
- All can build in parallel

## How Cache Works

### With cache: true (default)

```
First run:
  $ npm run build
  ├─ build:datin-web (runs, caches result)
  ├─ build:datin-api (runs, caches result)
  └─ build:datin-discovery (runs, caches result)
  Time: 5s

Second run (no changes):
  $ npm run build
  ├─ build:datin-web (SKIPPED - cached)
  ├─ build:datin-api (SKIPPED - cached)
  └─ build:datin-discovery (SKIPPED - cached)
  Time: <1s
```

### With cache: false (lint/format)

```
First run:
  $ npm run lint
  ├─ lint:datin-web (runs)
  ├─ lint:datin-api (runs)
  └─ lint:datin-discovery (runs)
  Time: 2s

Second run (same code):
  $ npm run lint
  ├─ lint:datin-web (RUNS AGAIN - no cache)
  ├─ lint:datin-api (RUNS AGAIN - no cache)
  └─ lint:datin-discovery (RUNS AGAIN - no cache)
  Time: 2s
```

## Outputs Configuration

`outputs` tells Turborepo what to cache:

```json
"build": {
  "outputs": ["dist/**", ".next/**", "build/**"]
}
```

**Caches:**
- `dist/**` - Python build output (if any)
- `.next/**` - Next.js build output
- `build/**` - Generic build output

**Benefits:**
- Don't rebuild if outputs exist
- Faster CI/CD on subsequent runs
- Share cache across machines (with remote cache)

## Why Test Depends on Build

```json
"test": {
  "dependsOn": ["^build"]
}
```

**Reasons:**
1. **Tests need compiled code** - Tests run against built app
2. **Build dependencies are needed** - Can't test without building
3. **Proper order** - Can't test before building

**Example:**
```
TypeScript needs compilation before running tests:

Source: app.ts
  ↓ (build step)
Build: app.js
  ↓ (test step)
Result: test output
```

## Visualization

```
Development Flow:
┌─────────────┐
│ npm run dev │
└──────┬──────┘
       │ (no dependencies)
       ├─→ dev:datin-web (localhost:3000)
       ├─→ dev:datin-api (localhost:8000)
       └─→ dev:datin-discovery (localhost:8001)

Build Flow:
┌──────────────┐
│ npm run build│
└──────┬───────┘
       │ (^build)
       ├─→ build:datin-web
       ├─→ build:datin-api
       └─→ build:datin-discovery
         (all parallel, no dependencies)

Test Flow:
┌─────────────┐
│ npm run test│
└──────┬──────┘
       │
       ├─ build:* (all parallel)
       │   ├─→ build:datin-web
       │   ├─→ build:datin-api
       │   └─→ build:datin-discovery
       │
       └─ test:* (all parallel, after build)
           ├─→ test:datin-web
           ├─→ test:datin-api
           └─→ test:datin-discovery

Lint Flow:
┌──────────────┐
│ npm run lint │
└──────┬───────┘
       │ (no dependencies, no cache)
       ├─→ lint:datin-web
       ├─→ lint:datin-api
       └─→ lint:datin-discovery
         (all parallel)
```

## Summary

✅ **Dependencies Added:**
- `build`: depends on `^build` (workspace deps)
- `test`: depends on `^build` (must build first)
- `lint`: no cache (always fresh)
- `format`: no cache (always fresh)

✅ **Benefits:**
- Proper task ordering
- Parallel execution where possible
- Faster CI/CD times
- Correct testing workflow
- No incorrect cached results

✅ **Our Monorepo:**
- All services are independent (for now)
- All build tasks run in parallel
- Tests wait for builds
- Linting is always fresh

✅ **Future Scaling:**
- Add `dependsOn: ["@shared/core"]` if services need shared code
- Turborepo will automatically order builds correctly
- No manual configuration needed
