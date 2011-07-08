#!/usr/bin/bash

ldapclient -v manual \
-a attributeMap=passwd:gecos=cn \
-a objectClassMap=group:posixGroup=posixGroup \
-a objectClassMap=passwd:posixAccount=posixAccount \
-a objectClassMap=shadow:shadowAccount=shadowAccount \
-a domainName=homer.lab \
-a credentialLevel=proxy \
-a defaultSearchBase=dc=alpha,dc=homer,dc=lab \
-a proxyDN=cn=proxyagent,ou=profile,dc=alpha,dc=homer,dc=lab \
-a serviceSearchDescriptor=passwd:ou=people,dc=alpha,dc=homer,dc=lab \
-a serviceSearchDescriptor=shadow:ou=people,dc=alpha,dc=homer,dc=lab \
-a serviceSearchDescriptor=group:ou=groups,dc=alpha,dc=homer,dc=lab \
-a serviceSearchDescriptor=netgroup:ou=netgroups,dc=alpha,dc=homer,dc=lab \
-a defaultServerList=10.10.100.11:389 \
-a bindTimeLimit=20 \
-a authenticationMethod=simple \
-a proxyPassword=password

