import type { ReactNode } from "react";
import clsx from "clsx";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import HomepageFeatures from "@site/src/components/HomepageFeatures";
import Heading from "@theme/Heading";
import Translate, { translate } from "@docusaurus/Translate";

import styles from "./index.module.css";

function MijnBureauAdvantages(): ReactNode {
  return (
    <section className={clsx("padding-vert--xl")}>
      <div className="container">
        <div className="text--center margin-bottom--xl">
          <Heading as="h2">
            <Translate id="homepage.advantages.title">
              Why Choose MijnBureau?
            </Translate>
          </Heading>
          <p className="hero__subtitle">
            <Translate id="homepage.advantages.subtitle">
              Purpose-built for government, designed for autonomy
            </Translate>
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
                        <Translate id="homepage.advantages.government.title">
                          Government-First Design
                        </Translate>
                      </Heading>
                    </div>
                  </div>
                </div>
              </div>
              <div className="card__body">
                <ul>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.government.digitalAutonomy">
                        Digital Autonomy:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.government.digitalAutonomyDesc">
                      Complete control over your data and infrastructure
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.government.complianceReady">
                        Compliance Ready:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.government.complianceReadyDesc">
                      Built-in security for government standards
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.government.noVendorLock">
                        No Vendor Lock-in:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.government.noVendorLockDesc">
                      Open-source foundation ensures long-term independence
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.government.transparentOps">
                        Transparent Operations:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.government.transparentOpsDesc">
                      Fully auditable codebase and deployment processes
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.government.dutchEndorsed">
                        Dutch Government Endorsed:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.government.dutchEndorsedDesc">
                      Developed by and for public sector organizations
                    </Translate>
                  </li>
                </ul>
                <p>
                  <em>
                    <Translate id="homepage.advantages.government.description">
                      Built specifically for the public sector, MijnBureau
                      prioritizes government autonomy and transparency over
                      proprietary commercial control.
                    </Translate>
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
                        <Translate id="homepage.advantages.deployment.title">
                          Streamlined Deployment
                        </Translate>
                      </Heading>
                    </div>
                  </div>
                </div>
              </div>
              <div className="card__body">
                <ul>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.deployment.oneCommand">
                        One-Command Setup:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.deployment.oneCommandDesc">
                      Deploy complete digital workplace with single command
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.deployment.governmentOptimized">
                        Government-Optimized:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.deployment.governmentOptimizedDesc">
                      Pre-configured security
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.advantages.deployment.odcTested">
                        ODC-noord tested:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.advantages.deployment.odcTestedDesc">
                      Ready to deploy to an secure government owned ODC
                    </Translate>
                  </li>
                </ul>
                <p>
                  <em>
                    <Translate id="homepage.advantages.deployment.description">
                      Skip months of integration work - get a complete, secure
                      digital workplace running in minutes on your own
                      infrastructure.
                    </Translate>
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
                    🚀{" "}
                    <Translate id="homepage.advantages.cta.title">
                      Ready to Achieve Digital Sovereignty?
                    </Translate>
                  </Heading>
                  <p>
                    <Translate id="homepage.advantages.cta.description">
                      Join government organizations that have chosen
                      independence over vendor dependency. MijnBureau delivers
                      enterprise-grade collaboration tools with the
                      transparency, security, and autonomy that public sector
                      organizations require.
                    </Translate>
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
                      <Translate id="homepage.advantages.cta.exploreProduct">
                        Explore product
                      </Translate>
                    </Link>
                    <Link
                      className="button button--outline button--primary button--lg"
                      to="/demo/"
                    >
                      <Translate id="homepage.advantages.cta.seeGovernmentBenefits">
                        See Government Benefits
                      </Translate>
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
          <Heading as="h2">
            <Translate id="homepage.production.title">
              Proven technology
            </Translate>
          </Heading>
          <p className="hero__subtitle">
            <Translate id="homepage.production.subtitle">
              Built on proven, battle-tested open-source foundation
            </Translate>
          </p>
        </div>

        <div className="row margin-bottom--lg">
          <div className="col col--8 col--offset-2">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h3">
                  🔧{" "}
                  <Translate id="homepage.production.integration.title">
                    Integration Platform
                  </Translate>
                </Heading>
              </div>
              <div className="card__body">
                <p>
                  <Translate id="homepage.production.integration.description">
                    MijnBureau packages proven, widely adopted open-source
                    components into a government-ready digital workplace. It
                    emphasizes stability, compliance, and operational
                    transparency while enabling innovation through optional,
                    fast-evolving components.
                  </Translate>
                </p>
                <ul>
                  <li>
                    <strong>
                      <Translate id="homepage.production.integration.provenFoundation">
                        Proven foundation:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.production.integration.provenFoundationDesc">
                      Stable, community-backed tools for production.
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.production.integration.compliance">
                        Compliance & security:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.production.integration.complianceDesc">
                      Hardened defaults and auditable deployments.
                    </Translate>
                  </li>
                  <li>
                    <strong>
                      <Translate id="homepage.production.integration.extensible">
                        Extensible:
                      </Translate>
                    </strong>{" "}
                    <Translate id="homepage.production.integration.extensibleDesc">
                      Safely add or swap experimental components without risking
                      core services.
                    </Translate>
                  </li>
                </ul>
                <p className="margin-top--md">
                  <Translate id="homepage.production.integration.seeGettingStarted">
                    See the
                  </Translate>{" "}
                  <Link to="/docs/category/getting-started">
                    <Translate id="homepage.production.integration.gettingStartedLink">
                      getting started
                    </Translate>
                  </Link>{" "}
                  <Translate id="homepage.production.integration.guideText">
                    guide to learn how we balance reliability and innovation.
                  </Translate>
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="row">
          <div className="col col--12">
            <Heading as="h3" className="text--center margin-bottom--lg">
              <Translate id="homepage.production.maturity.title">
                Component Maturity Classification
              </Translate>
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
                            <Translate id="homepage.production.graduated.title">
                              Graduated (Production-Ready)
                            </Translate>
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>
                        <Translate id="homepage.production.graduated.subtitle">
                          Stable, widely adopted, production-ready
                        </Translate>
                      </small>
                    </p>
                    <ul>
                      <li>
                        <strong>
                          <Translate id="homepage.production.graduated.nextcloud">
                            Nextcloud:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.graduated.nextcloudDesc">
                          File sharing and collaboration
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.graduated.keycloak">
                            Keycloak:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.graduated.keycloakDesc">
                          Identity and access management
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.graduated.element">
                            Element:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.graduated.elementDesc">
                          Secure messaging and chat
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.graduated.collabora">
                            Collabora:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.graduated.collaboraDesc">
                          Document editing and collaboration
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.graduated.docs">
                            Docs:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.graduated.docsDesc">
                          Note editing and collaboration
                        </Translate>
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
                            <Translate id="homepage.production.incubating.title">
                              Incubating
                            </Translate>
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>
                        <Translate id="homepage.production.incubating.subtitle">
                          Used in production by smaller groups, growing
                          contributors
                        </Translate>
                      </small>
                    </p>
                    <ul>
                      <li>
                        <strong>
                          <Translate id="homepage.production.incubating.grist">
                            Grist:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.incubating.gristDesc">
                          Collaborative spreadsheets
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.incubating.ollama">
                            Ollama:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.incubating.ollamaDesc">
                          Local AI model
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.incubating.meet">
                            Meet:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.incubating.meetDesc">
                          Real-time video conferencing
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.incubating.drive">
                            Drive:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.incubating.driveDesc">
                          File sharing and collaboration
                        </Translate>
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
                            <Translate id="homepage.production.sandbox.title">
                              Sandbox
                            </Translate>
                          </strong>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="card__body">
                    <p>
                      <small>
                        <Translate id="homepage.production.sandbox.subtitle">
                          Experimental, limited adoption
                        </Translate>
                      </small>
                    </p>
                    <ul>
                      <li>
                        <strong>
                          <Translate id="homepage.production.sandbox.integration">
                            MijnBureau Integration:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.sandbox.integrationDesc">
                          Our deployment and configuration system
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.sandbox.bureaublad">
                            Bureaublad:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.sandbox.bureaaubladDesc">
                          Dashboard that integrates all components
                        </Translate>
                      </li>
                      <li>
                        <strong>
                          <Translate id="homepage.production.sandbox.conversations">
                            Conversations:
                          </Translate>
                        </strong>{" "}
                        <Translate id="homepage.production.sandbox.conversationsDesc">
                          AI Assistant
                        </Translate>
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
          <Heading as="h2">
            <Translate id="homepage.governance.title">
              Shared Governance & Community
            </Translate>
          </Heading>
          <p className="hero__subtitle">
            <Translate id="homepage.governance.subtitle">
              Shape the future of government digital workplaces together
            </Translate>
          </p>
        </div>

        <div className="row margin-bottom--lg">
          <div className="col col--8 col--offset-2">
            <div
              className="card shadow--md"
              style={{ background: "var(--ifm-color-info-lightest)" }}
            >
              <div className="card__header">
                <Heading as="h3">
                  🤝{" "}
                  <Translate id="homepage.governance.collaborative.title">
                    Collaborative Model
                  </Translate>
                </Heading>
              </div>
              <div className="card__body">
                <p>
                  <Translate id="homepage.governance.collaborative.description">
                    MijnBureau thrives on shared governance where participating
                    organizations actively shape the platform's evolution. This
                    isn't just about using the software – it's about
                    collectively building the digital workplace that best serves
                    government needs.
                  </Translate>
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
                  <Heading as="h4">
                    <Translate id="homepage.governance.componentSelection.title">
                      Component Selection
                    </Translate>
                  </Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>
                  <Translate id="homepage.governance.componentSelection.subtitle">
                    Democratic Decision-Making
                  </Translate>
                </h5>
                <ul>
                  <li>
                    <Translate id="homepage.governance.componentSelection.vote">
                      Vote on which components to include in MijnBureau
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.componentSelection.propose">
                      Propose new tools that meet government requirements
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.componentSelection.evaluate">
                      Evaluate emerging technologies collectively
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.componentSelection.setPriorities">
                      Set priorities based on real organizational needs
                    </Translate>
                  </li>
                </ul>
                <div className="alert alert--info">
                  <strong>
                    <Translate id="homepage.governance.componentSelection.alert">
                      Your voice matters:
                    </Translate>
                  </strong>{" "}
                  <Translate id="homepage.governance.componentSelection.alertText">
                    Each participating organization helps decide the platform's
                    direction.
                  </Translate>
                </div>
              </div>
            </div>
          </div>

          <div className="col col--4">
            <div className="card shadow--sm margin-bottom--md">
              <div className="card__header">
                <div className="text--center">
                  <span style={{ fontSize: "3rem" }}>🏗️</span>
                  <Heading as="h4">
                    <Translate id="homepage.governance.architecture.title">
                      Architecture Participation
                    </Translate>
                  </Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>
                  <Translate id="homepage.governance.architecture.subtitle">
                    Shape the Technical Design
                  </Translate>
                </h5>
                <ul>
                  <li>
                    <Translate id="homepage.governance.architecture.contribute">
                      Contribute to architectural decisions
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.architecture.share">
                      Share security and compliance requirements
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.architecture.influence">
                      Influence deployment patterns and configurations
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.architecture.review">
                      Review and validate technical roadmaps
                    </Translate>
                  </li>
                </ul>
                <div className="alert alert--success">
                  <strong>
                    <Translate id="homepage.governance.architecture.alert">
                      Expertise sharing:
                    </Translate>
                  </strong>{" "}
                  <Translate id="homepage.governance.architecture.alertText">
                    Combine knowledge from multiple government IT teams.
                  </Translate>
                </div>
              </div>
            </div>
          </div>

          <div className="col col--4">
            <div className="card shadow--sm margin-bottom--md">
              <div className="card__header">
                <div className="text--center">
                  <span style={{ fontSize: "3rem" }}>🚀</span>
                  <Heading as="h4">
                    <Translate id="homepage.governance.contribution.title">
                      Contribution & Innovation
                    </Translate>
                  </Heading>
                </div>
              </div>
              <div className="card__body">
                <h5>
                  <Translate id="homepage.governance.contribution.subtitle">
                    Drive Improvements Forward
                  </Translate>
                </h5>
                <ul>
                  <li>
                    <Translate id="homepage.governance.contribution.code">
                      Contribute code improvements and bug fixes
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.contribution.configurations">
                      Share custom configurations and best practices
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.contribution.fund">
                      Fund development of specific features
                    </Translate>
                  </li>
                  <li>
                    <Translate id="homepage.governance.contribution.test">
                      Test and validate new releases
                    </Translate>
                  </li>
                </ul>
                <div className="alert alert--warning">
                  <strong>
                    <Translate id="homepage.governance.contribution.alert">
                      Collective benefit:
                    </Translate>
                  </strong>{" "}
                  <Translate id="homepage.governance.contribution.alertText">
                    Improvements made by one organization benefit all
                    participants.
                  </Translate>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="row margin-top--lg">
          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h4">
                  📋{" "}
                  <Translate id="homepage.governance.howItWorks.title">
                    How Governance Works
                  </Translate>
                </Heading>
              </div>
              <div className="card__body">
                <div className="margin-bottom--md">
                  <h5>
                    🏛️{" "}
                    <Translate id="homepage.governance.productSteering.title">
                      Productstuurgroep
                    </Translate>
                  </h5>
                  <p>
                    <Translate id="homepage.governance.productSteering.description">
                      Representatives from participating organizations guide
                      strategic decisions.
                    </Translate>
                  </p>
                </div>
                <div className="margin-bottom--md">
                  <h5>
                    👥{" "}
                    <Translate id="homepage.governance.technicalSteering.title">
                      Technische stuurgroep
                    </Translate>
                  </h5>
                  <p>
                    <Translate id="homepage.governance.technicalSteering.description">
                      Focused teams tackle specific areas like security, IHH,
                      data privacy, or component evaluation.
                    </Translate>
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="col col--6">
            <div className="card shadow--md">
              <div className="card__header">
                <Heading as="h4">
                  🎯{" "}
                  <Translate id="homepage.governance.benefits.title">
                    Benefits of Participation
                  </Translate>
                </Heading>
              </div>
              <div className="card__body">
                <div className="margin-bottom--md">
                  <h5>
                    💡{" "}
                    <Translate id="homepage.governance.benefits.influence.title">
                      Influence Direction
                    </Translate>
                  </h5>
                  <p>
                    <Translate id="homepage.governance.benefits.influence.description">
                      Ensure MijnBureau evolves to meet your organization's
                      specific needs and requirements.
                    </Translate>
                  </p>
                </div>
                <div className="margin-bottom--md">
                  <h5>
                    🛡️{" "}
                    <Translate id="homepage.governance.benefits.expertise.title">
                      Shared Expertise
                    </Translate>
                  </h5>
                  <p>
                    <Translate id="homepage.governance.benefits.expertise.description">
                      Benefit from the collective knowledge of government IT
                      professionals across multiple organizations.
                    </Translate>
                  </p>
                </div>
                <div>
                  <h5>
                    💰{" "}
                    <Translate id="homepage.governance.benefits.cost.title">
                      Cost Efficiency
                    </Translate>
                  </h5>
                  <p>
                    <Translate id="homepage.governance.benefits.cost.description">
                      Share development costs while gaining access to
                      enterprise-grade solutions tailored for government.
                    </Translate>
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
                  <Heading as="h3">
                    🌟{" "}
                    <Translate id="homepage.governance.cta.title">
                      Ready to Join the Community?
                    </Translate>
                  </Heading>
                  <p>
                    <Translate id="homepage.governance.cta.description">
                      Become part of a growing network of government
                      organizations shaping the future of digital workplace
                      technology. Your participation strengthens the entire
                      ecosystem and ensures MijnBureau serves the real needs of
                      public sector organizations.
                    </Translate>
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
                      <Translate id="homepage.governance.cta.button">
                        Join the Governance Community
                      </Translate>
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
            <Translate id="homepage.hero.getStarted">Get Started</Translate> ⚡
          </Link>
          <Link className="button button--secondary button--lg" to="/demo/">
            <Translate id="homepage.hero.bookDemo">Book a Demo</Translate> 🚀
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
      title={
        translate({
          id: "homepage.page.title",
          message: "Home",
          description: "The title of the homepage",
        }) + ` - ${siteConfig.title}`
      }
      description={translate({
        id: "homepage.page.description",
        message: "The flexible and secure digital workplace suite",
        description: "The description of the homepage",
      })}
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
