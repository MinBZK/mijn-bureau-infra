import useBaseUrl from "@docusaurus/useBaseUrl";
import Heading from "@theme/Heading";

import styles from "./OpenSourceFoundation.module.css";

interface ComponentLogo {
  name: string;
  role: string;
  logo: string;
  ext: "svg" | "png" | "webp";
}

const COMPONENTS: ComponentLogo[] = [
  {
    name: "Keycloak",
    role: "Identity & Access",
    logo: "/img/logos/Keycloak.svg",
    ext: "svg",
  },
  { name: "Element", role: "Chat", logo: "/img/logos/element.svg", ext: "svg" },
  {
    name: "Nextcloud",
    role: "File Sharing",
    logo: "/img/logos/Nextcloud.svg",
    ext: "svg",
  },
  {
    name: "Collabora",
    role: "Office Suite",
    logo: "/img/logos/Collabora.svg",
    ext: "svg",
  },
  {
    name: "Grist",
    role: "Spreadsheets",
    logo: "/img/logos/Grist.png",
    ext: "png",
  },
  {
    name: "OpenProject",
    role: "Project Management",
    logo: "/img/logos/openprojects.svg",
    ext: "svg",
  },
  {
    name: "Ollama",
    role: "AI Language Models",
    logo: "/img/logos/ollama.webp",
    ext: "webp",
  },
  {
    name: "Docs",
    role: "Notes",
    logo: "/img/logos/LaSuite docs.svg",
    ext: "svg",
  },
  {
    name: "LiveKit",
    role: "Video Backend",
    logo: "/img/logos/LiveKit.svg",
    ext: "svg",
  },
  {
    name: "LaSuite Visio",
    role: "Meet",
    logo: "/img/logos/LaSuite Visio.svg",
    ext: "svg",
  },
  {
    name: "Conversations",
    role: "AI Assistant",
    logo: "/img/logos/LaSuite conversations.svg",
    ext: "svg",
  },
  {
    name: "Drive",
    role: "Document Drive",
    logo: "/img/logos/LaSuite fichiers.svg",
    ext: "svg",
  },
  {
    name: "PostgreSQL",
    role: "Database",
    logo: "/img/logos/postgresql.png",
    ext: "png",
  },
  { name: "Redis", role: "Cache", logo: "/img/logos/Redis.svg", ext: "svg" },
  {
    name: "Garage",
    role: "Object Storage",
    logo: "/img/logos/garage.png",
    ext: "png",
  },
  {
    name: "ClamAV",
    role: "Antivirus",
    logo: "/img/logos/ClamAV.svg",
    ext: "svg",
  },
];

function LogoTile({ name, role, logo }: ComponentLogo): React.JSX.Element {
  const src = useBaseUrl(logo);
  return (
    <div className={styles.tile}>
      <div className={styles.logoWrap}>
        <img
          src={src}
          alt={`${name} logo`}
          className={styles.logo}
          loading="lazy"
        />
      </div>
      <span className={styles.tileName}>{name}</span>
      <span className={styles.tileRole}>{role}</span>
    </div>
  );
}

export default function OpenSourceFoundation(): React.JSX.Element {
  return (
    <section className={styles.section}>
      <div className="container">
        <div className={styles.header}>
          <Heading as="h2" className={styles.title}>
            Built on Open Source
          </Heading>
          <p className={styles.subtitle}>
            MijnBureau would not exist without the incredible open-source
            community. Every component below is maintained by dedicated teams
            and contributors worldwide — we are proud to build on their work and
            give back to the ecosystem.
          </p>
        </div>

        <div className={styles.grid}>
          {COMPONENTS.map((c) => (
            <LogoTile key={c.name} {...c} />
          ))}
        </div>

        <p className={styles.footer}>
          … and many more libraries, tools, and contributors who make
          open-source software possible. Thank you. 🙏
        </p>
      </div>
    </section>
  );
}
