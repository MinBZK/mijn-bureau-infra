import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: "Open Source",
    Svg: require("@site/static/img/code-bracket-square.svg").default,
    description: (
      <>
        MijnBureau is a fully open-source digital workplace suite built for
        transparency and community collaboration.
      </>
    ),
  },
  {
    title: "Cloud Native",
    Svg: require("@site/static/img/cloud.svg").default,
    description: (
      <>
        Built for Kubernetes with modern cloud-native principles, ensuring
        scalability and reliability.
      </>
    ),
  },
  {
    title: "Government Ready",
    Svg: require("@site/static/img/shield-check.svg").default,
    description: (
      <>
        Designed to meet government requirements with security, compliance, and
        data sovereignty in mind.
      </>
    ),
  },
];

function Feature({ title, Svg, description }: FeatureItem) {
  return (
    <div className={clsx("col col--4")}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
