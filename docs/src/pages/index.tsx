import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import MijnBureauScreenshots from "@site/src/components/MijnBureauScreenshots";
import EUCollaboration from "@site/src/components/EUCollaboration";
import OpenSourceFoundation from "@site/src/components/OpenSourceFoundation";
import Heading from "@theme/Heading";

import styles from "./index.module.css";

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={styles.heroBanner}>
      <div className={clsx("container", styles.heroInner)}>
        <div className={styles.heroBadge}>
          Open source · Self-hosted · Government-ready
        </div>
        <Heading as="h1" className={styles.heroTitle}>
          {siteConfig.title}
        </Heading>
        <p className={styles.heroTagline}>{siteConfig.tagline}</p>
        <div className={styles.heroButtons}>
          <Link
            className={clsx("button button--lg", styles.btnPrimary)}
            to="/docs/intro"
          >
            Get Started ⚡
          </Link>
          <Link
            className={clsx("button button--lg", styles.btnOutline)}
            href="mailto:mijnbureau@rijksoverheid.nl"
          >
            Contact Us
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="The flexible and secure digital workplace suite"
    >
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <MijnBureauScreenshots />
        <EUCollaboration />
        <OpenSourceFoundation />
      </main>
    </Layout>
  );
}
