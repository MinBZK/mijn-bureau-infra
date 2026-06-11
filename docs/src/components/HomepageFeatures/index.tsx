import type { ReactNode } from "react";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Autonomy",
    Svg: require("@site/static/img/code-bracket-square.svg").default,
    description: (
      <>
        Run everything on your own hardware and maintain full control over your
        critical data.
      </>
    ),
  },
  {
    title: "Secure",
    Svg: require("@site/static/img/cloud.svg").default,
    description: <>Built securely from the ground up.</>,
  },
  {
    title: "Government Ready",
    Svg: require("@site/static/img/shield-check.svg").default,
    description: <>Designed to meet government requirements.</>,
  },
];

function Feature({ title, Svg, description }: FeatureItem) {
  return (
    <div className={styles.card}>
      <div className={styles.iconWrap}>
        <Svg className={styles.featureSvg} role="img" aria-hidden="true" />
      </div>
      <div className={styles.cardBody}>
        <Heading as="h3" className={styles.cardTitle}>{title}</Heading>
        <p className={styles.cardDesc}>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className={styles.grid}>
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
