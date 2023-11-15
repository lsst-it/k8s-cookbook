Keycloak installation
====================

Before you begin, make sure the following env. variables are created:

Login Credentials
export KEYCLOAK_PASS=XXXXXXX

PG Credentials
export POSTGRES_PASS=YYYYYY

PG host
export POSTGRES_HOST=WWWWWWW

Keycloak ingress
export KEYCLOAK_INGRESS=ZZZZZ

Execute:
 ./keycloak.sh

And login as admin:$KEYCLOAK_PASS at https://KEYCLOAK_INGRESS
