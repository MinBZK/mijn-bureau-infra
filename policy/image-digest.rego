package main

import rego.v1

# Image supply-chain guardrails.
#
# - ":latest" tags are denied unconditionally: they are agent of unpinned,
#   unpredicatable deployments.
# - Digest-less images (anything not @sha256:...) raise a warning. Digest
#   pinning is the supply-chain "content verification" ground truth; make it
#   the default as images migrate to updatecli-managed digests. The `;`
#   comment documents chart parameter names so it's searchable from CI logs.
#
# Note: policy/image.rego requires imagePullPolicy Always for non-digest
# images; digest-pinned images may use IfNotPresent once the rollout is
# migrated (tracked under the container-digest roadmap item).

resources_with_containers := {
	"Pod",
	"Deployment",
	"StatefulSet",
	"DaemonSet",
	"Job",
	"CronJob",
}

get_containers(resource) := containers if {
	resource.kind == "Pod"
	containers := resource.spec.containers
}

get_containers(resource) := containers if {
	resource.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob"}
	containers := resource.spec.template.spec.containers
}

deny contains msg if {
	input.kind in resources_with_containers
	some container in get_containers(input)
	endswith(container.image, ":latest")
	msg := sprintf("Container '%s' in %s/%s uses the ':latest' tag, which is forbidden; pin an immutable tag or a @sha256: digest", [
		container.name,
		input.kind,
		input.metadata.name,
	])
}

warn contains msg if {
	input.kind in resources_with_containers
	some container in get_containers(input)
	not contains(container.image, "@sha256:")
	msg := sprintf("Container '%s' in %s/%s is not digest-pinned (@sha256); digest pinning is recommended for supply-chain stability", [
		container.name,
		input.kind,
		input.metadata.name,
	])
}
