package main
import rego.v1

# Resources that should have image pull policy checks
resources_with_containers := {
    "Pod",
    "Deployment",
    "StatefulSet",
    "DaemonSet",
    "Job",
    "CronJob"
}

# Check if imagePullPolicy is set to "Always" for all containers
deny contains msg if {
    input.kind in resources_with_containers
    containers := get_containers(input)
    some container in containers
    container.imagePullPolicy != "Always"
    msg := sprintf("Container '%s' in %s/%s must have imagePullPolicy set to 'Always', got '%s'", [
        container.name,
        input.kind,
        input.metadata.name,
        container.imagePullPolicy
    ])
}

# Check if imagePullPolicy is missing (defaults to "IfNotPresent")
deny contains msg if {
    input.kind in resources_with_containers
    containers := get_containers(input)
    some container in containers
    not container.imagePullPolicy
    msg := sprintf("Container '%s' in %s/%s is missing imagePullPolicy (must be set to 'Always')", [
        container.name,
        input.kind,
        input.metadata.name
    ])
}

# Helper function to get containers from different resource types
get_containers(resource) := containers if {
    resource.kind == "Pod"
    containers := resource.spec.containers
}

get_containers(resource) := containers if {
    resource.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob"}
    containers := resource.spec.template.spec.containers
}

# Check init containers as well
deny contains msg if {
    input.kind in resources_with_containers
    init_containers := get_init_containers(input)
    some container in init_containers
    container.imagePullPolicy != "Always"
    msg := sprintf("Init container '%s' in %s/%s must have imagePullPolicy set to 'Always', got '%s'", [
        container.name,
        input.kind,
        input.metadata.name,
        container.imagePullPolicy
    ])
}

deny contains msg if {
    input.kind in resources_with_containers
    init_containers := get_init_containers(input)
    some container in init_containers
    not container.imagePullPolicy
    msg := sprintf("Init container '%s' in %s/%s is missing imagePullPolicy (must be set to 'Always')", [
        container.name,
        input.kind,
        input.metadata.name
    ])
}

# Helper function to get init containers
get_init_containers(resource) := init_containers if {
    resource.kind == "Pod"
    init_containers := resource.spec.initContainers
}

get_init_containers(resource) := init_containers if {
    resource.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob"}
    init_containers := resource.spec.template.spec.initContainers
}

# Default to empty array if no init containers
get_init_containers(resource) := [] if {
    resource.kind == "Pod"
    not resource.spec.initContainers
}

get_init_containers(resource) := [] if {
    resource.kind in {"Deployment", "StatefulSet", "DaemonSet", "Job", "CronJob"}
    not resource.spec.template.spec.initContainers
}
