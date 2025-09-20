---
sidebar_position: 3
---

# Mijn Bureau

MijnBureau integrates and configures upstream products into a unified suite, acting as the gatekeeper for security of those products. If a product does not meet security requirements, MijnBureau may replace it with a more secure alternative that fits project needs.

## Secure Configuration

MijnBureau aims for secure-by-default configurations. The MijnBureau setup is flexible, allowing service integrators to tailor security settings to their hosting environment and requirements.

## Software Bill of Materials (SBOM)

MijnBureau plans to collect and publish SBOMs for all integrated products. If an upstream product lacks an SBOM, MijnBureau will assist in its creation. This transparency enables service integrators to scan SBOMs and make informed security decisions.

## Supply Chain Attestation

Attestation verifies the authenticity of products. MijnBureau strives to include attestation data for all products, helping service integrators enforce supply chain policies. Where missing, MijnBureau will support upstream projects in adding attestation.

## CVE Scanning

MijnBureau intends to provide visibility into vulnerabilities (CVEs) affecting its products. Service integrators are responsible for assessing the impact and deciding on mitigation strategies. CVE scanning is on the backlog and will be implemented in the future.

## Operational Guidance

MijnBureau offers recommendations to service integrators for secure operation of MijnBureau. MijnBureau can also offer recommendations for companies the write tenders for MijnBureau.

## Current Security Practices

MijnBureau currently improves security by:

1. Assuming a DenyAll Kubernetes network policy.
2. Scanning configurations with OPA policies for best practices.
3. Allowing flexible configuration for maximum Kubernetes security.
4. Reviewing and enabling security options in product setups.
5. Provide documentation to guide service integrators in maximizing security.

## Planned Security Enhancements

MijnBureau is committed to continuously improving its security posture. Future initiatives include:

1. Building hardened container images for all integrated products.
2. Introducing a continuous CVE scanning pipeline to detect vulnerabilities early.
3. Implementing automated SBOM generation and publication for transparency.
4. Developing a notification system to alert service integrators about critical security updates and issues.
5. Update product versions when provided
