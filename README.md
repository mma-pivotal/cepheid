# ElasticSearch Bulk Upload Script

This project is in a very early stage.

## Prepare ES server

Go to your Kibana top page (http://<kibana_host>:5601/app/kibana#/home?\_g=()) then click **Dev Tools** on the left panel.
Enter the following content into console and click the green triangle button.
This should create a new index (myindex) and new doc_type (\_doc) for you.

```
PUT myindex
{
  "mappings": {
    "_doc": {
      "properties": {
        "timestamp": {
          "type":   "date",
          "format": "epoch_millis"
        }
      }
    }
  }
}
```

If you see error message saying index already exists, Click **Management** > **Index Management** and delete the existing index.
This is to save the disk usage of ES server.

## es-bulk.sh

Upload cloud_controller_ng log to specified ES server.
Put the sample log file in the same directory of this script and run the script.

Usage:

es-bulk.sh <your_es_host>

After execution, go to (http://<es_host>:5601/app/kibana#/management/elasticsearch/index_management/home?\_g=())
You should then see the **Docs Count** increased, meaning logs are being imported.

Next go to **Management** > **Index Patterns** > **Create Index Pattern** , create a index pattern so that you can search it, select timestamp as timestamp filter and click Create.
Then go to **Discover** and make sure you have select the correct Index Pattern (dropbox in upper left corner) and correct time range (From: 2018-10-17 00:00:00.000 To: 2018-10-17 23:59:59.999)

## test.sh
Extract a given archive_file from PCF, currently only support cloud_controller_ng and gorouter.
The target directory is /tmp, make sure you have enough free disk space.

Usage:

test.sh <path_to_your_archive_file> cloud_controller_ng|gorouter

Example:

/test.sh /Users/Documents/cloud_controller-1539b798d482.zip cloud_controller_ng

After execution you should see a file structure like below:

```
/tmp/cloud_controller-1539b798d482/
└── cf-421763892047a2991301.cloud_controller-20181017-020536-641577571
    ├── cloud_controller.6ee013f3-b9ec-4e09-9835-fdb20de2a169.2018-10-17-02-03-18
    │   ├── bosh-dns
    │   │   ├── bosh_dns.stderr.log
    │   │   ├── bosh_dns.stdout.log
    │   │   ├── bosh_dns_ctl.stderr.log
    │   │   ├── bosh_dns_ctl.stdout.log
    │   │   ├── bosh_dns_health.stderr.log
    │   │   ├── bosh_dns_health.stdout.log
    │   │   ├── bosh_dns_health_ctl.stderr.log
    │   │   ├── bosh_dns_health_ctl.stdout.log
    │   │   ├── bosh_dns_resolvconf.stderr.log
    │   │   ├── bosh_dns_resolvconf.stdout.log
    │   │   ├── bosh_dns_resolvconf_ctl.stderr.log
    │   │   ├── bosh_dns_resolvconf_ctl.stdout.log
    │   │   ├── post-start.stderr.log
    │   │   ├── post-start.stdout.log
    │   │   ├── pre-start.stderr.log
    │   │   └── pre-start.stdout.log
```
