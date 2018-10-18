#ElasticSearch Bulk Upload Script

This script is still incomplete.

##es-bulk.sh

Upload cloud_controller_ng log to specified ES server.
Do not run this script now.

##test.sh
Extract a given archive_file from PCF, currently only support cloud_controller_ng and gorouter.
The target directory is /tmp, make sure you have enough free disk space.

Usage:

test.sh <path_to_your_archive_file> cloud_controller_ng|gorouter

Example:

/test.sh /Users/Documents/cloud_controller-1539b798d482.zip cloud_controller_ng

After execution you should see a file structure like below:

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
