package main
import rego.v1

# Define the required common Kubernetes labels
required_labels := {
	"app.kubernetes.io/name",
	"app.kubernetes.io/instance",
	"app.kubernetes.io/version",
	"app.kubernetes.io/component",
	"app.kubernetes.io/part-of",
	"app.kubernetes.io/managed-by"
}

# Define the minimum required labels (most critical ones)
minimum_required_labels := {
	"app.kubernetes.io/name",
	"app.kubernetes.io/instance",
	"app.kubernetes.io/version"
}

# Resources that should have labels
labeled_resources := {
	"Deployment",
	"Service",
	"ConfigMap",
	"Secret",
	"StatefulSet",
	"DaemonSet",
	"CronJob",
	"Pod",
	"Ingress",
	"NetworkPolicy",
	"PersistentVolumeClaim"
}

# Check if minimum required labels are present
deny contains msg if {
	input.kind in labeled_resources
	existing_labels := {key | input.metadata.labels[key]}
	missing_labels := minimum_required_labels - existing_labels
	count(missing_labels) > 0
	msg := sprintf("Resource %s/%s is missing minimum required labels: %v", [
		input.kind,
		input.metadata.name,
		missing_labels
	])
}

# Check if all recommended labels are present (warning level)
warn contains msg if {
	input.kind in labeled_resources
	input.metadata.labels
	existing_labels := {key | input.metadata.labels[key]}
	missing_labels := required_labels - existing_labels
	count(missing_labels) > 0
	msg := sprintf("Resource %s/%s is missing recommended labels: %v", [
		input.kind,
		input.metadata.name,
		missing_labels
	])
}

# Check if app.kubernetes.io/name follows naming conventions
deny contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/name"]
	name := input.metadata.labels["app.kubernetes.io/name"]
	not regex.match(`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`, name)
	msg := sprintf("Resource %s/%s has invalid app.kubernetes.io/name format: %s (must be lowercase alphanumeric with hyphens)", [
		input.kind,
		input.metadata.name,
		name
	])
}

# Check if app.kubernetes.io/version follows semantic versioning
deny contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/version"]
	version := input.metadata.labels["app.kubernetes.io/version"]
	not regex.match(`^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$`, version)
	msg := sprintf("Resource %s/%s has invalid app.kubernetes.io/version format: %s (should follow semantic versioning)", [
		input.kind,
		input.metadata.name,
		version
	])
}

# Check if app.kubernetes.io/component follows naming conventions
deny contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/component"]
	component := input.metadata.labels["app.kubernetes.io/component"]
	not regex.match(`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`, component)
	msg := sprintf("Resource %s/%s has invalid app.kubernetes.io/component format: %s (must be lowercase alphanumeric with hyphens)", [
		input.kind,
		input.metadata.name,
		component
	])
}

# Check if app.kubernetes.io/part-of follows naming conventions
deny contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/part-of"]
	part_of := input.metadata.labels["app.kubernetes.io/part-of"]
	not regex.match(`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`, part_of)
	msg := sprintf("Resource %s/%s has invalid app.kubernetes.io/part-of format: %s (must be lowercase alphanumeric with hyphens)", [
		input.kind,
		input.metadata.name,
		part_of
	])
}


# Check if labels are not empty
deny contains msg if {
	input.kind in labeled_resources
	some label_key, label_value in input.metadata.labels
	label_key in required_labels
	label_value == ""
	msg := sprintf("Resource %s/%s has empty value for label: %s", [
		input.kind,
		input.metadata.name,
		label_key
	])
}

# Check if labels are not too long (max 63 characters)
deny contains msg if {
	input.kind in labeled_resources
	some label_key, label_value in input.metadata.labels
	label_key in required_labels
	count(label_value) > 63
	msg := sprintf("Resource %s/%s has label value too long for %s: %d characters (max 63)", [
		input.kind,
		input.metadata.name,
		label_key,
		count(label_value)
	])
}

# Check for consistent app.kubernetes.io/instance across related resources
# This is a more advanced check that would require additional context
warn contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/instance"]
	instance := input.metadata.labels["app.kubernetes.io/instance"]
	count(instance) > 63
	msg := sprintf("Resource %s/%s has instance label value too long: %d characters (max 63)", [
		input.kind,
		input.metadata.name,
		count(instance)
	])
}

# Check for valid characters in instance name
deny contains msg if {
	input.kind in labeled_resources
	input.metadata.labels["app.kubernetes.io/instance"]
	instance := input.metadata.labels["app.kubernetes.io/instance"]
	not regex.match(`^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`, instance)
	msg := sprintf("Resource %s/%s has invalid app.kubernetes.io/instance format: %s (must be lowercase alphanumeric with hyphens)", [
		input.kind,
		input.metadata.name,
		instance
	])
}

# Additional check for Pod template specs in higher-level resources
deny contains msg if {
	input.kind in {"Deployment", "StatefulSet", "DaemonSet", "CronJob"}
	input.spec.template.metadata.labels
	existing_labels := {key | input.spec.template.metadata.labels[key]}
	missing_labels := minimum_required_labels - existing_labels
	count(missing_labels) > 0
	msg := sprintf("Resource %s/%s pod template is missing minimum required labels: %v", [
		input.kind,
		input.metadata.name,
		missing_labels
	])
}

# Check for label consistency between resource and pod template
deny contains msg if {
	input.kind in {"Deployment", "StatefulSet", "DaemonSet", "CronJob"}
	input.spec.template.metadata.labels
	input.metadata.labels
	some label_key in minimum_required_labels
	input.metadata.labels[label_key] != input.spec.template.metadata.labels[label_key]
	msg := sprintf("Resource %s/%s has inconsistent label %s between resource and pod template", [
		input.kind,
		input.metadata.name,
		label_key
	])
}
