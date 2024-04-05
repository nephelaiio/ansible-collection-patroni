# Ansible Collection - nephelaiio.patroni

[![Build Status](https://github.com/nephelaiio/ansible-collection-patroni/actions/workflows/molecule.yml/badge.svg)](https://github.com/nephelaiio/ansible-collection-patroni/actions/wofklows/molecule.yml)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-nephelaiio.patroni-blue.svg)](https://galaxy.ansible.com/ui/repo/published/nephelaiio/patroni/)

An [ansible collection](https://galaxy.ansible.com/ui/repo/published/nephelaiio/patroni/) to install and manage [Patroni](https://patroni.readthedocs.io/en/latest/README.html) clusters

## ToDo
* Add Barman verification for master failover
* Refactor Consul playbooks into independent collection
* Refactor all collections with Consul deployments to pull from Consul collection
* Add slave cluster bootstrap option
* Add slave cluster test scenario
* Overwrite Patroni configuration
* Test dataplane integration
* Add PGCat deployment to install playbook
* Move API authentication to SSL certs

## Collection hostgroups

| Hostgroup                 |              Default | Description                                               |
|:--------------------------|---------------------:|:----------------------------------------------------------|
| patroni_cluster_group     |    'patroni_cluster' | Patroni DBMS hosts                                        |
| patroni_consul_group      |     'patroni_consul' | Patroni Consul Distibuted Configuration Store (DCS) hosts |
| patroni_barman_group      |     'patroni_barman' | Patroni Barman hosts                                      |
| patroni_haproxy_group     |    'patroni_haproxy' | Patroni HAProxy hosts                                      |
| patroni_update_skip_group | 'patroni_update_skip | Patroni update exclude hosts                              |

## Collection variables

The following is the list of parameters intended for end-user manipulation: 

Cluster wide parameters

| Parameter                            |                         Default | Description                                 | Required |
|:-------------------------------------|--------------------------------:|:--------------------------------------------|:---------|
| patroni_release_postgresql           |                            16.2 | Target PostgreSQL release                   | false    |
| patroni_release_patroni              |                           3.2.2 | Target Patroni release                      | false    |
| patroni_release_consul               |                        1.18.1-1 | Target Consul release                       | false    |
| patroni_cluster_name                 |                             n/a | Patroni cluster name                        | true     |
| patroni_cluster_databases            |                              [] | Patroni cluster databases                   | false    |
| patroni_cluster_roles                |                              [] | Patroni cluster roles                       | false    |
| patroni_cluster_api_username         |                         patroni | Patroni cluster restapi username            | false    |
| patroni_cluster_api_password         |                             n/a | Patroni cluster restapi password            | true     |
| patroni_cluster_postgres_password    |                             n/a | Patroni cluster replication password        | true     |
| patroni_cluster_replication_username |                      replicator | Patroni cluster replication username        | false    |
| patroni_cluster_replication_password |                             n/a | Patroni cluster replication password        | true     |
| patroni_cluster_roles                |                              [] | Patroni cluster roles                       | false    |
| patroni_cluster_databases            |                              [] | Patroni cluster databases                   | false    |
| patroni_cluster_maxlag_failover      |                         1048576 | Patroni cluster max async replica lag bytes | false    |
| patroni_cluster_maxlag_sync          |                              -1 | Patroni cluster max sync replica lag bytes  | false    |
| patroni_cluster_start_timeout        |                              60 | Patroni cluster max member start timeout    | false    |
| patroni_cluster_hba                  |                              [] | Patroni cluster hba objects                 | false    |
| patroni_watchdog_enable              |                            true | Enable watchdog module                      | false    |
| patroni_watchdog_mode                |                        required | Patroni watchdog mode                       | false    |
| patroni_config_hostnames             |                            true | Use hostnames for Patroni configuration     | false    |
| patroni_consul_datacenter            |                       'patroni' | Consul Datacenter name                      | false    |
| patroni_consul_backup_path           |               '/backups/consul' | Consul snapshot backup path                 | false    |
| patroni_consul_backup_bin            | '/usr/local/bin/consul-snapshot | Consul snapshot backup script location      | false    |
| patroni_consul_backup_retention      |                            1440 | Consul snapshot retention in minutes        | false    |
| patroni_consul_backup_minutes        |                          '\*/5' | Consul snapshot cronjob component           | false    |
| patroni_consul_backup_hours          |                            '\*' | Consul snapshot cronjob component           | false    |
| patroni_consul_backup_days           |                            '\*' | Consul snapshot cronjob component           | false    |
| patroni_haproxy_maxconn              |                            1000 | HAProxy max connections settings            | false    |
| patroni_barman_user                  |                          barman | Barman user                                 | false    |
| patroni_barman_group                 |                          barman | Barman group                                | false    |

where <node_object> follows the following json schema

``` json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "array",
  "items": [
    {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "address": {
          "type": "string"
        }
      },
      "required": [
        "name",
        "address"
      ]
    }
  ]
}

```

## Collection playbooks

* nephelaiio.patroni.install: Install and bootstrap cluster

## Testing

Please make sure your environment has [docker](https://www.docker.com) installed in order to run role validation tests.

Role is tested against the following distributions (docker images):

  * Ubuntu Jammy
  * Ubuntu Focal

You can test the collection directly from sources using command `make test`

## License

This project is licensed under the terms of the [MIT License](/LICENSE)

