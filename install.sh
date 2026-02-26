#!/bin/bash

npm install --prefix scripts
export NPM_TOKEN=$(node scripts/gcp-npm-auth.mjs)

npm install --no-frozen-lockfile