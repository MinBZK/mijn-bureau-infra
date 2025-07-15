#!/usr/bin/env python3

import argparse
import os
import subprocess
import tempfile

import yaml


# check if helmfile is already installed
def is_helmfile_installed():
    try:
        subprocess.run(["helmfile", "--version"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

# check if helmfile is already installed
def is_docker_installed():
    try:
        subprocess.run(["docker", "--version"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

# check if helmfile is already installed
def is_helm_installed():
    try:
        subprocess.run(["helm", "version"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def get_images(temp_dir):
    # read all kubernetes manifests and extract images
    manifests = []
    for root, dirs, files in os.walk(temp_dir):
      for file in files:
          if file.endswith(".yaml") or file.endswith(".yml"):
              with open(os.path.join(root, file), 'r') as f:
                  yaml_content = yaml.safe_load(f)
                  if 'kind' in yaml_content and yaml_content['kind'] in ['StatefulSet', 'Deployment', 'DaemonSet', 'Job', 'CronJob', 'Pod']:
                    manifests.append(yaml_content)
    images = set()
    for manifest in manifests:
      if manifest['kind'] in ['Pod']:
        if 'spec' in manifest:
          if 'containers' in manifest['spec']:
            for container in manifest['spec']['containers']:
                if 'image' in container:
                    images.add(container['image'])
          if 'initContainers' in manifest['spec']:
            if manifest['spec']['initContainers'] is None:
                continue
            for container in manifest['spec']['initContainers']:
                if 'image' in container:
                    images.add(container['image'])


      if manifest['kind'] in ['StatefulSet', 'Deployment', 'DaemonSet']:
        if 'spec' in manifest and 'template' in manifest['spec']:
                if 'containers' in manifest['spec']['template']['spec']:
                    for container in manifest['spec']['template']['spec']['containers']:
                        if 'image' in container:
                            images.add(container['image'])
                if 'initContainers' in manifest['spec']['template']['spec']:
                    if manifest['spec']['template']['spec']['initContainers'] == None:
                        continue
                    for container in manifest['spec']['template']['spec']['initContainers']:
                        if 'image' in container:
                            images.add(container['image'])

      if manifest['kind'] in ['Job']:
        if 'spec' in manifest:
            if 'template' in manifest['spec']:
                if 'spec' in manifest['spec']['template']:
                    if 'containers' in manifest['spec']['template']['spec']:
                        for container in manifest['spec']['template']['spec']['containers']:
                            if 'image' in container:
                                images.add(container['image'])

      if manifest['kind'] in ['CronJob']:
        if 'spec' in manifest and 'jobTemplate' in manifest['spec']:
            if 'spec' in manifest['spec']['jobTemplate']:
                if 'template' in manifest['spec']['jobTemplate']['spec']:
                    if 'containers' in manifest['spec']['jobTemplate']['spec']['template']['spec']:
                        for container in manifest['spec']['jobTemplate']['spec']['template']['spec']['containers']:
                            if 'image' in container:
                                images.add(container['image'])

    return images



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Prepare airgap environment by pulling images and charts from helmfile.")
    parser.add_argument("--environment", type=str, help="Path to the helmfile binary", default="demo")
    parser.add_argument("--output-dir", type=str, help="Directory to output the charts and images", default="output")
    parser.add_argument("--platform", type=str, help="Platform to use for the images", default="linux/amd64")
    args = parser.parse_args()

    # Check if helmfile is installed
    if not is_helmfile_installed():
        print("Helmfile is not installed. Please install Helmfile before running this script.")
        exit(1)

    # Check if helmfile is installed
    if not is_docker_installed():
        print("docker is not installed. Please install Docker before running this script.")
        exit(1)

    if not is_helm_installed():
        print("Helm is not installed. Please install Helm before running this script.")
        exit(1)


    # Define the path to the helmfile binary
    helmfile_path = os.path.join(os.getcwd(), "helmfile")

    # Check if the helmfile binary exists
    if not os.path.exists(helmfile_path):
        print(f"Helmfile binary not found at {helmfile_path}. Please ensure it is in the correct location.")
        exit(1)

    # create temporary directory for helmfile output
    temp_dir = tempfile.mkdtemp()

    print("Rendering helmfile...")
    try:
        subprocess.run(["helmfile", "-e", args.environment , "template", "--output-dir", temp_dir], check=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        print("Helmfile rendered successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error rendering helmfile: {e}")
        exit(1)

    images = get_images(temp_dir)

    print("Parsing manifests for images...")
    for image in images:
        # create image shortname
        image_shortname = image.split('/')[-1]+ '.tar'
        try:
            subprocess.run(["docker", "pull", image], check=True)
            subprocess.run(["docker", "save", "-o", args.output_dir+"/images/"+image_shortname, image], check=True)
            print(f"Pulled image: {image}")
        except subprocess.CalledProcessError as e:
            print(f"Error pulling image {image}: {e}")
            continue

    # get all helm charts.
    charts = set()
    try:
        subprocess.run(["helmfile", "-e", args.environment , "list"], check=True)
        print("Helm charts listed.")
    except subprocess.CalledProcessError as e:
        print(f"Error listing helmfile charts: {e}")
        exit(1)

    # parse the output of helmfile list
    helmfile_output = subprocess.run(["helmfile", "-e", args.environment, "list"], capture_output=True, text=True, check=True)
    lines = helmfile_output.stdout.strip().split('\n')[1:]  # Skip the header line
    for line in lines:
        parts = line.split()
        print(parts)
        if len(parts) > 6:
            chart_name = parts[5]
            chart_version = parts[6]
            charts.add((chart_name, chart_version))

    for chart_name, chart_version in charts:
        chart_dir = os.path.join(args.output_dir, chart_name)
        os.makedirs(chart_dir, exist_ok=True)
        try:
            subprocess.run(["helm", "pull", chart_name, "--version", chart_version], check=True)
            print(f"Pulled chart: {chart_name} version {chart_version}")
        except subprocess.CalledProcessError as e:
            print(f"Error pulling chart {chart_name}: {e}")
            continue
