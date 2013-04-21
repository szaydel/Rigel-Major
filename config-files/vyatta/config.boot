firewall {
    all-ping enable
    broadcast-ping disable
    group {
        network-group CLASS_A_PRIV {
            network 10.0.0.0/8
        }
        network-group CLASS_B_PRIV {
            network 172.16.0.0/12
        }
        network-group CLASS_C_PRIV {
            network 192.168.0.0/16
        }
        port-group UNSAFE_PORTS {
            port 1-1024
            port 2022
        }
    }
    ipv6-receive-redirects disable
    ipv6-src-route disable
    ip-src-route disable
    log-martians enable
    name INTERNET_TO_LOCAL {
        default-action drop
        description "FW Instance for inbound traffic on WAN interface"
        rule 1 {
            action accept
            disable
            state {
                established enable
                related enable
            }
        }
        rule 2 {
            action accept
            protocol icmp
        }
        rule 10 {
            action drop
            description "Drop any traffic deemed invalid"
            log enable
            protocol all
            state {
                invalid enable
            }
        }
        rule 11 {
            action drop
            destination {
                group {
                    port-group UNSAFE_PORTS
                }
            }
            protocol all
        }
        rule 12 {
            action drop
            protocol all
            source {
                group {
                    network-group CLASS_A_PRIV
                }
            }
        }
        rule 13 {
            action drop
            protocol all
            source {
                group {
                    network-group CLASS_B_PRIV
                }
            }
        }
        rule 14 {
            action drop
            protocol all
            source {
                group {
                    network-group CLASS_C_PRIV
                }
            }
        }
        rule 100 {
            action accept
            description "Allow Inbound Skype Connections"
            destination {
                port 5579
            }
            protocol tcp
        }
        rule 101 {
            action accept
            log enable
            p2p {
                bittorrent
            }
        }
    }
    name LOCAL_TO_INTERNET {
        default-action accept
        description "FW Instance for outbound traffic on WAN interface"
    }
    receive-redirects disable
    send-redirects enable
    source-validation disable
    state-policy {
        established {
            action accept
        }
        related {
            action accept
        }
    }
    syn-cookies enable
}
interfaces {
    ethernet eth0 {
        address dhcp
        description "WAN interface"
        duplex auto
        firewall {
            in {
                name INTERNET_TO_LOCAL
            }
            out {
                name LOCAL_TO_INTERNET
            }
        }
        hw-id 00:07:e9:a5:59:b2
        smp_affinity auto
        speed auto
    }
    ethernet eth1 {
        address 192.168.0.5/22
        address 10.10.100.5/22
        address 192.168.0.4/22
        address 192.168.0.1/22
        description "Inside NAT"
        duplex auto
        hw-id 00:07:e9:a5:59:b3
        smp_affinity auto
        speed auto
        vif 10 {
            address 192.168.10.1/22
        }
    }
    ethernet eth2 {
        address 10.10.99.1/16
        duplex auto
        hw-id 70:71:bc:18:2d:e9
        smp_affinity auto
        speed auto
    }
    loopback lo {
    }
}
nat {
    source {
        rule 10 {
            outbound-interface eth0
            source {
                address 192.168.0.0/22
            }
            translation {
                address masquerade
            }
        }
    }
}
service {
    dhcp-server {
        disabled false
        dynamic-dns-update {
            enable true
        }
        shared-network-name ETH1_POOL {
            authoritative enable
            description "DHCP pool with range from 192.168.1.100 to 192.168.1.200"
            subnet 192.168.0.0/22 {
                default-router 192.168.0.1
                dns-server 192.168.0.1
                domain-name internal.dom
                lease 86400
                ntp-server 192.168.0.1
                start 192.168.1.100 {
                    stop 192.168.1.200
                }
                static-mapping android-mxoom-lz {
                    ip-address 192.168.1.102
                    mac-address 98:4b:4a:b6:0a:78
                }
                static-mapping apple-ipad-sz {
                    ip-address 192.168.1.104
                    mac-address 64:20:0c:ea:97:d0
                }
                static-mapping laptop-mbp-lz {
                    ip-address 192.168.1.103
                    mac-address 68:a8:6d:2f:89:c2
                }
                static-mapping laptop-mbp-sz {
                    ip-address 192.168.1.105
                    mac-address b8:f6:b1:12:58:03
                }
            }
        }
    }
    dns {
        dynamic {
            interface eth0 {
                service dyndns {
                    host-name sepiidae.dyndns-at-home.com
                    login szaydel
                    password ix3JRYTb
                }
            }
        }
        forwarding {
            cache-size 5000
            listen-on eth1
            name-server 208.67.222.222
            name-server 208.67.220.220
        }
    }
    ssh {
        port 2022
    }
    webproxy {
        cache-size 102400
        default-port 3128
        listen-address 192.168.0.5 {
        }
        maximum-object-size 1048576
        mem-cache-size 1536
        url-filtering {
            squidguard {
                auto-update {
                    update-hour 2
                }
                block-category ads
                block-category gambling
                block-category phishing
                block-category marketingware
                block-category violence
                default-action allow
                redirect-url http://www.google.com
            }
        }
    }
}
system {
    config-management {
        commit-revisions 20
    }
    console {
        device ttyS0 {
            speed 9600
        }
    }
    domain-name internal.dom
    host-name minos-gw-01
    login {
        user vyatta {
            authentication {
                encrypted-password $1$71jPzW7v$CD1TOQoOlrRXbR3kkP2jz0
                plaintext-password ""
                public-keys vyatta {
                    key AAAAB3NzaC1yc2EAAAABIwAAAQEAvZFBaWT5yOTgLD+zu37fyVFPeE+Us6BmNT6zEHrJUPIyDNir2I9zaobqqedtNPORNCNpR9In/KsoPYWpuL0ph1ukOmBKKfuEP14W67c0uIbMTRjhZQHiT2tiDP1YaBkFUNdd+JSAMV30h4ZVrOaGg/fKIth6HZpP0QqOHRLi+dI/dFI6xwcZzcwPuZrIrHtopuhtoh9C3q/JudHO8HB4W4H/u4Hs8uxEjTp00u5d4uW7Io/ZDAavGGZ1bui2pPrp+bshR0cn+t7aFg73qmtdtqtH0nhBtUXEm6F/8HnZOUJJsOO4faTQbQ9hBjbwRzUD39M0sBYMp+zS343Z4x5qfw==
                    type ssh-rsa
                }
            }
            level admin
        }
    }
    name-server 208.67.222.222
    name-server 208.67.220.220
    ntp {
        server 0.north-america.pool.ntp.org {
        }
        server 1.north-america.pool.ntp.org {
        }
        server 2.north-america.pool.ntp.org {
        }
        server 3.north-america.pool.ntp.org {
        }
    }
    package {
        auto-sync 7
        repository community {
            components main
            distribution stable
            password ""
            url http://packages.vyatta.com/vyatta
            username ""
        }
        repository squeeze {
            components "main contrib non-free"
            distribution squeeze
            password ""
            url http://ftp.us.debian.org/debian
            username ""
        }
        repository vyatta4people {
            components main
            distribution experimental
            password ""
            url http://packages.vyatta4people.org/debian
            username ""
        }
    }
    static-host-mapping {
        host-name athens-wap.internal.dom {
            alias athens-wap
            inet 192.168.1.15
        }
        host-name printerbw01.internal.dom {
            alias printerbw01
            inet 192.168.1.12
        }
        host-name router-admin.internal.dom {
            alias router-admin
            inet 10.10.99.1
        }
        host-name router.internal.dom {
            alias router
            alias gw
            inet 192.168.0.1
        }
    }
    syslog {
        global {
            facility all {
                level notice
            }
            facility protocols {
                level debug
            }
        }
    }
    time-zone US/Pacific
}


/* Warning: Do not remove the following line. */
/* === vyatta-config-version: "system@6:conntrack-sync@1:nat@4:ipsec@4:dhcp-server@4:wanloadbalance@3:conntrack@1:cluster@1:config-management@1:quagga@2:webproxy@1:firewall@5:webgui@1:zone-policy@1:qos@1:vrrp@1:dhcp-relay@1" === */
/* Release version: VC6.5R1 */
