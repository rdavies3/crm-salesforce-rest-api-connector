#!/bin/bash

set -e

LAMBDA_DIR="../lamdas/sf-query"
ZIP_NAME="sf-query-${1}.zip"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <env>"
  exit 1
fi

cd "$LAMBDA_DIR"

echo "[Lambda Zip] Installing prod-only dependencies..."
npm ci --omit=dev

echo "[Lambda Zip] Creating zip file respecting .gitignore..."
git ls-files -z | xargs -0 zip -q -r "../../terraform/${ZIP_NAME}"

echo "[Lambda Zip] Done -> terraform/${ZIP_NAME}"
