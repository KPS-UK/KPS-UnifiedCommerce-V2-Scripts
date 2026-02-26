# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This `scripts/` directory is a **standalone helper package** within the larger `kps-unified-commerce` monorepo. Its sole responsibility is to authenticate with GCP and emit an npm token so that the parent project can install private npm packages hosted in Google Artifact Registry.

## Install flow

Running `install.sh` (macOS/Linux) or `install.bat` (Windows) at the **parent** repo root:
1. Installs this package's own dependencies: `npm install --prefix scripts`
2. Runs `gcp-npm-auth.mjs` to obtain a GCP access token and exports it as `NPM_TOKEN`
3. Runs the parent project's install (npm on Linux/Mac, pnpm on Windows)

## Prerequisites

A `.env` file must exist at `../` (the monorepo root, one level above this directory) containing:

```
GOOGLE_APPLICATION_CREDENTIALS_JSON=<service account JSON as a single-line string>
```

`gcp-npm-auth.mjs` reads this automatically via `dotenv`.

## Key file

- **`gcp-npm-auth.mjs`** — ES module that uses `google-auth-library` to obtain a GCP access token scoped to `https://www.googleapis.com/auth/cloud-platform`, then writes the token to stdout. This token is consumed as `NPM_TOKEN` by the npm/pnpm install step.
