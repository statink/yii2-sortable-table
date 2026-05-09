# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CLAUDE.md の保守

コード変更によって本ファイルの記述と実態が乖離する場合は、変更と同時に CLAUDE.md も更新してください。特に以下を変更したときは見直しが必要です:

- `Makefile` のターゲットやビルドパイプライン
- `composer.json` / `package.json` の依存関係や `browserslist`
- `tsconfig.json` / `eslint.config.js` の設定
- `src/` 配下のアセットバンドル構成 (依存関係・公開ファイル・`sourcePath` など)
- `assets/sortable-table.ts` の前提 (Font Awesome のクラス名や対象セレクタなど)

## このリポジトリの概要

stat.ink で使用されている Yii2 アセットバンドルパッケージ (`statink/yii2-sortable-table`) です。jQuery プラグイン `stupid-table-plugin` をラップし、ソート中の列に Font Awesome の上下矢印を表示する小さなスクリプトを追加しています。本体の stat.ink アプリから Composer 経由で読み込まれ、`assets/` 配下の JS 成果物はリポジトリにコミットされたものがそのまま配布されます。

## ビルドコマンド

ビルドは `Makefile` によって駆動され、Composer と npm を統括します:

- `make` — PHP 依存関係をインストールし、JS 成果物を再ビルドします (デフォルトターゲット = `php js`)。
- `make js` — `assets/sortable-table.min.js` (および `.gz`, `.br`) を再ビルドします。パイプラインは `*.ts` → tsc → `*.js` → terser → `*.min.js` → gzip / brotli です。再ビルドを強制したい場合は `assets/sortable-table.ts` を touch してください。中間ファイルの `*.js` は保持されます (`.PRECIOUS`)。
- `make typecheck` — `tsc --noEmit` で型チェックのみを実行します。
- `make lint` — ESLint (neostandard, flat config) で `*.ts` を検査します。`--fix` 相当は `npx eslint --fix .` を直接実行してください。
- `make clean` — `assets/` 配下の生成済み JS と `*.tsbuildinfo` を削除します (`.ts` ソースは残します)。
- `make dist-clean` — さらに `composer.phar`, `vendor/`, `node_modules/` も削除します。

Makefile は `composer.phar` の自動取得、`composer.lock` に対する `composer install`/`update`、`package-lock.json` に対する `npm install`/`update` を行います。また、実行時に `brotli` と旧来の `bro` バイナリを自動で使い分けます。

テストスイート・CI 設定はこのリポジトリには存在しません。

## アーキテクチャ

`src/` 配下に 2 つのアセットバンドルがあり、いずれも名前空間は `statink\yii2\sortableTable\` です:

- `JqueryStupidTableAsset` — npm パッケージ `stupid-table-plugin` の `stupidtable.min.js` を公開します。`sourcePath` は `@npm/stupid-table-plugin` で、`composer.json` に Composer リポジトリとして設定された `asset-packagist.org` 経由で解決されます (`fxp-asset` は無効化済み)。`yii\web\JqueryAsset` に依存します。
- `SortableTableAsset` — このパッケージ自身の `sortable-table.min.js` を `@vendor/statink/yii2-sortable-table/assets` から公開します。`JqueryStupidTableAsset` に依存します。注意点: このバンドルは Font Awesome (`fas fa-angle-up` / `fa-angle-down`) が利用側アプリで読み込まれていることを前提としています。`FontAwesomeAsset::class` の依存指定が意図的にコメントアウトされており、Font Awesome バンドルは別途登録する必要があります。

ランタイムスクリプト (`assets/sortable-table.ts`) は `$('.table-sortable').stupidtable()` を初期化し、`aftertablesort` イベントで `<th>` 行内の `.arrow` span を削除した上で、ソート中の列に Font Awesome の矢印を追加します。ソート矢印の挙動やマークアップを変更する場合は `.ts` ファイルを編集し、`make js` を実行してください。生成された `.js`/`.min.js` を直接編集してはいけません。

## TypeScript / Lint 環境

- `tsconfig.json`: `target: ES2022`, `lib: ["ES2022", "DOM"]`, `strict: true`, `noUncheckedIndexedAccess: true`, `noEmitOnError: true`, `skipLibCheck: true`, `types: ["jquery"]`。
- `module` / `moduleResolution` / `outDir` / `rootDir` は **意図的に未設定**: `outDir` を `assets` に置くと `include` から自動除外されてしまうため、`.ts` の隣に `.js` を出力するデフォルト挙動に任せています。
- `assets/types/stupid-table-plugin.d.ts`: stupid-table-plugin の自前アンビエント型 (`JQuery.stupidtable()`, `$.fn.stupidtable.dir`, `aftertablesort` イベントの `data` 形状)。`@types/jquery` は v4 系で globals が auto-load されないため、`tsconfig` の `types: ["jquery"]` で明示的に読み込んでいます。
- `eslint.config.js`: ESLint 9 (flat config) + `neostandard({ ts: true, semi: true })`。**ESLint 10 は neostandard 0.13 が peer に対応していない** ため固定 (将来 neostandard が ESLint 10 対応したら同時に上げてください)。
- 配布物に `.ts`, `.d.ts`, `tsconfig.json`, `eslint.config.js` も含まれます (Composer 配布から除外していません)。

## 依存関係の更新時の注意

- npm パッケージ `stupid-table-plugin` のバージョン更新は、`composer update` で行います (`npm-asset/*` パッケージとして asset-packagist 経由で取得されるため)。npm では更新しません。本リポジトリの npm `package.json` は TypeScript / ESLint / terser のツールチェーンを管理しています。
- `package.json` の `browserslist` は IE 11 を **明示的に除外** しています (`not Explorer <= 11`)。対象は「シェア 1% 以上」「各ブラウザの最新メジャー 2 バージョン」「Firefox ESR」「dead 扱いでないもの」「KaiOS 2.5 以下を除く」です。現状は babel を使っていないため `browserslist` を読むツールはなく、**ターゲットドキュメントとしての位置付け** です。`tsc` の `target` (ES2022) を上げる/下げる判断材料として参照してください。
- ES ターゲットを変更する場合は、resolve 結果のうち最古エンジン (現状は KaiOS 3.0 ≒ Gecko 84) との突き合わせが必要です。`npx browserslist` で確認できます。
