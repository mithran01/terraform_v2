kubectl delete deployment openemr -n openemr

kubectl delete pvc openemr-documents -n openemr

kubectl get pv

kubectl delete pv <old-pv>

DROP DATABASE openemr;

CREATE DATABASE openemr;

GRANT ALL PRIVILEGES ON openemr.* TO 'openemr'@'%';

FLUSH PRIVILEGES;