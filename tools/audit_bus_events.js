#!/usr/bin/env node
// Scan games/web for Bus event usage (emit/on/once) and output a JSON report.

import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const scanRoot = path.resolve(repoRoot, '..', 'games', 'web');
const outputPath = path.join(repoRoot, 'docs', '_generated', 'bus-events.json');

const allowedExt = new Set(['js', 'ts', 'mjs', 'cjs', 'jsx', 'vue', 'php', 'html', 'htm']);
const ignoreDirs = new Set(['.git', 'node_modules', 'dist']);

// Matches Bus emit/on/once calls, including window.Bus and optional chaining.
const BUS_CALL_RE = /(window\.)?Bus(?:\?\.|\.)\s*(emit|on|once)\s*\(\s*(['"`])([^'"`]+?)\3/gm;

const readDirSafe = async (dir) => {
  try {
    return await fs.readdir(dir, { withFileTypes: true });
  } catch (err) {
    if (err.code === 'ENOENT') return null;
    throw err;
  }
};

const walk = async (dir, collector) => {
  const entries = await readDirSafe(dir);
  if (!entries) return;

  for (const entry of entries) {
    if (ignoreDirs.has(entry.name)) continue;
    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      await walk(fullPath, collector);
      continue;
    }

    if (!entry.isFile()) continue;
    const ext = path.extname(entry.name).slice(1).toLowerCase();
    if (!allowedExt.has(ext)) continue;

    collector.push(fullPath);
  }
};

const lineInfo = (content, index) => {
  const before = content.slice(0, index);
  const line = before.split(/\r?\n/).length;
  const lineStart = before.lastIndexOf('\n') + 1;
  const nextBreak = content.indexOf('\n', index);
  const lineEnd = nextBreak === -1 ? content.length : nextBreak;
  const snippet = content.slice(lineStart, lineEnd).trim();
  return { line, snippet };
};

const scanFile = async (file) => {
  const content = await fs.readFile(file, 'utf8');
  const matches = [];

  BUS_CALL_RE.lastIndex = 0;
  let m;
  while ((m = BUS_CALL_RE.exec(content)) !== null) {
    const { line, snippet } = lineInfo(content, m.index);
    matches.push({
      event: m[4],
      kind: m[2],
      line,
      snippet,
    });
  }

  return matches;
};

const sortOccurrences = (occurrences) =>
  occurrences.sort((a, b) => {
    if (a.file === b.file) return a.line - b.line;
    return a.file.localeCompare(b.file);
  });

const main = async () => {
  const filesToScan = [];
  await walk(scanRoot, filesToScan);

  if (filesToScan.length === 0) {
    console.error(`Scan root not found or empty: ${scanRoot}`);
    process.exit(1);
  }

  const events = new Map();
  let totalOccurrences = 0;

  for (const file of filesToScan) {
    const relativeFile = path.relative(repoRoot, file);
    const matches = await scanFile(file);
    if (!matches.length) continue;

    totalOccurrences += matches.length;

    for (const match of matches) {
      const existing = events.get(match.event) || {
        name: match.event,
        occurrences: [],
        counts: { emit: 0, on: 0, once: 0 },
      };

      existing.occurrences.push({
        file: relativeFile,
        line: match.line,
        kind: match.kind,
        snippet: match.snippet,
      });
      existing.counts[match.kind] += 1;

      events.set(match.event, existing);
    }
  }

  const sortedEvents = Array.from(events.values()).sort((a, b) =>
    a.name.localeCompare(b.name)
  );

  for (const evt of sortedEvents) {
    sortOccurrences(evt.occurrences);
  }

  const output = {
    generatedAt: new Date().toISOString(),
    scanRoot: path.relative(repoRoot, scanRoot),
    ignore: Array.from(ignoreDirs),
    fileExtensions: Array.from(allowedExt),
    filesScanned: filesToScan.length,
    totals: {
      uniqueEvents: sortedEvents.length,
      occurrences: totalOccurrences,
    },
    events: sortedEvents,
  };

  await fs.mkdir(path.dirname(outputPath), { recursive: true });
  await fs.writeFile(outputPath, `${JSON.stringify(output, null, 2)}\n`, 'utf8');

  console.log(`Bus audit written to ${path.relative(repoRoot, outputPath)}`);
  console.log(`Events: ${sortedEvents.length} | Occurrences: ${totalOccurrences}`);
};

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
