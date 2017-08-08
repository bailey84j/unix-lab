$etcdconf = 

Configuration ExampleConfiguration{

    Import-DscResource -Module nx

    Node  "10.0.0.11"{    
    $n = 1
    foreach ($Package in @(
    'etcd',
    'kubernetes'
    )){
        nxPackage $Package {
        Name = $Package
        Ensure = "Present"
        PackageManager = "Yum"
        }
    }

        nxFile etcdconf {
 
            Ensure = "Present" 
            Type = "File"
            DestinationPath = "/etc/etcd/etcd.conf"   
            Contents= @"
#[member]
ETCD_NAME=CentOS_00$($n)
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_WAL_DIR=""
#ETCD_SNAPSHOT_COUNT="10000"
ETCD_HEARTBEAT_INTERVAL="100"
ETCD_ELECTION_TIMEOUT="2500"
ETCD_LISTEN_PEER_URLS="http://10.0.0.1$($n):2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.1$($n):2379,http://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.1$($n):2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="CentOS_001=http://10.0.0.11:2380,CentOS_002=http://10.0.0.12:2380,CentOS_003=http://10.0.0.13:2380,"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.1$($n):2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_STRICT_RECONFIG_CHECK="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"
#
#[proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[security]
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_CLIENT_CERT_AUTH="false"
#ETCD_TRUSTED_CA_FILE=""
#ETCD_AUTO_TLS="false"
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
#ETCD_PEER_CLIENT_CERT_AUTH="false"
#ETCD_PEER_TRUSTED_CA_FILE=""
#ETCD_PEER_AUTO_TLS="false"
#
#[logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
"@
        }
        nxService etcd
        {
            Name = "etcd"
            Controller = "systemd"
            Enabled = $True
            State = "Running"
        }
        <#nxscript etdccluster {
        SetScript ={}
        TestScript = {#!/bin/bash
        etcdhealth=$(etcdctl cluster-health)
        if [[ "$etcdhealth" == *"healthy result from http://10.0.0.13:2379"* ]];then exit 0; fi
        
        }
        GetScript ={}
        #
        }#>
    }
    Node  "10.0.0.12"{    
    $n = 2
    foreach ($Package in @(
    'etcd',
    'kubernetes'
    )){
        nxPackage $Package {
        Name = $Package
        Ensure = "Present"
        PackageManager = "Yum"
        }
    }
            nxFile etcdconf {
 
            Ensure = "Present" 
            Type = "File"
            DestinationPath = "/etc/etcd/etcd.conf"   
            Contents= @"
#[member]
ETCD_NAME=CentOS_00$($n)
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_WAL_DIR=""
#ETCD_SNAPSHOT_COUNT="10000"
ETCD_HEARTBEAT_INTERVAL="100"
ETCD_ELECTION_TIMEOUT="2500"
ETCD_LISTEN_PEER_URLS="http://10.0.0.1$($n):2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.1$($n):2379,http://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.1$($n):2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="CentOS_001=http://10.0.0.11:2380,CentOS_002=http://10.0.0.12:2380,CentOS_003=http://10.0.0.13:2380,"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.1$($n):2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_STRICT_RECONFIG_CHECK="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"
#
#[proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[security]
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_CLIENT_CERT_AUTH="false"
#ETCD_TRUSTED_CA_FILE=""
#ETCD_AUTO_TLS="false"
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
#ETCD_PEER_CLIENT_CERT_AUTH="false"
#ETCD_PEER_TRUSTED_CA_FILE=""
#ETCD_PEER_AUTO_TLS="false"
#
#[logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
"@
        }
        nxService etcd
        {
            Name = "etcd"
            Controller = "systemd"
            Enabled = $True
            State = "Running"
        }

    }
    Node  "10.0.0.13"{    
    $n = 3
    foreach ($Package in @(
    'etcd',
    'kubernetes'
    )){
        nxPackage $Package {
        Name = $Package
        Ensure = "Present"
        PackageManager = "Yum"
        }
    }
            nxFile etcdconf {
 
            Ensure = "Present" 
            Type = "File"
            DestinationPath = "/etc/etcd/etcd.conf"   
            Contents= @"
#[member]
ETCD_NAME=CentOS_00$($n)
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_WAL_DIR=""
#ETCD_SNAPSHOT_COUNT="10000"
ETCD_HEARTBEAT_INTERVAL="100"
ETCD_ELECTION_TIMEOUT="2500"
ETCD_LISTEN_PEER_URLS="http://10.0.0.1$($n):2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.1$($n):2379,http://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.1$($n):2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="CentOS_001=http://10.0.0.11:2380,CentOS_002=http://10.0.0.12:2380,CentOS_003=http://10.0.0.13:2380,"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.1$($n):2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_STRICT_RECONFIG_CHECK="false"
#ETCD_AUTO_COMPACTION_RETENTION="0"
#
#[proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[security]
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_CLIENT_CERT_AUTH="false"
#ETCD_TRUSTED_CA_FILE=""
#ETCD_AUTO_TLS="false"
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
#ETCD_PEER_CLIENT_CERT_AUTH="false"
#ETCD_PEER_TRUSTED_CA_FILE=""
#ETCD_PEER_AUTO_TLS="false"
#
#[logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
"@
        }
        nxService etcd
        {
            Name = "etcd"
            Controller = "systemd"
            Enabled = $True
            State = "Running"
        }

    }
       Node  "10.0.0.14"{    
    $n = 4
    foreach ($Package in @(
    'haproxy'
    )){
        nxPackage $Package {
        Name = $Package
        Ensure = "Present"
        PackageManager = "Yum"
        }
    }
     nxFile haproxy {
 
            Ensure = "Present" 
            Type = "File"
            DestinationPath = "/etc/haproxy/haproxy.cfg"   
            Contents= @"
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2     #Log configuration
 
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000                
    user        haproxy             #Haproxy running under user and group "haproxy"
    group       haproxy
    daemon
 
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
 
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
 
#---------------------------------------------------------------------
#HAProxy Monitoring Config
#---------------------------------------------------------------------
listen haproxy3-monitoring *:8080                #Haproxy Monitoring run on port 8080
    mode http
    option forwardfor
    option httpclose
    stats enable
    stats show-legends
    stats refresh 5s
    stats uri /stats                             #URL for HAProxy monitoring
    stats realm Haproxy\ Statistics
    stats auth howtoforge:howtoforge            #User and Password for login to the monitoring dashboard
    stats admin if TRUE
    default_backend app-main                    #This is optionally for monitoring backend
 
#---------------------------------------------------------------------
# FrontEnd Configuration
#---------------------------------------------------------------------
frontend main
    bind *:80
    option http-server-close
    option forwardfor
    default_backend app-main
 
#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm
#---------------------------------------------------------------------
backend app-main
    balance roundrobin                                     #Balance algorithm
    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server application is up and healty - 200 status code
    server CentOS_001 10.0.0.11:8080 check                 #CENTOS001
    server CentOS_002 10.0.0.12:8080 check                 #CENTOS002
    server CentOS_003 10.0.0.13:8080 check                 #CENTOS003
"@
        }
        

    }
}
ExampleConfiguration -OutputPath:"C:\temp" 

