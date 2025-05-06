Rancher Configuration
=====================

create ldap bind user
---------------------

_XXX broken_

as root on an ipa master...

```bash
cd files
# edit <password> in rancher-binddn.update to match 1pass `rancher ldap bind user`
ipa-ldap-updater rancher-binddn.update
```

Configure rancher free ipa integration
--------------------------------------

Logon to https://rancher.dev.lsst.org

Security -> Authentication

### Configure an FreeIPA server

Hostname or IP Address
`ipa1.ls.lsst.org`

Port
`636` TLS [X]

CA Certificate
`file:ipa-ca.pem`

Service Account Distinguished Name
_XXX binding seems to only work with Directory Manager.  It is not working with
read-only ldap only users or regular ipa user accounts._
XXX cn=rancher
cn=Directory Manager

Service Account Password
`<value from 1pass>`

User Search Base
`cn=accounts,dc=lsst,dc=cloud`

Group Search Base
`<blank>`

### Customize Schema

`<no changes from defaults>`

### Test and enable authentication

Your Username
`<your username>`

Your Password
`<your pass>`

`<submit>`

### Next dialog

Site Access:

`[x]  Allow members of Clusters, Projects, plus Authorized Users and Organizations`

Authorized Users and Organizations
`admins (group)`
