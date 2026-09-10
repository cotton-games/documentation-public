import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, writeFileSync, readFileSync, copyFileSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const scripts = path.dirname(fileURLToPath(import.meta.url));
function fixture(t) {
  const root = mkdtempSync(path.join(tmpdir(), 'cotton-docs-promotion-'));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const git = (...args) => execFileSync('git', args, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  const write = (p, content) => writeFileSync(path.join(root, p), content);
  git('init', '-b', 'main'); git('config', 'user.name', 'Offline test'); git('config', 'user.email', 'test@example.invalid');
  for (const dir of ['scripts', 'canon', 'notes', 'specs']) mkdirSync(path.join(root, dir));
  for (const name of ['promote-docs.mjs', 'gen-sitemap.mjs']) copyFileSync(path.join(scripts, name), path.join(root, 'scripts', name));
  for (let i = 0; i < 6; i++) { mkdirSync(path.join(root, `canon/topic-${i}`)); write(`canon/topic-${i}/README.md`, '# Fixture\n'); }
  write('README.md', '# Base\n'); write('canon/topic.md', '# Base\n');
  write('SITEMAP.md', 'base\n'); write('obsolete.md', 'base\n');
  git('add', '.'); git('commit', '-m', 'base'); git('branch', 'develop');
  write('README.md', '# Main\n'); write('SITEMAP.md', 'main\n'); write('main-only.md', 'main-only\n');
  git('add', '.'); git('commit', '-m', 'main differences');
  const previous = git('rev-parse', 'HEAD');
  git('switch', 'develop'); write('README.md', '# Develop\n'); write('SITEMAP.md', 'develop\n');
  write('canon/topic.md', '# Updated topic\n'); git('rm', 'obsolete.md'); git('add', '.'); git('commit', '-m', 'release');
  const source = git('rev-parse', 'HEAD'); git('switch', 'main');
  const run = (...args) => spawnSync(process.execPath, ['scripts/promote-docs.mjs', ...args], { cwd: root, encoding: 'utf8' });
  return { root, git, write, run, source, previous };
}
for (const resume of [false, true]) test(`promote with ${resume ? 'existing' : 'new'} conflicting merge`, t => {
  const f = fixture(t);
  if (resume) assert.throws(() => f.git('merge', '--no-ff', '--no-commit', 'develop'));
  const result = f.run(...(resume ? ['--resume'] : []));
  assert.equal(result.status, 0, result.stderr);
  assert.equal(f.git('rev-parse', 'HEAD'), f.previous, 'no automatic commit');
  assert.equal(f.git('rev-parse', 'MERGE_HEAD'), f.source);
  assert.equal(f.git('diff', '--name-only', '--diff-filter=U'), '');
  assert.equal(readFileSync(path.join(f.root, 'README.md'), 'utf8'), '# Develop\n');
  assert.equal(existsSync(path.join(f.root, 'obsolete.md')), false);
  assert.equal(existsSync(path.join(f.root, 'main-only.md')), false);
  const index = readFileSync(path.join(f.root, 'canon/INDEX.md'), 'utf8');
  assert.match(index, /refs\/heads\/main\//);
  assert.ok(index.includes(f.source));
  f.git('commit', '-m', 'promote');
  assert.equal(f.git('rev-list', '--parents', '-n', '1', 'HEAD').split(' ').length, 3, 'merge retains both parents');
});
test('reject dirty main without changing HEAD or local work', t => {
  const f = fixture(t); f.write('README.md', 'unfinished\n');
  assert.notEqual(f.run().status, 0);
  assert.equal(readFileSync(path.join(f.root, 'README.md'), 'utf8'), 'unfinished\n');
  assert.equal(f.git('rev-parse', 'HEAD'), f.previous);
});
test('reject source branch and invalid resume', t => {
  const f = fixture(t); assert.notEqual(f.run('--resume').status, 0);
  f.git('switch', 'develop'); assert.notEqual(f.run().status, 0);
});
test('resume refuses edits outside conflicted files', t => {
  const f = fixture(t); assert.throws(() => f.git('merge', '--no-ff', '--no-commit', 'develop'));
  f.write('canon/topic.md', '# Uncommitted edit\n');
  assert.notEqual(f.run('--resume').status, 0);
  assert.equal(readFileSync(path.join(f.root, 'canon/topic.md'), 'utf8'), '# Uncommitted edit\n');
});
