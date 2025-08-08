#!/bin/bash

tar -cjf devenv.tar.bz2 \
    --exclude='packages/css/node_modules' \
    --exclude='packages/js/node_modules' \
    packages/ \
    .editorconfig \
    eslint.config.ts \
    .gitattributes \
    .gitignore \
    .npmrc \
    .nvmrc \
    package.json \
    pnpm-lock.yaml \
    pnpm-workspace.yaml \
    stylelint.config.ts \
    .vscode/extensions.json \
    .vscode/.linux/install.env \
    .vscode/.linux/install.sh \
    .vscode/.linux/install.svg \
    .vscode/.linux/fonts/ \
    .vscode/.linux/scripts/ \
    .vscode/.linux/templates/ \
    .vscode/.linux/themes/
