/*!
 * @copyright Copyright (C) 2015-2026 AIZAWA Hina
 * @license https://github.com/fetus-hina/stat.ink/blob/master/LICENSE MIT
 * @author AIZAWA Hina <hina@fetus.jp>
 *
 * Ambient type declarations for stupid-table-plugin
 * https://github.com/joequery/Stupid-Table-Plugin
 */

interface StupidTableSortDir {
  readonly ASC: 'asc';
  readonly DESC: 'desc';
}

type StupidTableSortDirection = StupidTableSortDir[keyof StupidTableSortDir];

type StupidTableComparator = (a: string, b: string) => number;

interface StupidTableSortMethod {
  (options?: Record<string, StupidTableComparator>): JQuery;
  dir: StupidTableSortDir;
}

interface StupidTableSortEventData {
  column: number;
  direction: StupidTableSortDirection;
  $th: JQuery;
}

interface JQuery {
  stupidtable: StupidTableSortMethod;
}
