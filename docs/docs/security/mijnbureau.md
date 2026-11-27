---
sidebar_position: 3
---

# Mijn Bureau

MijnBureau integrates and configures upstream products into a unified suite, acting as the gatekeeper for security of those products. If a product does not meet security requirements, MijnBureau may replace it with a more secure alternative that fits project needs.

## Secure Configuration

MijnBureau aims for secure-by-default configurations. The MijnBureau setup is flexible, allowing service integrators to tailor security settings to their hosting environment and requirements.

## Software Bill of Materials (SBOM)

Every MijnBureau release publishes a CycloneDX and an SPDX SBOM for each container image it deploys. The SBOMs are generated from the exact image digest with Syft, so they describe the bits that run and not just a tag. Where an upstream product publishes its own SBOM attestation, that data can be compared against the generated SBOM.

## Supply Chain Attestation

Each release report records whether every container image carries a verifiable cosign signature and, if so, which keyless identity or release key signed it. The release tarball, the container inventory and the report checksums are signed with the MijnBureau release key, so service integrators can enforce supply chain policies on the artifacts they receive. Images that are unsigned are listed explicitly instead of being silently trusted.

## CVE Scanning

Each release report includes a Trivy scan of every CycloneDX SBOM, grouped per image and severity, with the fixed version where one exists. Service integrators remain responsible for assessing exploitability and deciding on mitigation strategies, and can rescan the published SBOMs at any time as new CVEs are disclosed.

See [Supply chain and release reports](supply-chain.md) for the artifacts, the signature statuses and the verification commands.

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
2. Scanning published release reports continuously for newly disclosed CVEs.
3. Moving image references from tags to digests, as described in ADR-MB-019.
4. Developing a notification system to alert service integrators about critical security updates and issues.
5. Update product versions when provided
