oc new-project dev-tools  
oc policy add-role-to-group system:image-puller system:serviceaccounts -n dev-tools
oc apply -f ./tools-build.yaml

oc import-image postgresql-15-c9s:c9s --from=quay.io/sclorg/postgresql-15-c9s:c9s --confirm -n dev-tools

oc start-build dev-tools -n dev-tools -w -F    

