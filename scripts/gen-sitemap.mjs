import fs from "node:fs/promises";
import path from "node:path";
import { execSync } from "node:child_process";

const IGNORED_DIR_NAMES = new Set([
  ".git",
  ".github",
  "node_modules",
  "dist",
  "build",
]);

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
  return `[${label}](${url})`;
}

async function writeDirIndex({ repoRoot, dir, dirInfo, baseUrl }) {
  const { files = [], subdirs = new Set() } = dirInfo;
  const indexPath = path.join(repoRoot, dir, "INDEX.md");

  const pages = files
    .filter((f) => path.posix.basename(f).toLowerCase() !== "index.md")
    .map((f) => ({
      label: path.posix.basename(f),
      url: baseUrl + encodePathForRawUrl(toPosixPath(f)),
    }))
    .sort((a, b) => a.label.localeCompare(b.label, "en", { sensitivity: "base" }));

  const childDirs = [...subdirs]
    .filter((subdir) => path.posix.dirname(subdir) === dir)
    .map((subdir) => ({
      label: `${path.posix.basename(subdir)}/`,
      url: baseUrl + encodePathForRawUrl(path.posix.join(subdir, "INDEX.md")),
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
  const baseUrl = `https://raw.githubusercontent.com/cotton-games/documentation-public/refs/heads/${branch}/`;
  const entrypointUrl = `${baseUrl}SITEMAP.md`;

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
    await writeDirIndex({ repoRoot, dir, dirInfo: info, baseUrl });
    generatedIndexPaths.push(toPosixPath(path.join(dir, "INDEX.md")));
  }

  const rootFiles = uniqueFiles.filter((p) => path.posix.dirname(p) === ".");
  const filesForSitemap = [...new Set([...rootFiles, ...generatedIndexPaths])].sort(
    compareByDirThenName,
  );

  const lines = [
    "<!-- Generated file — do not edit manually. Run npm run docs:sitemap -->",
    "",
    "# Cotton Documentation — Start Here (Single Entrypoint)",
    "",
    "This `SITEMAP.md` is the **single entrypoint** to the Cotton documentation.",
    "- Web AI agents must orchestrate and delegate edits to Codex; do not propose code patches in chat.",
    "- Verification-first: if unsure/missing info, don’t guess—organize verification (user or Codex audit).",
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
    "## Sitemap",
    ...filesForSitemap.map((p) => {
      const rel = toPosixPath(p);
      const url = baseUrl + encodePathForRawUrl(rel);
      return `- [${rel}](${url})`;
    }),
    "",
  ];

  await fs.writeFile(path.join(repoRoot, "SITEMAP.md"), lines.join("\n"), "utf8");
}

await main();
