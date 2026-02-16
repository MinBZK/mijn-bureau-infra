import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import Heading from "@theme/Heading";

import styles from "./index.module.css";

function MijnBureauAdvantages(): ReactNode {
  return (
    <section className={clsx("padding-vert--xl")}>
      <div className="container">
        <div className="text--center margin-bottom--xl">
          <Heading as="h2">Why Choose MijnBureau?</Heading>
          <p className="hero__subtitle">
            Purpose-built for government, designed for autonomy
          </p>
        </div>

        <div className="row">
          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <div className="avatar">
                  <div className="avatar__intro">
                    <div className="avatar__name">
                      <span style={{ fontSize: "2rem" }}>🏛️</span>
                      <Heading
                        as="h3"
                        style={{ marginLeft: "0.5rem", display: "inline" }}
                      >
                        Government-First Design
                      </Heading>
                    </div>
                  </div>
                </div>
              </div>
              <div className="card__body">
                <ul>
                  <li>
                    <strong>Digital Autonomy:</strong> Complete control over
                    your data and infrastructure
                  </li>
                  <li>
                    <strong>Compliance Ready:</strong> Built-in security for
                    government standards
                  </li>
                  <li>
                    <strong>No Vendor Lock-in:</strong> Open-source foundation
                    ensures long-term independence
                  </li>
                  <li>
                    <strong>Transparent Operations:</strong> Fully auditable
                    codebase and deployment processes
                  </li>
                  <li>
                    <strong>Dutch Government Endorsed:</strong> Developed by and
                    for public sector organizations
                  </li>
                </ul>
                <p>
                  <em>
                    Built specifically for the public sector, MijnBureau
                    prioritizes government autonomy and transparency over
                    proprietary commercial control.
                  </em>
                </p>
              </div>
            </div>
          </div>

          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <div className="avatar">
                  <div className="avatar__intro">
                    <div className="avatar__name">
                      <span style={{ fontSize: "2rem" }}>⚡</span>
                      <Heading
                        as="h3"
                        style={{ marginLeft: "0.5rem", display: "inline" }}
                      >
                        Streamlined Deployment
                      </Heading>
                    </div>
                  </div>
                </div>
              </div>
              <div className="card__body">
                <ul>
                  <li>
                    <strong>One-Command Setup:</strong> Deploy complete digital
                    workplace with single command
                  </li>
                  <li>
                    <strong>Government-Optimized:</strong> Pre-configured
                    security
                  </li>
                  <li>
                    <strong>ODC-noord tested:</strong> Ready to deploy to an
                    secure government owned ODC
                  </li>
                </ul>
                <p>
                  <em>
                    Skip months of integration work - get a complete, secure
                    digital workplace running in minutes on your own
                    infrastructure.
                  </em>
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="text--center margin-top--xl">
          <div className="row">
            <div className="col col--8 col--offset-2">
              <div
                className="card shadow--lg"
                style={{ background: "var(--ifm-color-primary-lightest)" }}
              >
                <div className="card__body">
                  <Heading as="h3">
                    🚀 Ready to Achieve Digital Sovereignty?
                  </Heading>
                  <p>
                    Join government organizations that have chosen independence
                    over vendor dependency. MijnBureau delivers enterprise-grade
                    collaboration tools with the transparency, security, and
                    autonomy that public sector organizations require.
                  </p>
                  <div
                    style={{
                      display: "flex",
                      gap: "1rem",
                      justifyContent: "center",
                      flexWrap: "wrap",
                    }}
                  >
                    <Link
                      className="button button--primary button--lg"
                      to="/docs/category/features"
                    >
                      Explore product
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function ProductionReadiness(): ReactNode {
  return (
    <section
      className={clsx("padding-vert--xl")}
      style={{ backgroundColor: "var(--ifm-color-secondary-lightest)" }}
    >
      <div className="container">
        <div className="text--center margin-bottom--xl">
          <Heading as="h2">Proven technology</Heading>
          <p className="hero__subtitle">
            Built on proven, battle-tested open-source foundation
          </p>
        </div>

        <div className="row margin-bottom--lg">
          <div className="col col--8 col--offset-2">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h3">🔧 Integration Platform</Heading>
              </div>
              <div className="card__body">
                <p>
                  MijnBureau packages proven, widely adopted open-source
                  components into a government-ready digital workplace. It
                  emphasizes stability, compliance, and operational transparency
                  while enabling innovation through optional, fast-evolving
                  components.
                </p>
                <ul>
                  <li>
                    <strong>Proven foundation:</strong> Stable, community-backed
                    tools for production.
                  </li>
                  <li>
                    <strong>Compliance & security:</strong> Hardened defaults
                    and auditable deployments.
                  </li>
                  <li>
                    <strong>Extensible:</strong> Safely add or swap experimental
                    components without risking core services.
                  </li>
                </ul>
                <p className="margin-top--md">
                  See the{" "}
                  <Link to="/docs/category/getting-started">
                    getting started
                  </Link>{" "}
                  guide to learn how we balance reliability and innovation.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col col--12">
            <Heading as="h3" className="text--center margin-bottom--lg">
              Component Maturity Classification
            </Heading>
            <div className="row">
              <div className="col col--6">
                <div className="card shadow--sm margin-bottom--md">
                  <div className="card__header">
                    <div className="avatar">
                      <div className="avatar__intro">
                        <div className="avatar__name">
                          <span style={{ fontSize: "1.5rem", color: "green" }}>
                            ✅
                          </span>
                          <strong
                            style={{ marginLeft: "0.5rem", color: "green" }}
                          >
                            Graduated (Production-Ready)
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>Stable, widely adopted, production-ready</small>
                    </p>
                    <ul>
                      <li>
                        <strong>Nextcloud:</strong> File sharing and
                        collaboration
                      </li>
                      <li>
                        <strong>Keycloak:</strong> Identity and access
                        management
                      </li>
                      <li>
                        <strong>Element:</strong> Secure messaging and chat
                      </li>
                      <li>
                        <strong>Collabora:</strong> Document editing and
                        collaboration
                      </li>
                      <li>
                        <strong>Docs:</strong> Note editing and collaboration
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              <div className="col col--6">
                <div className="card shadow--sm margin-bottom--md">
                  <div className="card__header">
                    <div className="avatar">
                      <div className="avatar__intro">
                        <div className="avatar__name">
                          <span style={{ fontSize: "1.5rem", color: "orange" }}>
                            🔄
                          </span>
                          <strong
                            style={{ marginLeft: "0.5rem", color: "orange" }}
                          >
                            Incubating
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>
                        Used in production by smaller groups, growing
                        contributors
                      </small>
                    </p>
                    <ul>
                      <li>
                        <strong>Grist:</strong> Collaborative spreadsheets
                      </li>
                      <li>
                        <strong>Ollama:</strong> Local AI model
                      </li>
                      <li>
                        <strong>Meet:</strong> Real-time video conferencing
                      </li>
                      <li>
                        <strong>Drive:</strong> File sharing and collaboration
                      </li>
                    </ul>
                  </div>
                </div>

                <div className="card shadow--sm">
                  <div className="card__header">
                    <div className="avatar">
                      <div className="avatar__intro">
                        <div className="avatar__name">
                          <span style={{ fontSize: "1.5rem", color: "blue" }}>
                            🧪
                          </span>
                          <strong
                            style={{ marginLeft: "0.5rem", color: "blue" }}
                          >
                            Sandbox
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>Experimental, limited adoption</small>
                    </p>
                    <ul>
                      <li>
                        <strong>MijnBureau Integration:</strong> Our deployment
                        and configuration system
                      </li>
                      <li>
                        <strong>Bureaublad:</strong> Dashboard that integrates
                        all components
                      </li>
                      <li>
                        <strong>Conversations:</strong> AI Assistant
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function SharedGovernance(): ReactNode {
  return (
    <section className={clsx("padding-vert--xl")}>
      <div className="container">
        <div className="text--center margin-bottom--xl">
          <Heading as="h2">Shared Governance & Community</Heading>
          <p className="hero__subtitle">
            Shape the future of government digital workplaces together
          </p>
        </div>

        <div className="row margin-bottom--lg">
          <div className="col col--8 col--offset-2">
            <div
              className="card shadow--md"
              style={{ background: "var(--ifm-color-info-lightest)" }}
            >
              <div className="card__header">
                <Heading as="h3">🤝 Collaborative Model</Heading>
              </div>
              <div className="card__body">
                <p>
                  MijnBureau thrives on shared governance where participating
                  organizations actively shape the platform's evolution. This
                  isn't just about using the software – it's about collectively
                  building the digital workplace that best serves government
                  needs.
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col col--4">
            <div className="card shadow--sm margin-bottom--md">
              <div className="card__header">
                <div className="text--center">
                  <span style={{ fontSize: "3rem" }}>🗳️</span>
                  <Heading as="h4">Component Selection</Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>Democratic Decision-Making</h5>
                <ul>
                  <li>Vote on which components to include in MijnBureau</li>
                  <li>Propose new tools that meet government requirements</li>
                  <li>Evaluate emerging technologies collectively</li>
                  <li>Set priorities based on real organizational needs</li>
                </ul>
                <div className="alert alert--info">
                  <strong>Your voice matters:</strong> Each participating
                  organization helps decide the platform's direction.
                </div>
              </div>
            </div>
          </div>

          <div className="col col--4">
            <div className="card shadow--sm margin-bottom--md">
              <div className="card__header">
                <div className="text--center">
                  <span style={{ fontSize: "3rem" }}>🏗️</span>
                  <Heading as="h4">Architecture Participation</Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>Shape the Technical Design</h5>
                <ul>
                  <li>Contribute to architectural decisions</li>
                  <li>Share security and compliance requirements</li>
                  <li>Influence deployment patterns and configurations</li>
                  <li>Review and validate technical roadmaps</li>
                </ul>
                <div className="alert alert--success">
                  <strong>Expertise sharing:</strong> Combine knowledge from
                  multiple government IT teams.
                </div>
              </div>
            </div>
          </div>

          <div className="col col--4">
            <div className="card shadow--sm margin-bottom--md">
              <div className="card__header">
                <div className="text--center">
                  <span style={{ fontSize: "3rem" }}>🚀</span>
                  <Heading as="h4">Contribution & Innovation</Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>Drive Improvements Forward</h5>
                <ul>
                  <li>Contribute code improvements and bug fixes</li>
                  <li>Share custom configurations and best practices</li>
                  <li>Fund development of specific features</li>
                  <li>Test and validate new releases</li>
                </ul>
                <div className="alert alert--warning">
                  <strong>Collective benefit:</strong> Improvements made by one
                  organization benefit all participants.
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="row margin-top--lg">
          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h4">📋 How Governance Works</Heading>
              </div>
              <div className="card__body">
                <div className="margin-bottom--md">
                  <h5>🏛️ Productstuurgroep</h5>
                  <p>
                    Representatives from participating organizations guide
                    strategic decisions.
                  </p>
                </div>
                <div className="margin-bottom--md">
                  <h5>👥 Technische stuurgroep</h5>
                  <p>
                    Focused teams tackle specific areas like security, IHH, data
                    privacy, or component evaluation.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h4">🎯 Benefits of Participation</Heading>
              </div>
              <div className="card__body">
                <div className="margin-bottom--md">
                  <h5>💡 Influence Direction</h5>
                  <p>
                    Ensure MijnBureau evolves to meet your organization's
                    specific needs and requirements.
                  </p>
                </div>
                <div className="margin-bottom--md">
                  <h5>🛡️ Shared Expertise</h5>
                  <p>
                    Benefit from the collective knowledge of government IT
                    professionals across multiple organizations.
                  </p>
                </div>
                <div>
                  <h5>💰 Cost Efficiency</h5>
                  <p>
                    Share development costs while gaining access to
                    enterprise-grade solutions tailored for government.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="text--center margin-top--xl">
          <div className="row">
            <div className="col col--10 col--offset-1">
              <div
                className="card shadow--lg"
                style={{ background: "var(--ifm-color-primary-lightest)" }}
              >
                <div className="card__body">
                  <Heading as="h3">🌟 Ready to Join the Community?</Heading>
                  <p>
                    Become part of a growing network of government organizations
                    shaping the future of digital workplace technology. Your
                    participation strengthens the entire ecosystem and ensures
                    MijnBureau serves the real needs of public sector
                    organizations.
                  </p>
                  <div
                    style={{
                      display: "flex",
                      gap: "1rem",
                      justifyContent: "center",
                      flexWrap: "wrap",
                      marginTop: "1.5rem",
                    }}
                  >
                    <Link
                      className="button button--primary button--lg"
                      href="mailto:opensource@MinBZK.nl?subject=MijnBureau Governance Participation&body=Hello,%0D%0A%0D%0AWe are interested in participating in MijnBureau's shared governance model.%0D%0A%0D%0AOrganization: %0D%0AInterest areas: %0D%0A- Component selection%0D%0A- Architecture participation%0D%0A- Technical contribution%0D%0A%0D%0APlease provide information about how to get involved.%0D%0A%0D%0AThank you!"
                    >
                      Join the Governance Community
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero hero--primary", styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div
          className={styles.buttons}
          style={{
            display: "flex",
            gap: "1rem",
            justifyContent: "center",
            alignItems: "center",
            flexWrap: "wrap",
          }}
        >
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            Get Started ⚡
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
        <MijnBureauAdvantages />
        <ProductionReadiness />
        <SharedGovernance />
      </main>
    </Layout>
  );
}
