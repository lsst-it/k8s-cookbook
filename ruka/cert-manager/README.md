Cert-Manager installation with letsencrypt ClusterIssuer
========================================================

Before you begin, make sure to set the environmental variables and then run the script (settings the variables to a default value):

cd cert-manager/
unset HISTFILE
DNS_ZONE=your.domain.com
HOSTED_ZONE_ID=A123B456C789D
EMAIL=jdoe@acme.com
AWS_DEFAULT_REGION=us-east-1
AWS_ACCESS_KEY_ID=THISISNOTAREALKEY
AWS_SECRET_ACCESS_KEY=THISISNOTAREALSECRET
./cm-and_clusterissuer.sh
