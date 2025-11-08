import type { ReactNode } from "react";
import clsx from "clsx";
import Heading from "@theme/Heading";
import styles from "./styles.module.css";
import Translate, { translate } from "@docusaurus/Translate";

type FeatureItem = {
  title: string;
  Svg: React.ComponentType<React.ComponentProps<"svg">>;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: translate({
      id: "homepage.features.autonomy.title",
      message: "Autonomy",
      description: "The title for the autonomy feature",
    }),
    Svg: require("@site/static/img/code-bracket-square.svg").default,
    description: (
      <Translate id="homepage.features.autonomy.description">
        Run everything on your own hardware and maintain full control over your
        critical data.
      </Translate>
    ),
  },
  {
    title: translate({
      id: "homepage.features.secure.title",
      message: "Secure",
      description: "The title for the secure feature",
    }),
    Svg: require("@site/static/img/cloud.svg").default,
    description: (
      <Translate id="homepage.features.secure.description">
        Built securely from the ground up.
      </Translate>
    ),
  },
  {
    title: translate({
      id: "homepage.features.governmentReady.title",
      message: "Government Ready",
      description: "The title for the government ready feature",
    }),
    Svg: require("@site/static/img/shield-check.svg").default,
    description: (
      <Translate id="homepage.features.governmentReady.description">
        Designed to meet government requirements.
      </Translate>
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
