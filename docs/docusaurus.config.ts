import { themes as prismThemes } from "prism-react-renderer";
import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const config: Config = {
  title: "Mijn Bureau",
  tagline: "The autonomous digital workplace suite",
  favicon: "img/favicon.ico",

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url: "https://minbzk.github.io",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: "/mijn-bureau-infra/",

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "MinBZK", // Usually your GitHub org/user name.
  projectName: "mijn-bureau-infra", // Usually your repo name.

  trailingSlash: false,

  onBrokenLinks: "throw",
  onBrokenAnchors: "throw",
  onDuplicateRoutes: "throw",
  noIndex: false,

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
    localeConfigs: {
      en: {
        label: "English",
        direction: "ltr",
        htmlLang: "en-US",
        calendar: "gregory",
      },
    },
  },
  markdown: {
    mermaid: true,
    hooks: {
      onBrokenMarkdownLinks: "warn",
      onBrokenMarkdownImages: "warn",
    },
  },
  plugins: [
    [
      require.resolve("@easyops-cn/docusaurus-search-local"),
      {
        // Options for the search plugin
        hashed: true, // Recommended for production to avoid caching issues
        indexDocs: true, // Index documentation pages
        indexBlog: true, // Index blog pages
        indexPages: true, // Index static pages
        language: ["en"], // Language(s) for the search index
        highlightSearchTermsOnTargetPage: true, // Highlight search terms on the target page
        explicitSearchResultPath: true, // Show search results on a dedicated page
      },
    ],
    [
      require.resolve("@docusaurus/plugin-client-redirects"),
      {
        // Pages that moved in the 2026 information-architecture change. Keep
        // these so published URLs and external links keep working.
        redirects: [
          { from: "/docs/intro", to: "/docs/" },
          {
            from: "/docs/getting_started/overview",
            to: "/docs/getting_started/",
          },
          {
            from: "/docs/getting_started/setup",
            to: "/docs/getting_started/installation",
          },
          {
            from: "/docs/getting_started/install",
            to: "/docs/getting_started/installation",
          },
          { from: "/docs/backups", to: "/docs/operating/backup-restore" },
          {
            from: "/docs/datastores/backups",
            to: "/docs/operating/backup-restore",
          },
          {
            from: "/docs/administration",
            to: "/docs/operating/administration",
          },
          { from: "/docs/resources", to: "/docs/operating/configuration" },
          { from: "/docs/dns", to: "/docs/operating/dns" },
          { from: "/docs/gitops", to: "/docs/operating/gitops" },
          { from: "/docs/airgap", to: "/docs/operating/airgap" },
          {
            from: "/docs/external-secrets",
            to: "/docs/operating/secrets/external-secrets-operator",
          },
          { from: "/docs/datastores", to: "/docs/operating/datastores" },
          {
            from: "/docs/datastores/Intro",
            to: "/docs/operating/datastores",
          },
          {
            from: "/docs/datastores/objectstore",
            to: "/docs/operating/datastores/objectstore",
          },
          {
            from: "/docs/datastores/postgresql",
            to: "/docs/operating/datastores/postgresql",
          },
          {
            from: "/docs/datastores/redis",
            to: "/docs/operating/datastores/redis",
          },
          { from: "/docs/secrets", to: "/docs/operating/secrets" },
          {
            from: "/docs/secrets/derived",
            to: "/docs/operating/secrets/derived",
          },
          { from: "/docs/secrets/sops", to: "/docs/operating/secrets/sops" },
          {
            from: "/docs/secrets/external-secrets-operator",
            to: "/docs/operating/secrets/external-secrets-operator",
          },
          { from: "/docs/observability", to: "/docs/operating/observability" },
          {
            from: "/docs/observability/dashboards",
            to: "/docs/operating/observability/dashboards",
          },
          {
            from: "/docs/observability/logs",
            to: "/docs/operating/observability/logs",
          },
          {
            from: "/docs/observability/metrics",
            to: "/docs/operating/observability/metrics",
          },
          {
            from: "/docs/observability/traces",
            to: "/docs/operating/observability/traces",
          },
          {
            from: "/docs/development/deploy",
            to: "/docs/development/local-development",
          },
          { from: "/docs/development/intro", to: "/docs/development/" },
          { from: "/docs/security/intro", to: "/docs/security/" },
          // The Features section was merged into Using MijnBureau; the AI
          // configuration moved to Components.
          { from: "/docs/features", to: "/docs/user-guide" },
          { from: "/docs/features/documents", to: "/docs/user-guide/docs" },
          { from: "/docs/features/notes", to: "/docs/user-guide/docs" },
          { from: "/docs/features/filesharing", to: "/docs/user-guide/drive" },
          { from: "/docs/features/projects", to: "/docs/user-guide/projects" },
          { from: "/docs/features/calendar", to: "/docs/user-guide/calendars" },
          { from: "/docs/features/chat", to: "/docs/user-guide/element" },
          { from: "/docs/features/email", to: "/docs/user-guide/messages" },
          { from: "/docs/features/video", to: "/docs/user-guide/meet" },
          { from: "/docs/features/search", to: "/docs/user-guide/find" },
          {
            from: "/docs/features/ai-assistant",
            to: "/docs/user-guide/conversations",
          },
          {
            from: "/docs/features/ai-services",
            to: "/docs/components/ai-services",
          },
          {
            from: "/docs/features/transcription",
            to: "/docs/user-guide/dictaphone",
          },
          {
            from: "/docs/features/dashboard",
            to: "/docs/user-guide/bureaublad",
          },
          { from: "/docs/features/contacts", to: "/docs/user-guide/contacts" },
        ],
        createRedirects(existingPath: string) {
          // ADRs moved out of Development into Architecture.
          if (existingPath.startsWith("/docs/architecture/adr/")) {
            return [
              existingPath.replace(
                "/docs/architecture/adr/",
                "/docs/development/adr/",
              ),
            ];
          }
          // The Diagrams section was removed; the same content lives on the
          // component pages.
          const component = /^\/docs\/components\/(.+)$/.exec(existingPath);
          if (component) {
            return [`/docs/diagrams/${component[1]}`];
          }
          return undefined;
        },
      },
    ],
  ],

  themes: ["@docusaurus/theme-mermaid"],

  presets: [
    [
      "classic",
      {
        docs: {
          sidebarPath: "./sidebars.ts",
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/MinBZK/mijn-bureau-infra/tree/main/docs/",
        },
        blog: {
          showReadingTime: true,
          feedOptions: {
            type: ["rss", "atom"],
            xslt: true,
          },
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/MinBZK/mijn-bureau-infra/tree/main/docs/",
          // Useful options to enforce blogging best practices
          onInlineTags: "warn",
          onInlineAuthors: "warn",
          onUntruncatedBlogPosts: "warn",
        },
        theme: {
          customCss: "./src/css/custom.css",
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    // Replace with your project's social card
    navbar: {
      title: "Mijn Bureau",
      logo: {
        alt: "My Site Logo",
        src: "img/icon.svg",
      },
      items: [
        {
          type: "docSidebar",
          sidebarId: "documentationSidebar",
          position: "left",
          label: "Documentation",
        },
      ],
    },
    colorMode: {
      disableSwitch: true,
    },

    docs: {
      versionPersistence: "localStorage",
      sidebar: {
        hideable: true,
        autoCollapseCategories: true,
      },
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Community",
          items: [
            {
              label: "Matrix",
              href: "https://matrix.to/#/#mijnbureau:matrix.org",
            },
            {
              label: "Github",
              href: "https://github.com/MinBZK/mijn-bureau-infra",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} The State of the Netherlands and all contributors. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
