import fs from "node:fs/promises";
import path from "node:path";
import fsSync from "node:fs";

const IGNORED_DIR_NAMES = new Set([
  ".git",
  ".github",
  "node_modules",
  "dist",
  "build",
]);

// Guard against compact/one-line outputs (e.g., if a tool strips newlines)
const MIN_SITEMAP_LINES = 40;
const RAW_PREFIX = "https://raw.githubusercontent.com/";

function toPosixPath(p) {
  return p.split(path.sep).join("/");
}

function isIgnoredName(name) {
  return name.startsWith("_") || IGNORED_DIR_NAMES.has(name);
}

function encodePathForRawUrl(posixRelPath) {
  return posixRelPath
    .split("/")
    .map((segment) => encodeURIComponent(segment))
    .join("/");
}

// Canonical authenticated reads; never read or serialize credentials here.
const DOCS_REPOSITORY = "cotton-games/documentation";
function apiUrl(relPath, branch) {
  return `https://api.github.com/repos/${DOCS_REPOSITORY}/contents/${encodePathForRawUrl(relPath)}?ref=${branch}`;
}

function getDocsBranch() {
  const fromEnv =
    process.env.DOCS_BRANCH ||
    process.env.GITHUB_REF_NAME ||
    process.env.GITHUB_HEAD_REF;
  const branch = (fromEnv && fromEnv !== "HEAD" ? fromEnv : "").trim() || "develop";

  if (branch !== "develop" && branch !== "main") {
    throw new Error(
      `Unsupported DOCS_BRANCH=${JSON.stringify(branch)} (expected \"develop\" or \"main\").`,
    );
  }

  return branch;
}

function getVersionSha(repoRoot) {
  const fromEnv = (process.env.DOCS_VERSION_SHA || "").trim();
  if (fromEnv) {
    if (!/^[0-9a-f]{40}$/i.test(fromEnv)) {
      throw new Error(
        `DOCS_VERSION_SHA must be a 40-hex git SHA (got ${fromEnv.length} chars)`,
      );
    }
    return fromEnv.toLowerCase();
  }
  return readHeadSha(repoRoot);
}

function resolveGitDir(repoRoot) {
  const dotGitPath = path.join(repoRoot, ".git");
  const stat = fsSync.statSync(dotGitPath);
  if (stat.isDirectory()) {
    return dotGitPath;
  }

  const dotGitFile = fsSync.readFileSync(dotGitPath, "utf8").trim();
  const match = dotGitFile.match(/^gitdir:\s*(.+)$/i);
  if (!match) {
    throw new Error(`Unsupported .git file format in ${dotGitPath}`);
  }
  return path.resolve(repoRoot, match[1].trim());
}

function readPackedRef(gitDir, ref) {
  const packedRefsPath = path.join(gitDir, "packed-refs");
  if (!fsSync.existsSync(packedRefsPath)) {
    return "";
  }

  const packedRefs = fsSync.readFileSync(packedRefsPath, "utf8").split("\n");
  for (const line of packedRefs) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || trimmed.startsWith("^")) {
      continue;
    }
    const [sha, packedRef] = trimmed.split(" ");
    if (packedRef === ref && /^[0-9a-f]{40}$/i.test(sha)) {
      return sha.toLowerCase();
    }
  }
  return "";
}

function readHeadSha(repoRoot) {
  const gitDir = resolveGitDir(repoRoot);
  const headPath = path.join(gitDir, "HEAD");
  const head = fsSync.readFileSync(headPath, "utf8").trim();
  if (head.startsWith("ref:")) {
    const ref = head.split(" ")[1].trim();
    const refPath = path.join(gitDir, ref);
    if (fsSync.existsSync(refPath)) {
      return fsSync.readFileSync(refPath, "utf8").trim();
    }
    const packedSha = readPackedRef(gitDir, ref);
    if (packedSha) {
      return packedSha;
    }
    throw new Error(`Unable to resolve git ref ${ref} from ${gitDir}`);
  }
  return head;
}

async function listMarkdownFilesInRoot(repoRoot) {
  const entries = await fs.readdir(repoRoot, { withFileTypes: true });
  const result = [];

  for (const entry of entries) {
    if (!entry.isFile()) continue;
    if (isIgnoredName(entry.name)) continue;
    if (!entry.name.endsWith(".md")) continue;
    if (entry.name === "SITEMAP.md") continue;
    result.push(entry.name);
  }

  return result;
}

async function walkMarkdownFiles(dirRelPath) {
  const result = [];
  const dirAbsPath = path.resolve(dirRelPath);
  const entries = await fs.readdir(dirAbsPath, { withFileTypes: true });

  for (const entry of entries) {
    if (isIgnoredName(entry.name)) continue;

    const entryRelPath = path.join(dirRelPath, entry.name);
    const entryAbsPath = path.resolve(entryRelPath);

    if (entry.isDirectory()) {
      result.push(...(await walkMarkdownFiles(entryRelPath)));
      continue;
    }

    if (entry.isFile() && entry.name.endsWith(".md")) {
      result.push(toPosixPath(path.relative(process.cwd(), entryAbsPath)));
    }
  }

  return result;
}

function compareByDirThenName(a, b) {
  const dirA = path.posix.dirname(a) === "." ? "" : path.posix.dirname(a);
  const dirB = path.posix.dirname(b) === "." ? "" : path.posix.dirname(b);
  const dirCmp = dirA.localeCompare(dirB, "en", { sensitivity: "base" });
  if (dirCmp !== 0) return dirCmp;
  return a.localeCompare(b, "en", { sensitivity: "base" });
}

function buildDirIndexMap(filePaths) {
  const map = new Map();

  function ensure(dir) {
    if (!map.has(dir)) {
      map.set(dir, { files: [], subdirs: new Set() });
    }
    return map.get(dir);
  }

  for (const file of filePaths) {
    const dir = path.posix.dirname(file);
    ensure(dir).files.push(file);

    let child = dir;
    while (child !== ".") {
      const parent = path.posix.dirname(child);
      ensure(parent).subdirs.add(child);
      child = parent;
    }
  }

  return map;
}

function formatDirLabel(dir) {
  return dir === "." ? "root" : dir;
}

function mdLink(label, url) {
  assertNoEllipsisUrls(url, `url for label ${JSON.stringify(label)}`);
  return `[${label}](${url})`;
}

function assertNoEllipsisUrls(content, context = "") {
  const urls = [...content.matchAll(/https?:\/\/[^\s)>"']+/g)].map((m) => m[0]);
  const offenders = urls.filter((u) => u.includes("..."));
  if (offenders.length === 0) return;

  const prefix = context ? `${context}: ` : "";
  throw new Error(
    `${prefix}detected URL(s) containing ellipsis (...) which would publish truncated links: ${offenders.join(", ")}`,
  );
}

function assertRawUrls(urls, context = "") {
  const offenders = urls.filter((u) => !u.startsWith(RAW_PREFIX));
  if (offenders.length === 0) return;
  const prefix = context ? `${context}: ` : "";
  throw new Error(`${prefix}detected URL(s) not starting with ${RAW_PREFIX}: ${offenders.join(", ")}`);
}

function assertSitemapShape(content) {
  const lineCount = content.split("\n").length;
  if (!content.endsWith("\n")) {
    throw new Error("SITEMAP guard: generated content must end with a trailing newline.");
  }
  if (lineCount < MIN_SITEMAP_LINES) {
    throw new Error(
      `SITEMAP guard: generated content too short (${lineCount} lines < ${MIN_SITEMAP_LINES}); aborting to avoid compact publish.`,
    );
  }

  assertNoEllipsisUrls(content, "SITEMAP guard");
}

function assertPlainRawSitemapShape(name, content, minLines = 10) {
  const lineCount = content.split("\n").length;
  if (!content.endsWith("\n")) {
    throw new Error(`${name} guard: generated content must end with a trailing newline.`);
  }
  if (lineCount < minLines) {
    throw new Error(
      `${name} guard: generated content too short (${lineCount} lines < ${minLines}); aborting to avoid compact publish.`,
    );
  }
  assertNoEllipsisUrls(content, `${name} guard`);
}

async function writeVerifiedFile(targetPath, content, guardName, minLines = 10) {
  assertPlainRawSitemapShape(guardName, content, minLines);
  await fs.writeFile(targetPath, content, "utf8");
  const written = await fs.readFile(targetPath, "utf8");
  assertPlainRawSitemapShape(`${guardName} post-write`, written, minLines);
}

async function writeDirIndex({ repoRoot, dir, dirInfo, branch }) {
  const { files = [], subdirs = new Set() } = dirInfo;
  const indexPath = path.join(repoRoot, dir, "INDEX.md");

  // Custom hand-written index for canon/front (keep generator as source of truth)
  if (dir === "canon/front") {
    const lines = [
      "<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->",
      "",
      "# Front",
      "",
      "## Repo games (canvas)",
      `- [games-repo.md](${apiUrl("canon/front/games-repo.md", branch)})`,
      "",
      "_Organizer / player / remote ; telemetry avec writer unique via `logger.global.js`._",
      "",
    ];

    await fs.writeFile(indexPath, lines.join("\n"), "utf8");
    return;
  }

  const pages = files
    .filter((f) => path.posix.basename(f).toLowerCase() !== "index.md")
    .map((f) => ({
      label: path.posix.basename(f),
      url: apiUrl(toPosixPath(f), branch),
    }))
    .sort((a, b) => a.label.localeCompare(b.label, "en", { sensitivity: "base" }));

  const childDirs = [...subdirs]
    .filter((subdir) => path.posix.dirname(subdir) === dir)
    .map((subdir) => ({
      label: `${path.posix.basename(subdir)}/`,
      url: apiUrl(path.posix.join(subdir, "INDEX.md"), branch),
    }))
    .sort((a, b) => a.label.localeCompare(b.label, "en", { sensitivity: "base" }));

  const lines = [
    "<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->",
    "",
    `# Index — ${formatDirLabel(dir)}`,
    "",
  ];

  if (pages.length > 0) {
    lines.push("## Pages", ...pages.map(({ label, url }) => `- ${mdLink(label, url)}`), "");
  }

  if (childDirs.length > 0) {
    lines.push(
      "## Sous-dossiers",
      ...childDirs.map(({ label, url }) => `- ${mdLink(label, url)}`),
      "",
    );
  }

  await fs.writeFile(indexPath, lines.join("\n"), "utf8");
}

async function main() {
  const repoRoot = process.cwd();
  const branch = getDocsBranch();
  const versionSha = getVersionSha(repoRoot);
  const baseUrl = `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/${branch}/`;
  // Public raw URLs below are legacy / transition, retained for unchanged mirror CI.
  const rawUrl = (relPath, cacheBust = true) =>
    `${baseUrl}${encodePathForRawUrl(relPath)}${cacheBust ? `?v=${versionSha}` : ""}`;

  const publishedFiles = [];
  publishedFiles.push(...(await listMarkdownFilesInRoot(repoRoot)));
  publishedFiles.push(...(await walkMarkdownFiles("canon")));
  publishedFiles.push(...(await walkMarkdownFiles("specs")));
  publishedFiles.push(...(await walkMarkdownFiles("notes")));

  const uniqueFiles = [...new Set(publishedFiles)].sort(compareByDirThenName);
  const dirMap = buildDirIndexMap(uniqueFiles);

  const generatedIndexPaths = [];
  for (const [dir, info] of dirMap.entries()) {
    if (dir === ".") continue;
    await writeDirIndex({ repoRoot, dir, dirInfo: info, branch });
    generatedIndexPaths.push(toPosixPath(path.join(dir, "INDEX.md")));
  }

  const rootFiles = uniqueFiles.filter((p) => path.posix.dirname(p) === ".");
  const filesForSitemap = [...new Set([...rootFiles, ...generatedIndexPaths])].sort(
    compareByDirThenName,
  );

  const link = (relPath) => {
    const url = rawUrl(relPath);
    return { label: relPath, url, api: apiUrl(relPath, branch) };
  };

  const branchEntries = [
    {
      name: "develop",
      raw: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/develop/SITEMAP.md?v=${versionSha}`,
      view: "https://github.com/cotton-games/documentation-public/blob/develop/SITEMAP.md",
      shaTag: branch === "develop" ? ` | sha ${versionSha}` : "",
    },
    {
      name: "main",
      raw: "https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/main/SITEMAP.md",
      view: "https://github.com/cotton-games/documentation-public/blob/main/SITEMAP.md",
      shaTag: branch === "main" ? ` | sha ${versionSha}` : "",
    },
  ];

  const branchLine = ({ name, shaTag }) =>
    `- ${name}: [START API](${apiUrl("START.md", name)}) | [sitemap API](${apiUrl("SITEMAP.ndjson", name)})${shaTag}`;

  const sections = {
    branches: branchEntries,
    repos: [
      link("canon/repos/INDEX.md"),
      link("canon/repos/documentation/README.md"),
      link("canon/repos/documentation/TASKS.md"),
      link("canon/repos/games/README.md"),
      link("canon/repos/games/TASKS.md"),
      link("canon/repos/bingo.game/README.md"),
      link("canon/repos/bingo.game/TASKS.md"),
      link("canon/repos/bingo.game/INDEX.md"),
      link("canon/repos/blindtest/README.md"),
      link("canon/repos/blindtest/TASKS.md"),
      link("canon/repos/blindtest/INDEX.md"),
      link("canon/repos/quiz/README.md"),
      link("canon/repos/quiz/TASKS.md"),
      link("canon/repos/quiz/INDEX.md"),
    ],
    dbSchema: [
      link("canon/data/schema/OVERVIEW.md"),
      link("canon/data/schema/MAP.md"),
      link("canon/data/schema/DDL.sql"),
    ],
    globalSpecs: [
      link("canon/INDEX.md"),
	      link("canon/interfaces/INDEX.md"),
	      link("canon/data/INDEX.md"),
	      link("canon/data/cotton-certified-direct-import.md"),
	      link("canon/data/quiz-numeric-question-adaptation-csv.md"),
	      link("canon/runbooks/INDEX.md"),
      link("specs/INDEX.md"),
      link("specs/tests/INDEX.md"),
    ],
    projectStatus: [
      link("START.md"),
      link("README.md"),
      link("DOCS_MANIFEST.md"),
      link("HANDOFF.md"),
      link("CHANGELOG.md"),
      link("pm2-ws.md"),
    ],
    notes: [
      link("notes/INDEX.md"),
      link("notes/archive/INDEX.md"),
    ],
    other: [
      link("canon/front/INDEX.md"),
      link("canon/entrypoints.md"),
    ],
  };

  const readmeUrl = apiUrl("README.md", branch);
  const shareUrl = apiUrl("SITEMAP.ndjson", branch);

  const lines = [
    "# Cotton Documentation — SITEMAP",
    "",
    `**Navigation API privée (authentification requise) :** <${shareUrl}>`,
    "",
    "Lire avec les headers de START.md ; COTTON_DOCS_TOKEN pour Codex, jamais dans une URL.",
    "",
    "<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->",
    "",
    "# Cotton Documentation — Navigation",
    "",
    `**Start here**: lire le README général (${readmeUrl}) avant d'ouvrir \`canon/repos/*\` (entrypoint obligatoire).`,
    "Ne pas naviguer directement dans les sous-repos sans ce contexte.",
    "",
    "Canonical repository: `cotton-games/documentation`. Entrypoint: `START.md` → `SITEMAP.ndjson` → `DOCS_MANIFEST.md` → targeted paths.",
    "- `main` = référence publiée PROD avec exclusions explicites ; `develop` = préparation. Preuve : URL API + chemin + branche + heading ; absent = `non trouvé`.",
    "- `SITEMAP.txt` et le champ NDJSON `url` sont legacy / transition ; utiliser `api_url` pour les lectures privées.",
    "- Web AI agents must orchestrate and delegate edits to Codex; do not propose code patches in chat.",
    "- Verification-first: if unsure/missing info, don’t guess—organize verification (user or Codex audit).",
    "- IDE agents: **do not edit `SITEMAP.md` or `canon/**/INDEX.md` directly**; edit `scripts/gen-sitemap.mjs` if structure must change, then run `npm run docs:sitemap`.",
    "",
    "## How to use (humans + AI agents)",
    "1) **Read first**",
    "   - `README.md` → what this repo is, how to navigate, editing rules",
    "   - `DOCS_MANIFEST.md` → “update triggers” (what code change → what doc to update)",
    "   - `HANDOFF.md` → current state, what’s confirmed, what’s next, risks/debt",
    "",
    "2) **Choose by intent**",
    "   - **Integrate / understand API & contracts** → `canon/interfaces/*`",
    "   - **Find endpoints / env vars / ports** → `canon/entrypoints.md`",
    "   - **Run locally / dev ops** → `canon/runbooks/dev.md`",
    "   - **Troubleshoot (403, tokens, connectivity, etc.)** → `canon/runbooks/troubleshooting.md`",
    "   - **Data model / writes** → `canon/data/*`",
    "   - **Project status / roadmap** → `HANDOFF.md`",
    "   - **User-facing changes** → `CHANGELOG.md`",
    "   - **Deep dives / historical reasoning** (not source of truth) → `notes/*`",
    "",
    "3) **Editing rules (critical)**",
    "   - **`canon/` is source-of-truth.** `notes/` is non-canon (context only).",
    "   - Some files contain `AUTO-UPDATE` blocks:",
    "     - AI tools may edit **only inside** `AUTO-UPDATE` blocks.",
    "     - **Do not change block IDs.** Humans edit outside these blocks.",
    "   - When code changes, update docs using the mapping in `DOCS_MANIFEST.md`.",
    "",
    "---",
    "",
    "## Branches",
    `Lire via API Contents avec ref explicite. SHA source de génération : ${versionSha} (ne fige pas la branche distante).`,
    ...sections.branches.map((b) => branchLine(b)),
    "",
    "## Repos (repo-first)",
    ...sections.repos.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
    "## Global specs",
    ...sections.globalSpecs.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
    "## DB schema (global)",
    ...sections.dbSchema.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
    "## Project status",
    ...sections.projectStatus.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
    "## Notes & archive",
    ...sections.notes.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
    "## Other",
    ...sections.other.map(({ label, api }) => `- ${mdLink(label, api)}`),
    "",
  ];

  const content = `${lines.join("\n")}\n`;
  assertSitemapShape(content);
  await fs.writeFile(path.join(repoRoot, "SITEMAP.md"), content, "utf8");

  // Agent-first plain text (raw-only URLs, 1 per line)
  const txtLines = ["# LEGACY / TRANSITION — public mirror compatibility only; private agents use SITEMAP.ndjson api_url (see START.md)"];
  const pushSection = (title) => txtLines.push(`# ${title}`);

  pushSection("Branches");
  for (const b of sections.branches) {
    txtLines.push(b.raw);
  }

  pushSection("Repos");
  for (const { url } of sections.repos) txtLines.push(url);

  pushSection("Global specs");
  for (const { url } of sections.globalSpecs) txtLines.push(url);

  pushSection("DB schema");
  for (const { url } of sections.dbSchema) txtLines.push(url);

  pushSection("Project status");
  for (const { url } of sections.projectStatus) txtLines.push(url);

  pushSection("Notes & archive");
  for (const { url } of sections.notes) txtLines.push(url);

  pushSection("Other");
  for (const { url } of sections.other) txtLines.push(url);

  pushSection("Indexes (generated)");
  for (const rel of generatedIndexPaths) {
    txtLines.push(rawUrl(rel));
  }

  const txtContent = `${txtLines.join("\n")}\n`;
  assertPlainRawSitemapShape("SITEMAP.txt", txtContent, MIN_SITEMAP_LINES);
  assertRawUrls(
    txtLines.filter((l) => !l.startsWith("#")),
    "SITEMAP.txt",
  );
  await writeVerifiedFile(
    path.join(repoRoot, "SITEMAP.txt"),
    txtContent,
    "SITEMAP.txt",
    MIN_SITEMAP_LINES,
  );

  // Agent-first canonical paths/API; `url` stays legacy raw for existing CI/readers.
  const ndjson = [];
  const indexedPaths = new Set();
  const pushPage = (kind, relPath, pageBranch = branch, title = relPath) => {
    const key = `${pageBranch}:${relPath}`;
    if (indexedPaths.has(key)) return;
    indexedPaths.add(key);
    ndjson.push(JSON.stringify({
      kind, title, repository: DOCS_REPOSITORY, path: relPath, branch: pageBranch,
      api_url: apiUrl(relPath, pageBranch),
      url: `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/${pageBranch}/${encodePathForRawUrl(relPath)}`,
      url_role: "legacy/transition",
    }));
  };
  for (const b of sections.branches) pushPage("branch", "START.md", b.name, b.name);
  for (const [kind, list] of Object.entries(sections)) {
    if (kind === "branches") continue;
    const legacyKind = { repos: "repo", globalSpecs: "global", dbSchema: "db", projectStatus: "status" }[kind] || kind;
    for (const { label } of list) pushPage(legacyKind, label);
  }
  for (const rel of generatedIndexPaths) pushPage("index", rel);
  for (const rel of uniqueFiles) pushPage("page", rel);

  const ndjsonContent = `${ndjson.join("\n")}\n`;
  assertPlainRawSitemapShape("SITEMAP.ndjson", ndjsonContent, MIN_SITEMAP_LINES);
  assertRawUrls(
    ndjson.map((line) => JSON.parse(line).url),
    "SITEMAP.ndjson",
  );
  await writeVerifiedFile(
    path.join(repoRoot, "SITEMAP.ndjson"),
    ndjsonContent,
    "SITEMAP.ndjson",
    MIN_SITEMAP_LINES,
  );
}

await main();
