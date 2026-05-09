# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CLAUDE.md の保守

コード変更によって本ファイルの記述と実態が乖離する場合は、変更と同時に CLAUDE.md も更新してください。特に以下を変更したときは見直しが必要です:

- `Makefile` のターゲットやビルドパイプライン
- `composer.json` / `package.json` の依存関係や `browserslist`
- `src/` 配下のアセットバンドル構成 (依存関係・公開ファイル・`sourcePath` など)
- `assets/sortable-table.es` の前提 (Font Awesome のクラス名や対象セレクタなど)

## このリポジトリの概要

stat.ink で使用されている Yii2 アセットバンドルパッケージ (`statink/yii2-sortable-table`) です。jQuery プラグイン `stupid-table-plugin` をラップし、ソート中の列に Font Awesome の上下矢印を表示する小さなスクリプトを追加しています。本体の stat.ink アプリから Composer 経由で読み込まれ、`assets/` 配下の JS 成果物はリポジトリにコミットされたものがそのまま配布されます。

## ビルドコマンド

ビルドは `Makefile` によって駆動され、Composer と npm を統括します:

- `make` — PHP 依存関係をインストールし、JS 成果物を再ビルドします (デフォルトターゲット = `php js`)。
- `make js` — `assets/sortable-table.min.js` (および `.gz`, `.br`) を再ビルドします。パイプラインは `*.es` → babel (`@babel/preset-env`) → `*.js` → uglify-js → `*.min.js` → gzip / brotli です。再ビルドを強制したい場合は `assets/sortable-table.es` を touch してください。中間ファイルの `*.js` は保持されます (`.PRECIOUS`)。
- `make clean` — `assets/` 配下の生成済み JS を削除します (`.es` ソースは残します)。
- `make dist-clean` — さらに `composer.phar`, `vendor/`, `node_modules/` も削除します。

Makefile は `composer.phar` の自動取得、`composer.lock` に対する `composer install`/`update`、`package-lock.json` に対する `npm install`/`update` を行います。また、実行時に `brotli` と旧来の `bro` バイナリを自動で使い分けます。

テストスイート・リンター・CI 設定はこのリポジトリには存在しません。

## アーキテクチャ

`src/` 配下に 2 つのアセットバンドルがあり、いずれも名前空間は `statink\yii2\sortableTable\` です:

- `JqueryStupidTableAsset` — npm パッケージ `stupid-table-plugin` の `stupidtable.min.js` を公開します。`sourcePath` は `@npm/stupid-table-plugin` で、`composer.json` に Composer リポジトリとして設定された `asset-packagist.org` 経由で解決されます (`fxp-asset` は無効化済み)。`yii\web\JqueryAsset` に依存します。
- `SortableTableAsset` — このパッケージ自身の `sortable-table.min.js` を `@vendor/statink/yii2-sortable-table/assets` から公開します。`JqueryStupidTableAsset` に依存します。注意点: このバンドルは Font Awesome (`fas fa-angle-up` / `fa-angle-down`) が利用側アプリで読み込まれていることを前提としています。`FontAwesomeAsset::class` の依存指定が意図的にコメントアウトされており、Font Awesome バンドルは別途登録する必要があります。

ランタイムスクリプト (`assets/sortable-table.es`) は `$('.table-sortable').stupidtable()` を初期化し、`aftertablesort` イベントで `<th>` 行内の `.arrow` span を削除した上で、ソート中の列に Font Awesome の矢印を追加します。ソート矢印の挙動やマークアップを変更する場合は `.es` ファイルを編集し、`make js` を実行してください。生成された `.js`/`.min.js` を直接編集してはいけません。

## 依存関係の更新時の注意

- npm パッケージ `stupid-table-plugin` のバージョン更新は、`composer update` で行います (`npm-asset/*` パッケージとして asset-packagist 経由で取得されるため)。npm では更新しません。本リポジトリの npm `package.json` はビルドツールチェーン (babel + uglify-js) のみを管理しています。
- `package.json` の `browserslist` は IE 11 を **明示的に除外** しています (`not Explorer <= 11`)。対象は「シェア 1% 以上」「各ブラウザの最新メジャー 2 バージョン」「Firefox ESR」「dead 扱いでないもの」「KaiOS 2.5 以下を除く」です。`@babel/preset-env` はこの設定をそのまま参照するため、`sortable-table.es` を編集する際は IE 11 対応を前提にする必要はありません。一方で Firefox ESR は引き続きサポート対象なので、最新 Chrome/Firefox 限定の構文は避けてください。
