import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, existsSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const generator = path.resolve('scripts/gen-sitemap.mjs');
for (const branch of ['main', 'develop']) {
  test(`private navigation and legacy mirror guards: ${branch}`, () => {
    const root = mkdtempSync(path.join(tmpdir(), 'cotton-sitemap-'));
    try {
      // Enough distinct directories for the existing multiline guard, including encoding cases.
      const files = ['START.md', 'README.md', 'DOCS_MANIFEST.md', 'HANDOFF.md', 'CHANGELOG.md',
        'pm2-ws.md', 'canon/entrypoints.md', 'canon/front/games-repo.md',
        'canon/data/schema/OVERVIEW.md', 'canon/data/schema/MAP.md', 'canon/data/schema/DDL.sql',
        'canon/data/cotton-certified-direct-import.md', 'canon/data/quiz-numeric-question-adaptation-csv.md',
        'canon/interfaces/contract.md', 'canon/runbooks/dev.md', 'specs/tests/smoke.md',
        'notes/archive/history.md', 'notes/été espace #1.md'];
      for (const repo of ['documentation', 'games', 'bingo.game', 'blindtest', 'quiz']) {
        files.push(`canon/repos/${repo}/README.md`, `canon/repos/${repo}/TASKS.md`);
      }
      for (let i = 0; i < 20; i++) files.push(`notes/fixture-${i}/page.md`);
      for (const file of files) {
        mkdirSync(path.dirname(path.join(root, file)), { recursive: true });
        writeFileSync(path.join(root, file), '# Fixture\n');
      }
      const sentinel = 'test-only-credential-must-not-be-serialized';
      execFileSync(process.execPath, [generator], { cwd: root, env: {
        PATH: process.env.PATH, DOCS_BRANCH: branch, DOCS_VERSION_SHA: 'a'.repeat(40),
        COTTON_DOCS_TOKEN: sentinel,
      }});
      const ndjson = readFileSync(path.join(root, 'SITEMAP.ndjson'), 'utf8');
      const entries = ndjson.trim().split('\n').map(JSON.parse);
      const paths = new Set(entries.filter(e => e.branch === branch).map(e => e.path));
      for (const file of files) assert.ok(paths.has(file), `Missing ${file}`);
      for (const e of entries) {
        assert.equal(e.repository, 'cotton-games/documentation');
        assert.ok(existsSync(path.join(root, e.path)), e.path);
        const u = new URL(e.api_url);
        assert.equal(u.origin, 'https://api.github.com');
        assert.equal(decodeURIComponent(u.pathname), `/repos/cotton-games/documentation/contents/${e.path}`);
        assert.equal(u.searchParams.get('ref'), e.branch);
        assert.equal(e.url_role, 'legacy/transition');
        assert.ok(e.url.startsWith('https://raw.githubusercontent.com/'));
      }
      for (const name of ['SITEMAP.txt', 'SITEMAP.ndjson', 'SITEMAP.md']) {
        const content = readFileSync(path.join(root, name), 'utf8');
        assert.ok(content.endsWith('\n'));
        assert.ok(content.trim().split('\n').length > 50);
        assert.ok(!content.includes(sentinel));
        assert.ok(!/https?:\/\/[^\s]*\.\.\./.test(content));
      }
      for (const url of readFileSync(path.join(root, 'SITEMAP.txt'), 'utf8').split('\n').filter(l => l && !l.startsWith('#'))) {
        assert.ok(url.startsWith('https://raw.githubusercontent.com/'));
      }
      for (const name of ['SITEMAP.md', ...entries.map(e => e.path).filter(p => p.endsWith('/INDEX.md'))]) {
        const content = readFileSync(path.join(root, name), 'utf8');
        assert.ok(!content.includes('documentation-public'));
        for (const [, url] of content.matchAll(/\]\((https:[^)]+)\)/g)) {
          assert.equal(new URL(url).origin, 'https://api.github.com');
        }
      }
      // A second pass must be stable, including newly created directory indexes.
      execFileSync(process.execPath, [generator], { cwd: root, env: {
        PATH: process.env.PATH, DOCS_BRANCH: branch, DOCS_VERSION_SHA: 'a'.repeat(40),
      }});
      assert.equal(readFileSync(path.join(root, 'SITEMAP.ndjson'), 'utf8'), ndjson);
    } finally {
      rmSync(root, { recursive: true, force: true });
    }
  });
}
