# Usage

cepheid.sh  -p <path_to_archive> -h <es_host:port> -j <job_name>

Currently you can only use cloud_controller, gorouter, diego_brain as job_name.

## Prepare ES server

You can install a standalone ES stack deployment by yourself or simply use the bosh release from [here](https://github.com/making/elastic-stack-bosh-deployment)

In my case I mostly used the `Minimal deployment` manifest from the above repo and deployed with BOSH.

## Test log file

Check this [link](https://drive.google.com/file/d/14s8yqY2Vu9FQ8s0kb8lRuGIH1YqWAt5_/view?usp=sharing)

## cepheid.sh

Extract a given archive_file from PCF OPS manager and upload it to ES host.
The temp working directory (to decompress the archive files) is /tmp, make sure you have enough free disk space.

After execution, the data has been imported into ES host but not searchable in Kibana yet.
You need to create a index pattern so that you can search it (check this [link](https://www.elastic.co/guide/en/kibana/current/tutorial-define-index.html)), select \*timestamp as timestamp filter.
Then go to **Discover** in Kibana and make sure you have select the correct Index Pattern (dropbox in upper left corner) and correct time range (for the sample log file From: 2018-10-03 00:00:00.000 To: 2018-10-17 23:59:59.999).

## switch_timestamp.sh

A simple script to switch the epoch timestamp in cloud controller log file to human readable format, currently only support MacOS.
Need to add support for Ubuntu and probably also support milliseconds in epoch timestamp.

## ToDo

There a lot of things I want to do with this project in the future.

1) Make this script portable for any platform, probably meaning refactoring with Python.
2) Support any BOSH job log (currently only cloud_controller_ng).
3) Make a web application which accepts archive log file upload and do all other jobs in backend containers (probably on PKS).
4) Provide a company wide platform for troubleshooting logs so that CEs in different regions can easily share their investigation progress by posting ES search link in the case notes.

I really hope this project can save us lots of time when troubleshooting vast logs from PCF.
