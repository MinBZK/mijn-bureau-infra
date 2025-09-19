# Logs

All containers in our infrastructure log useful information to STDOUT, making it easy to collect logs directly from container logs. There are many tools available for aggregating container logs; you can choose any log collector that fits your needs.

If you require additional logs from a container, feel free to submit a pull request. Tools like Filebeat can be used to extract specific log data as needed.

Our software is tested on [HavenPlus](https://havenplus.commonground.nl/docs/overview) compliant clusters, which you can use as a reference for your own kubernetes setup.
