#!/usr/bin/env node
/**
 * Generate the release pages from published GitHub releases.
 *
 * Every MijnBureau release publishes `containers.json` (image inventory with
 * digests, signature status, SBOM checksums and Trivy findings). This script
 * downloads that file for the latest releases and writes one Markdown page per
 * release plus an index into `docs/docs/releases/`, which is generated at build
 * time and not committed.
 *
 * The script never fails the build: when the GitHub API is unreachable, rate
 * limited, or no release has been published yet, it writes a fallback index
 * page that links to the release list on GitHub.
 *
 * Environment:
 *   RELEASES_REPO        repository to read (default MinBZK/mijn-bureau-infra)
 *   RELEASES_LIMIT       number of releases to render (default 10)
 *   RELEASES_OUTPUT_DIR  output directory (default docs/docs/releases)
 *   GITHUB_TOKEN/GH_TOKEN  optional token, raises the API rate limit
 *   SKIP_RELEASES_FETCH  set to 1 to leave the generated pages untouched
 */

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const docsRoot = resolve(here, "..");

const repo = process.env.RELEASES_REPO || "MinBZK/mijn-bureau-infra";
const limit = Number.parseInt(process.env.RELEASES_LIMIT || "10", 10);
const outputDir = resolve(
  docsRoot,
  process.env.RELEASES_OUTPUT_DIR || "docs/releases",
);
const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN || "";

const severityOrder = ["critical", "high", "medium", "low"];

function escapeCell(value) {
  return String(value ?? "")
    .replaceAll("|", "\\|")
    .replaceAll("\n", " ");
}

function shortDigest(digest) {
  if (!digest) return "-";
  const value = digest.replace(/^sha256:/, "");
  return `\`${value.slice(0, 12)}…\``;
}

function signatureLabel(signature = {}) {
  if (signature.status === "verified") {
    return signature.method === "keyless"
      ? "verified (keyless)"
      : "verified (key)";
  }
  if (signature.status === "unverifiable") return "signed (unverifiable)";
  return signature.status || "unknown";
}

function cveCell(cve = {}) {
  if (cve.status !== "scanned") return cve.status || "n/a";
  return severityOrder.map((severity) => cve[severity] ?? 0).join("/");
}

async function github(path) {
  const response = await fetch(`https://api.github.com/repos/${repo}${path}`, {
    headers: {
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
      "User-Agent": "mijn-bureau-infra-docs",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (!response.ok) {
    const body = (await response.text()).slice(0, 200);
    throw new Error(
      `${response.status} ${response.statusText} for ${path}: ${body}`,
    );
  }
  return response.json();
}

async function downloadAsset(asset) {
  const headers = { "User-Agent": "mijn-bureau-infra-docs" };
  let url = asset.browser_download_url;
  if (token) {
    url = asset.url;
    headers.Accept = "application/octet-stream";
    headers.Authorization = `Bearer ${token}`;
  }
  const response = await fetch(url, {
    headers,
    redirect: "follow",
  });
  if (!response.ok) {
    throw new Error(
      `asset ${asset.name}: ${response.status} ${response.statusText}`,
    );
  }
  return response.text();
}

async function releaseReport(release) {
  const asset = (release.assets || []).find(
    (candidate) => candidate.name === "containers.json",
  );
  if (!asset) return null;
  const text = await downloadAsset(asset);
  return JSON.parse(text);
}

function releasePage(release, report, position) {
  const tag = release.tag_name;
  const published = (release.published_at || "").slice(0, 10);
  const summary = report.summary || {};
  const vulnerabilities = summary.vulnerabilities || {};
  const sbomAsset = (release.assets || []).find(
    (asset) => asset.name === `sbom-${tag}.tar.gz`,
  );
  const tarballAsset = (release.assets || []).find(
    (asset) => asset.name === `helmfile-${tag}.tar.gz`,
  );

  const images = [...(report.images || [])].sort((a, b) =>
    (a.components?.[0] || a.image).localeCompare(b.components?.[0] || b.image),
  );

  const lines = [
    "---",
    `title: ${tag}`,
    `sidebar_label: ${tag}`,
    `sidebar_position: ${position}`,
    "---",
    "",
    `# MijnBureau ${tag}`,
    "",
    `Released ${published || "unknown date"} · [GitHub release](${release.html_url})`,
    "",
    "This page is generated from the signed `containers.json` published with the release.",
    "",
    "## Summary",
    "",
    "| Images | Signed | Unsigned | Untrusted key | Mutable tags | Critical | High | Medium | Low |",
    "|---|---|---|---|---|---|---|---|---|",
    `| ${summary.images ?? images.length} | ${summary.signed ?? 0} | ${summary.unsigned ?? 0} | ${
      summary.unverifiable ?? 0
    } | ${summary.mutable_tags ?? 0} | ${vulnerabilities.critical ?? 0} | ${
      vulnerabilities.high ?? 0
    } | ${vulnerabilities.medium ?? 0} | ${vulnerabilities.low ?? 0} |`,
    "",
    `Environments: ${(report.environments || []).join(", ") || "n/a"} · Platform: \`${
      report.platform || "n/a"
    }\` · Generated ${
      report.generated_at || "unknown"
    }${report.source_commit ? ` from \`${report.source_commit.slice(0, 12)}\`` : ""}.`,
    "",
    "## Containers",
    "",
    "| Component | Image | Tag | Digest | Env | Signature | CVEs (C/H/M/L) |",
    "|---|---|---|---|---|---|---|",
  ];

  for (const image of images) {
    const component = (image.components || []).join(", ") || "-";
    const tagCell = image.mutable_tag
      ? `\`${image.tag || "-"}\` (mutable)`
      : `\`${image.tag || "-"}\``;
    lines.push(
      `| ${escapeCell(component)} | \`${escapeCell(image.image)}\` | ${tagCell} | ${shortDigest(
        image.digest || image.platform_digest,
      )} | ${escapeCell((image.environments || []).join(", "))} | ${escapeCell(
        signatureLabel(image.signature),
      )} | ${cveCell(image.cve)} |`,
    );
  }

  lines.push("", "## Download and verify", "");

  if (tarballAsset) {
    lines.push(
      `- Deployment tarball: [\`${tarballAsset.name}\`](${tarballAsset.browser_download_url})`,
    );
  }
  if (sbomAsset) {
    lines.push(
      `- SBOM bundle: [\`${sbomAsset.name}\`](${sbomAsset.browser_download_url})`,
    );
  }
  for (const name of [
    "containers.json",
    "containers.md",
    "cve.json",
    "SHA256SUMS",
  ]) {
    const asset = (release.assets || []).find(
      (candidate) => candidate.name === name,
    );
    if (asset) lines.push(`- [\`${name}\`](${asset.browser_download_url})`);
  }

  lines.push(
    "",
    "Verify the tarball and the report with the release key:",
    "",
    "```bash",
    `curl -LO ${release.html_url.replace("/tag/", "/download/")}/helmfile-${tag}.tar.gz`,
    `curl -LO ${release.html_url.replace("/tag/", "/download/")}/helmfile-${tag}.tar.gz.sigstore.json`,
    `curl -LO ${release.html_url.replace("/tag/", "/download/")}/SHA256SUMS.sigstore.json`,
    "curl -LO https://raw.githubusercontent.com/MinBZK/mijn-bureau-infra/main/cosign.pub",
    `cosign verify-blob --key cosign.pub --bundle helmfile-${tag}.tar.gz.sigstore.json helmfile-${tag}.tar.gz`,
    "```",
    "",
    "See [Supply chain](../security/supply-chain.md) for what the signature statuses mean.",
    "",
  );

  return lines.join("\n");
}

function indexPage(releases, error) {
  const lines = [
    "---",
    "title: Releases",
    "sidebar_position: 10",
    "---",
    "",
    "# Releases",
    "",
    "Every release publishes a container inventory with image digests, SBOMs, " +
      "cosign verification results and Trivy findings. Open a release to see the " +
      "exact images that release deploys.",
    "",
  ];

  if (error) {
    lines.push(
      `> The release list could not be fetched at build time (${error}). ` +
        `See the [releases on GitHub](https://github.com/${repo}/releases) instead.`,
      "",
      "Set `GITHUB_TOKEN` when building the site to avoid anonymous API rate limits.",
      "",
    );
    return lines.join("\n");
  }

  if (!releases.length) {
    lines.push(
      `No release with a security report has been published yet. See the [releases on GitHub](https://github.com/${repo}/releases).`,
      "",
    );
    return lines.join("\n");
  }

  lines.push(
    "| Release | Date | Images | Signed | Critical | High |",
    "|---|---|---|---|---|---|",
  );
  for (const { release, report } of releases) {
    const summary = report.summary || {};
    const vulnerabilities = summary.vulnerabilities || {};
    lines.push(
      `| [${release.tag_name}](./${release.tag_name}.md) | ${(release.published_at || "").slice(0, 10)} | ${
        summary.images ?? 0
      } | ${summary.signed ?? 0} | ${vulnerabilities.critical ?? 0} | ${vulnerabilities.high ?? 0} |`,
    );
  }
  lines.push("");
  return lines.join("\n");
}

async function previousIndex() {
  try {
    return await readFile(join(outputDir, "index.md"), "utf8");
  } catch {
    return null;
  }
}

async function main() {
  if (process.env.SKIP_RELEASES_FETCH === "1") {
    console.log("[releases] SKIP_RELEASES_FETCH=1, keeping existing pages");
    return;
  }

  await mkdir(outputDir, { recursive: true });
  await writeFile(
    join(outputDir, "_category_.json"),
    `${JSON.stringify(
      {
        label: "Releases",
        position: 90,
        link: { type: "doc", id: "releases/index" },
      },
      null,
      2,
    )}\n`,
  );

  let repositoryReleases = [];
  try {
    repositoryReleases = (await github(`/releases?per_page=${limit}`)).filter(
      (release) => !release.draft,
    );
  } catch (error) {
    console.warn(`[releases] ${error.message}`);
    const existing = await previousIndex();
    if (existing) {
      console.log("[releases] keeping previously generated pages");
      return;
    }
    await writeFile(join(outputDir, "index.md"), indexPage([], error.message));
    return;
  }

  const rendered = [];
  for (const release of repositoryReleases) {
    try {
      const report = await releaseReport(release);
      if (!report) continue;
      rendered.push({ release, report });
    } catch (error) {
      console.warn(`[releases] skipping ${release.tag_name}: ${error.message}`);
    }
  }

  for (const [offset, { release, report }] of rendered.entries()) {
    await writeFile(
      join(outputDir, `${release.tag_name}.md`),
      releasePage(release, report, offset + 2),
    );
  }

  await writeFile(join(outputDir, "index.md"), indexPage(rendered));
  console.log(
    `[releases] wrote ${rendered.length} release page(s) to ${outputDir}`,
  );
}

const invokedDirectly =
  process.argv[1] &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (invokedDirectly) {
  await main();
}

export { indexPage, main, releasePage };
