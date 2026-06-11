import Heading from "@theme/Heading";
import Link from "@docusaurus/Link";
import useBaseUrl from "@docusaurus/useBaseUrl";

import styles from "./EUCollaboration.module.css";

export default function EUCollaboration(): React.JSX.Element {
  const euLogo = useBaseUrl("/img/logos/europe_opensource.png");
  const laSuiteLogo = useBaseUrl("/img/logos/lasuite.svg");
  const openDeskLogo = useBaseUrl("/img/logos/OpenDesk_logo.svg");

  return (
    <section className={styles.section}>
      <div className="container">
        <div className={styles.header}>
          <img
            src={euLogo}
            alt="European open source collaboration logo"
            className={styles.euLogo}
            loading="lazy"
          />
          <Heading as="h2">European Collaboration on Digital Suites</Heading>
          <p className={styles.subtitle}>
            MijnBureau is part of a growing European movement for sovereign,
            open, and interoperable workplace platforms.
          </p>
        </div>

        <div className={styles.cards}>
          <article className={styles.card}>
            <div className={styles.cardTop}>
              <img
                src={laSuiteLogo}
                alt="La Suite logo"
                className={styles.partnerLogo}
                loading="lazy"
              />
              <Heading as="h3">France: La Suite</Heading>
            </div>
            <p>
              We closely collaborate with France around{" "}
              <strong>La Suite</strong>, exchanging practical lessons on
              open-source government workplace tooling and reusable building
              blocks.
            </p>
            <div className={styles.cardActions}>
              <Link
                className="button button--secondary button--sm"
                href="https://lasuite.numerique.gouv.fr/"
              >
                Visit La Suite
              </Link>
            </div>
          </article>

          <article className={styles.card}>
            <div className={styles.cardTop}>
              <img
                src={openDeskLogo}
                alt="openDesk logo"
                className={styles.partnerLogo}
                loading="lazy"
              />
              <Heading as="h3">Germany: openDesk</Heading>
            </div>
            <p>
              We also align with Germany's <strong>openDesk</strong> initiative
              to strengthen cross-border cooperation on secure,
              public-sector-first digital collaboration suites.
            </p>
            <div className={styles.cardActions}>
              <Link
                className="button button--secondary button--sm"
                href="https://opendesk.eu/"
              >
                Visit openDesk
              </Link>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
}
