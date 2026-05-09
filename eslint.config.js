import neostandard from 'neostandard';

export default [
  {
    ignores: [
      'assets/*.js',
      'assets/*.min.js',
      'node_modules/**',
      'vendor/**',
    ],
  },
  ...neostandard({
    ts: true,
    semi: true,
  }),
];
