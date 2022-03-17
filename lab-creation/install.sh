oc new-project lab-infra
oc new-project crw
oc project lab-infra

# Gitea Operator 用のカタログ
oc apply -f https://raw.githubusercontent.com/redhat-gpte-devopsautomation/gitea-operator/master/catalog_source.yaml

# Operator Install
oc apply -f lab-manifests/operator.yaml -n lab-infra
oc apply -f lab-manifests/crw-operator.yaml -n crw

# 各リソース作成 (CRWとSSOは競合するようなので分ける)
oc apply -f lab-manifests/sso.yaml -n lab-infra
oc apply -f lab-manifests/crw.yaml -n crw
oc apply -f lab-manifests/gitea.yaml -n lab-infra
oc apply -f lab-manifests/nexus-repo.yaml
oc expose service lab-nexusrepo

# モノリスアプリケーションは事前にビルド
oc new-build php:7.4-ubi8~https://gitlab.com/openshift-starter-kit/msa-app.git --context-dir='monolith/' --name='monolith-ui' -n lab-infra
oc new-build java:8~https://gitlab.com/openshift-starter-kit/msa-app.git --context-dir='monolith/' --name='monolith-service' -e MAVEN_MIRROR_URL=http://lab-nexusrepo-sonatype-nexus-service.lab-infra.svc/repository/maven-public/ -n lab-infra

# 各ユーザーからlab-infraのイメージをpullできるように
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user1-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user2-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user3-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user4-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user5-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user6-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user7-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user8-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user9-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user10-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user11-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user12-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user13-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user14-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user15-monolith -n lab-infra
oc policy add-role-to-group  system:image-puller system:serviceaccounts:user16-monolith -n lab-infra

oc get route keycloak -n lab-infra
