Cert-Manager installation with letsencrypt ClusterIssuer
========================================================

Before you begin, make sure to set the environmental variables and then run the script (settings the variables to a default value):

cd cert-manager/
DNS_ZONE = your.domain.com
HOSTED_ZONE_ID = A123B456C789D
EMAIL = jdoe@acme.com
REGION = us-somewhere-1
AWS_ACCESS_KEY = THISISNOTAREALKEY
AWS_SECRET_KEY = THISISNOTAREALSECRET|base64
./cm-and-clusterissuer.sh
