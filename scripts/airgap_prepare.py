#!/usr/bin/env python3

import argparse
import json
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

def get_images(dir):
    # read all kubernetes manifests and extract images
    manifests = []
    for root, dirs, files in os.walk(dir):
      for file in files:
          if file.endswith(".yaml") or file.endswith(".yml")  or file.endswith(".yaml.gotmpl")  or file.endswith(".yml.gotmpl"):
              with open(os.path.join(root, file), 'r') as f:
                  yaml_content = yaml.safe_load_all(f)
                  if yaml_content is None:
                      continue
                  for doc in yaml_content:
                      if doc is None:
                        continue
                      if 'kind' in doc and doc['kind'] in ['StatefulSet', 'Deployment', 'DaemonSet', 'Job', 'CronJob', 'Pod']:
                          manifests.append(doc)
    print(f"Found {len(manifests)} manifests")

    images = set()
    for manifest in manifests:
      print(f"Parsing manifest: {manifest['metadata']['name']} of kind {manifest['kind']}")
      if manifest['kind'] in ['Pod']:
        if 'spec' in manifest:
          if 'containers' in manifest['spec']:
            for container in manifest['spec']['containers']:
                if 'image' in container:
                    print(f"Found image: {container['image']}")
                    images.add(container['image'])
          if 'initContainers' in manifest['spec']:
            if manifest['spec']['initContainers'] is None:
                continue
            for container in manifest['spec']['initContainers']:
                if 'image' in container:
                    print(f"Found image: {container['image']}")
                    images.add(container['image'])


      if manifest['kind'] in ['StatefulSet', 'Deployment', 'DaemonSet']:
        if 'spec' in manifest and 'template' in manifest['spec']:
                if 'containers' in manifest['spec']['template']['spec']:
                    for container in manifest['spec']['template']['spec']['containers']:
                        if 'image' in container:
                            print(f"Found image: {container['image']}")
                            images.add(container['image'])
                if 'initContainers' in manifest['spec']['template']['spec']:
                    if manifest['spec']['template']['spec']['initContainers'] == None:
                        continue
                    for container in manifest['spec']['template']['spec']['initContainers']:
                        if 'image' in container:
                            print(f"Found image: {container['image']}")
                            images.add(container['image'])

      if manifest['kind'] in ['Job']:
        if 'spec' in manifest:
            if 'template' in manifest['spec']:
                if 'spec' in manifest['spec']['template']:
                    if 'containers' in manifest['spec']['template']['spec']:
                        for container in manifest['spec']['template']['spec']['containers']:
                            if 'image' in container:
                                print(f"Found image: {container['image']}")
                                images.add(container['image'])

      if manifest['kind'] in ['CronJob']:
        if 'spec' in manifest and 'jobTemplate' in manifest['spec']:
            if 'spec' in manifest['spec']['jobTemplate']:
                if 'template' in manifest['spec']['jobTemplate']['spec']:
                    if 'containers' in manifest['spec']['jobTemplate']['spec']['template']['spec']:
                        for container in manifest['spec']['jobTemplate']['spec']['template']['spec']['containers']:
                            if 'image' in container:
                                print(f"Found image: {container['image']}")
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
        print(f"Helmfile folder not found at {helmfile_path}. Please ensure it is in the correct location.")
        exit(1)

    # create temporary directory for helmfile output
    temp_dir = tempfile.mkdtemp()

    print(f"Rendering helmcharts with helmfile for environment {args.environment}, this may take a few minutes...")
    try:
        helmfile_result = subprocess.run(["helmfile", "-e", args.environment , "template", "--output-dir", temp_dir, "--skip-cleanup"], check=True, stderr=subprocess.PIPE, stdout=subprocess.DEVNULL)
        print("Helmfile rendered successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error rendering helmfile: {e}")
        exit(1)

    images = get_images(temp_dir)
    print(f"Found {len(images)} unique images in the manifests.")

    print("Parsing manifests for images...")
    for image in images:
        print(f"downloading Image: {image}")
        # create image shortname
        image_shortname = image.split('/')[-1]+ '.tar'
        try:
            subprocess.run(["docker", "pull", image], check=True,  stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
            os.makedirs(os.path.join(args.output_dir, "images"), exist_ok=True)
            subprocess.run(["docker", "save", "-o", args.output_dir+"/images/"+image_shortname, image], check=True,  stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

        except subprocess.CalledProcessError as e:
            print(f"Error pulling image {image}: {e}")
            continue

    # parse the output of helmfile for charts
    print("Parsing helmfile output for charts...")
    charts = set()

    # parse the helmfile output for string "Pulling"
    for line in helmfile_result.stderr.splitlines():
        line = line.decode('utf-8')
        if line.startswith("Pulling "):
            chart_list = line.split(" ")
            chart = chart_list[1]
            if chart.startswith("oci:") or chart.startswith("http:") or chart.startswith("https:"):
                charts.add(chart)
            else:
                charts.add("oci://"+chart) # for now assume oci:// for all chart

        if line.startswith("Downloading "):
            chart_list = line.split(" ")
            chart = chart_list[4]+"/"+chart_list[1]
            if chart.startswith("oci:") or chart.startswith("http:") or chart.startswith("https:"):
                charts.add(chart)
            else:
                charts.add("oci://"+chart) # for now assume oci:// for all charts

    print(f"Found {len(charts)} unique charts in the helmfile output.")
    print("Downloading charts...")
    for chart in charts:
        try:
            os.makedirs(os.path.join(args.output_dir, "charts"), exist_ok=True)
            subprocess.run(["helm", "pull", chart, "-d", os.path.join(args.output_dir, "charts")], check=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        except subprocess.CalledProcessError as e:
            print(f"Error pulling chart {chart}: {e}")
            continue
