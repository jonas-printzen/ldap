# An easy to config OpenLDAP image

## Purpose
This project builds an image that provides a no-hassle incarnation of OpenLDAP image. By using this you are set for quick success with implementing LDAP - authentication and more. At least when i comes to the actual OpenLDAP setup. 

## Quick start
`docker run -d -e LDAP_DOMAIN=demo.net -e LDAP_PASSWORD=your-secret -p389:389 pzen/ldap`

Check that it works ...

`ldapsearch -x -D "cn=admin,dc=demo,dc=net" -W -b '' -s base '(objectclass=*)' namingContexts`

This should show that the **dn**, `namingContexts: dc=demo,dc=net` is in fact present.

## Configuration
To setup an LDAP - directory you need to **configure** the server, add an **admin-account** and a database for your **directory**.
Instead of  providing a leangthy instruction I just wrote a script that will setup the server properly. This setup is complete enough to get started. There are other steps to tweak for performance and/or security. But that can easily be added later.

## Environment variables

The auto-configuration use environment variables to pass configuration data in the simplest possible way.

| Variable  | Value  | Purpose |
|:---------:|:------:|:--------|
| **LDAP_DOMAIN** | **`demo.net`** | (**Required**) The dc-part of the base-dn (dc=demo,dc=net) is built on this|
| **LDAP_ORG**    | **`OptLtd`** | An optional organisation name  |
| **LDAP_ADMIN**  | **`Manager`** | An optional override for the admin-user |
| **LDAP_PASSWORD** | **`changeme`** | (**Required**) The password for the administrative user |
| **LDAP_USERS** | **`users`** | Optional override of the base for users |
| **LDAP_GROUPS** | **`group`** | Optional override of the base for groups |

These variables can be passed when starting the image the first time (assuming persistent volume) or everytime. If the start-script finds a legal configuration it won't change anything!

## Persistance
The image assumes to be started using an entrypoint-script, which will redirect all persistance-data to the **`/srv`** - folder of the container. You are expected to mount a persistent volume here.

> **Note**!
>
> The slapd - daemon will run as ldap:ldap (100:101)

Expecting an empty **`/srv`** folder at first, the entrypoint-script will create **`/srv/data`** to hold the **mdb**-database and **`/srv/slapd.d`** to hold configuration. If there already is a configuration it will be used without modification. To re-configure, remove the content of the folder mounted as volume on **`/srv`**, then restart with environment variables set as above..


## Using with LAM.

The following yaml-file is an example for running **LAM** and **pzen/ldap** in a docker-stack.
<sub>**Note**! _Can also be found on the github-repo_</sub>

    version: '3.8'
    services:
      ldap:
        image: pzen/ldap
        environment:
          LDAP_DOMAIN: demo.net
          LDAP_ADMIN: admin
          LDAP_PASSWD: changeme
          LDAP_ORG: DEMO
          LDAP_USERS: users
          LDAP_GROUPS: groups
        ports:
          - 389:389
        # volumes:
        #   - ldap_vol:/srv
  
      lam:
        image: ldapaccountmanager/lam:7.2
        environment:
          - LDAP_DOMAIN=demo.net
          - LDAP_BASE_DN=o=DEMO,dc=demo,dc=net
          - LDAP_USERS_DN=ou=users,o=DEMO,dc=demo,dc=net
          - LDAP_GROUPS_DN=ou=groups,o=DEMO,dc=demo,dc=net
          - LDAP_SERVER=ldap://ldap:389
          - LDAP_USER=cn=admin,o=DEMO,dc=demo,dc=net
        ports:
          - 8080:80

    # volumes:
    #   ldap_vol:
    #     ...

**Note**!

LAM needs some love in LAM Configuration to work properly. It seams that **`ou=users/groups`** is not included properly in LAM's environment based setup. Look at **Account types** under **Server-profiles**. **`o=DEMO`** is there on the **Users** and **Groups**, but not **`ou=users`** and **`ou=groups`**.

> **Users**:
>  LDAP suffix: _**ou=users**_,o=DEMO,dc=demo,dc=net

> **Groups** 
>  LDAP suffix: _**ou=groups**_,o=DEMO,dc=demo,dc=net

The **master** password can be changed under LAM configuration / general settings!
On new installs it's `lam`. ...  _**Remember to change it**_!

Chears!