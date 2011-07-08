$os_dep_file = $operatingsystem ? {
    ubuntu => 'ubuntu.conf',
    centos => 'centos.conf',
    default => undef,
    }

class generic_which_os {

    file { "/root/$os_dep_file":
        ## Section will stage file from /etc/puppet/files
        ## and assign permissions as described
        
        ## Source depends on version of operating system
#        source => $operatingsystem ? {  
#            ubuntu => "puppet://puppet/files/ubuntu.conf",
#            centos => "puppet://puppet/files/centos.conf",
#            default => undef,
#            }, # Close conditional statement           
        source => "puppet://puppet/files/$os_dep_file",
        owner => 'root',
        group => 'bitnami',
        mode => 660,
        ensure => present;  
        } # Close file "/root/platform.file"
        
#    file { "/root/hostname.file":
#        content => "Server's hostname is $hostname.$domain\n OS is $operatingsystem\n",
#        require => File [/root/$os_dep_file];
#        } # Close file "/root/hostname.file"

} # Close generic_which_os
