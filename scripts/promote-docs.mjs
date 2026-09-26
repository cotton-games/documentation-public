#!/usr/bin/env node
// Run from a clean main checkout after develop documents the deployed release.
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const git = (...args) => execFileSync('git', args, { cwd: root, encoding: 'utf8' }).trim();
const mergeHead = () => {
  const result = spawnSync('git', ['rev-parse', '--verify', '-q', 'MERGE_HEAD'], { cwd: root, encoding: 'utf8' });
  return result.status === 0 ? result.stdout.trim() : '';
};
try {
  if (args.some(arg => arg !== '--resume') || args.length > 1) {
    throw new Error('Usage: node scripts/promote-docs.mjs [--resume]');
  }
  if (git('branch', '--show-current') !== 'main') throw new Error('Basculer sur main avant la promotion.');
  const source = git('rev-parse', '--verify', 'develop^{commit}');
  const pending = mergeHead();
  if (args.includes('--resume')) {
    if (pending !== source) throw new Error('Le merge en cours doit viser exactement la branche locale develop.');
    if (git('ls-files', '--others', '--exclude-standard')) throw new Error('Fichiers non suivis à conserver avant reprise.');
    // Refuse edits made after the automatic merge, except unresolved conflict files.
    const unresolved = new Set(git('diff', '--name-only', '--diff-filter=U').split('\n'));
    const edited = git('diff', '--name-only').split('\n').filter(p => p && !unresolved.has(p));
    if (edited.length) throw new Error(`Modifications locales à préserver avant reprise : ${edited.join(', ')}`);
  } else {
    if (pending) throw new Error('Merge déjà en cours : utiliser --resume.');
    if (git('status', '--porcelain')) throw new Error('Le checkout main doit être propre, fichiers non suivis compris.');
    const merge = spawnSync('git', ['merge', '--no-ff', '--no-commit', 'develop'], { cwd: root, stdio: 'inherit' });
    if (merge.status !== 0 && mergeHead() !== source) throw new Error('Le merge a échoué avant sa préparation.');
  }
  // The agreed source of truth is the complete develop tree, including deletions.
  // Keep MERGE_HEAD: the eventual commit retains both branches' history.
  git('restore', `--source=${source}`, '--staged', '--worktree', '--', '.');
  execFileSync(process.execPath, ['scripts/gen-sitemap.mjs'], {
    cwd: root, stdio: 'inherit',
    env: { ...process.env, DOCS_BRANCH: 'main', DOCS_VERSION_SHA: source },
  });
  git('add', '-A', '--', 'SITEMAP.md', 'SITEMAP.txt', 'SITEMAP.ndjson', ':(glob)**/INDEX.md');
  if (git('diff', '--name-only', '--diff-filter=U')) throw new Error('Des conflits restent ouverts.');
  // The existing sitemap generator deliberately ends with a blank line.
  git('-c', 'core.whitespace=-blank-at-eof', 'diff', '--cached', '--check');
  const sources = git('diff', '--cached', '--name-only', source).split('\n').filter(Boolean)
    .filter(p => !/^SITEMAP\.(md|txt|ndjson)$/.test(p) && !p.endsWith('/INDEX.md'));
  if (sources.length) throw new Error(`Sources différentes de develop : ${sources.join(', ')}`);
  console.log('Promotion préparée : sources identiques à develop, index générés pour main.');
  console.log('Vérifier git diff --cached, puis git commit. Aucun commit ni push automatique.');
} catch (error) {
  console.error(error.message);
  if (error.stdout) console.error(String(error.stdout));
  console.error('Aucun push effectué. Si un merge est ouvert, git merge --abort permet de revenir avant sa préparation.');
  process.exitCode = 1;
}
