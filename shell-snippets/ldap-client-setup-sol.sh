#!/usr/bin/bash

ldapclient -v manual \
-a attributeMap=passwd:gecos=cn \
-a objectClassMap=group:posixGroup=posixGroup \
-a objectClassMap=passwd:posixAccount=posixAccount \
-a objectClassMap=shadow:shadowAccount=shadowAccount \
-a domainName=homer.lab \
-a credentialLevel=proxy \
-a defaultSearchBase=dc=homer,dc=lab \
-a proxyDN=cn=proxy,ou=profile,dc=homer,dc=lab \
-a proxyPassword=proxy \
-a serviceSearchDescriptor=passwd:ou=users,dc=homer,dc=lab \
-a serviceSearchDescriptor=shadow:ou=users,dc=homer,dc=lab \
-a serviceSearchDescriptor=group:ou=groups,dc=homer,dc=lab \
-a serviceSearchDescriptor=netgroup:ou=netgroups,dc=homer,dc=lab \
-a defaultServerList=localhost:389 \
-a bindTimeLimit=20 \
-a authenticationMethod=simple \

# ldapclient manual -v \
# -a authenticationMethod=simple \
# -a defaultServerList=IP.AD.DR.ESS:389 \
# -a defaultSearchBase=dc=rcf,dc=unl,dc=edu \
# -a domainName=tusker.hcc.unl.edu \
# -a followReferrals=false \
# -a attributeMap=group:userpassword=userPassword \
# -a attributeMap=group:memberuid=memberUid \
# -a attributeMap=group:gidnumber=gidNumber \
# -a attributeMap=passwd:gecos=cn \
# -a attributeMap=passwd:gidnumber=gidNumber \
# -a attributeMap=passwd:uidnumber=uidNumber \
# -a attributeMap=passwd:homedirectory=homeDirectory \
# -a attributeMap=passwd:loginshell=loginShell \
# -a attributeMap=shadow:shadowflag=shadowFlag \
# -a attributeMap=shadow:userpassword=userPassword \
# -a objectClassMap=group:posixGroup=posixGroup \
# -a objectClassMap=passwd:posixAccount=posixAccount \
# -a objectClassMap=shadow:shadowAccount=shadowAccount \
# -a serviceSearchDescriptor=passwd:ou=People,dc=rcf,dc=unl,dc=edu?sub \
# -a serviceSearchDescriptor=group:ou=Groups,dc=rcf,dc=unl,dc=edu?sub
