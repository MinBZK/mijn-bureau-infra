import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import Heading from "@theme/Heading";
import Translate, { translate } from "@docusaurus/Translate";

function DemoHero(): ReactNode {
  return (
    <header className={clsx("hero hero--primary")}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          <Translate id="demo.hero.title">Experience MijnBureau Live</Translate>
        </Heading>
        <p className="hero__subtitle">
          <Translate id="demo.hero.subtitle">
            See how our secure, autonomous digital workplace can transform your
            organization
          </Translate>
        </p>
        <div className={clsx("margin-top--lg")}>
          <Link
            className="button button--secondary button--lg margin-right--md"
            href="mailto:opensource@MinBZK.nl?subject=MijnBureau Demo&body=Hoi,%0D%0A%0D%0AGraag zou ik een demo willen voor mijn organizatie.%0D%0A%0D%0AWanneer hebben jullie tijd.%0D%0A%0D%0ABedankt!"
          >
            📧 <Translate id="demo.hero.bookDemo">Book a Demo</Translate>
          </Link>
          <Link
            className="button button--outline button--secondary button--lg"
            href="mailto:opensource@MinBZK.nl?subject=MijnBureau Demo omgeving&body=Hoi,%0D%0A%0D%0AGraag zou ik een demo omgeving willen voor mijn organisatie.%0D%0A%0D%0AKunnen we hier binnekort over praten.%0D%0A%0D%0ABedankt!"
          >
            📖{" "}
            <Translate id="demo.hero.requestDeployment">
              Request a dedicated deployment
            </Translate>
          </Link>
        </div>
      </div>
    </header>
  );
}

function DemoSection(): ReactNode {
  return (
    <section className={clsx("padding-vert--xl")}>
      <div className="container">
        <div className="row">
          <div className="col col--8 col--offset-2">
            <div className="text--center margin-bottom--lg">
              <Heading as="h2">
                <Translate id="demo.section.title">
                  Why Request a Demo?
                </Translate>
              </Heading>
              <p className="margin-bottom--lg">
                <Translate id="demo.section.subtitle">
                  See firsthand how MijnBureau can provide your organization
                  with a secure, sovereign digital workplace that meets
                  government requirements.
                </Translate>
              </p>
            </div>

            <div className="row margin-bottom--xl">
              <div className="col col--6">
                <div className="card">
                  <div className="card__header">
                    <h3>
                      🔒{" "}
                      <Translate id="demo.security.title">
                        Security First
                      </Translate>
                    </h3>
                  </div>
                  <div className="card__body">
                    <p>
                      <Translate id="demo.security.description">
                        Experience our secure architecture and see how
                        MijnBureau protects your sensitive data with
                        enterprise-grade security.
                      </Translate>
                    </p>
                  </div>
                </div>
              </div>
              <div className="col col--6">
                <div className="card">
                  <div className="card__header">
                    <h3>
                      🏛️{" "}
                      <Translate id="demo.government.title">
                        Government Ready
                      </Translate>
                    </h3>
                  </div>
                  <div className="card__body">
                    <p>
                      <Translate id="demo.government.description">
                        Discover how our platform meets governmental
                        requirements and supports digital autonomie for public
                        sector organizations.
                      </Translate>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div className="row margin-bottom--xl">
              <div className="col col--6">
                <div className="card">
                  <div className="card__header">
                    <h3>
                      ⚙️{" "}
                      <Translate id="demo.autonomy.title">
                        Full Autonomy
                      </Translate>
                    </h3>
                  </div>
                  <div className="card__body">
                    <p>
                      <Translate id="demo.autonomy.description">
                        See how you can run everything on your own
                        infrastructure while maintaining complete control over
                        your data.
                      </Translate>
                    </p>
                  </div>
                </div>
              </div>
              <div className="col col--6">
                <div className="card">
                  <div className="card__header">
                    <h3>
                      🔧{" "}
                      <Translate id="demo.integration.title">
                        Easy Integration
                      </Translate>
                    </h3>
                  </div>
                  <div className="card__body">
                    <p>
                      <Translate id="demo.integration.description">
                        Learn how MijnBureau integrates with your existing
                        systems and workflows without disruption.
                      </Translate>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div className="text--center">
              <div className="margin-bottom--md">
                <Heading as="h3">
                  <Translate id="demo.getStarted.title">
                    Ready to Get Started?
                  </Translate>
                </Heading>
                <p>
                  <Translate id="demo.getStarted.description">
                    Contact our team to schedule a personalized demonstration of
                    MijnBureau. We'll show you how our platform can meet your
                    organization's specific needs.
                  </Translate>
                </p>
              </div>

              <div className="margin-bottom--lg">
                <Link
                  className="button button--primary button--lg"
                  href="mailto:opensource@MinBZK.nl?subject=MijnBureau Demo&body=Hoi,%0D%0A%0D%0AGraag zou ik een demo willen voor mijn organizatie.%0D%0A%0D%0AWanneer hebben jullie tijd.%0D%0A%0D%0ABedankt!"
                >
                  📧{" "}
                  <Translate id="demo.contact.button">
                    Contact Us: opensource@MinBZK.nl
                  </Translate>
                </Link>
              </div>

              <p>
                <small>
                  <Translate id="demo.contact.note">
                    We typically respond within 3 days and can accommodate demos
                    in Dutch or English.
                  </Translate>
                </small>
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Demo(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={
        translate({
          id: "demo.page.title",
          message: "Demo",
          description: "The title of the demo page",
        }) + ` - ${siteConfig.title}`
      }
      description={translate({
        id: "demo.page.description",
        message:
          "Book a demo of MijnBureau - the flexible and secure digital workplace suite for government organizations",
        description: "The description of the demo page",
      })}
    >
      <DemoHero />
      <main>
        <DemoSection />
      </main>
    </Layout>
  );
}
