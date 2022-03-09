# Starter Kit MSA体験 ハンズオン

Container Stater Kit で実施するハンズオンの手順を紹介します。  
当ハンズオンによって、簡単なモノリスアプリケーションのマイクロサービスへの分割を体験することができます。

## 1. 【管理者向け】 環境準備
---

## 2. OpenShiftへのログイン
---
### 2-1. OpenShiftへのWeb Console ログイン

OpenShiftのWeb Consoleにログインしましょう。URLとユーザー/パスワードは管理者から割り当てられたものを使用してください。

![webconsole-login-1.png](./webconsole-login-1.png)

![webconsole-login-2.png](./webconsole-login-2.png)

![webconsole-login-3.png](./webconsole-login-3.png)

Developer パースペクティブへようこそというダイアログが出ればログインは成功です。ツアーはスキップしてください。

---
### 2-2. CodeReadyWorkspaces ログイン

今回のハンズオンは、簡単なモノリスを分解してJavaを利用したマイクロサービスをビルド・デプロイという体験を含んでいます。お手元にJavaの環境がなかったり、コーディングの経験がなくてもスムーズに進められるようにCodeReadyWorspacesというWebIDEを利用します。

Web Consoleの右上のアプリケーションボタンを押して、CodeReadyWorspacesを選択してください。

![crw1.png](./crw1.png)

再度Web Consoleのログイン画面と同じ認証画面が表示されるので、同じ用にログイン方法を選んで、ユーザー/パスワードを入力してください。

下記の画面は Allow selected permissions のボタンを押してください。

![crw2.png](./crw2.png)

さきほどのボタン押下でアカウント情報がOpenShiftのoAuthから連携されました。Eメールアドレスが不足しているので、下記の画面が表示されます。
割り当てあられたユーザー名@example.com と入力してSubmitをおしてください。

例: user1@example.com

![crd3.png](./crd3.png)

ログインが成功するとSampleワークスペースが並んだダッシュボードが表示されます。CodeReadyWorkspacesは、開発を行いたい言語に必要なツールスタックをひとまとめにし、WebIDEとしてデプロイすることができます。

本ハンズオンでは、モノリスをマイクロサービスに分割する際に Quarkus というJavaフレームワークを利用します。少しスクロールして Quarkus をクリックしてください。

![crd4.png](./crd4.png)

ワークスペースのスタートに少し時間がかかります。

![crd5.png](./crd5.png)

起動が完了すると、このようにVSCodeライクなIDEが起動します。

![crd6.png](./crd6.png)

Terminalを起動するために画面右側のキューブのマークをクリックしてから >_ New Terminal をクリックしてください。

![crd7.png](./crd7.png)

このようにTerminalが起動します。ハンズオン前半はWebIDEとしての機能はつかわず、Terminalとしての利用が主となるので、境界を上方にドラッグして領域を広げてもよいでしょう。

![crd8.png](./crd8.png)

このTerminalはOpenShift上のLinuxコンテナにリモートシェルで接続しているようなものと考えてください。そのためコマンドはRed Hat Enterprise Linux基準になります。
起動しているShellはBashなのでコマンドのタブ補完が可能です。

---
### 2-3.OpenShiftへのCLI ログイン

OpenShift Web Consoleの画面の右上のユーザー名の部分をクリックして、ログインコマンドのコピーを選択してください。これまで通りログインメソッドは lab-login を選択してください。

![cli-login1.png](./cli-login1.png)

Display Token という文字が表示されるのでクリックしてください。

![cli-login2.png](./cli-login2.png)

Loginコマンドが表示されるので oc から始まる文字列をコピーしてください。

![cli-login3.png](./cli-login3.png)

CodeReadyWorkspacesのTerminalに戻って、コピーしてログインコマンドをはりつけてエンターキーを押してください。
このように表示されればログインは完了です。

出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ oc login --token=sha256~nTF1VCPiraXSCxXwmdAnZjYlf7gI2TAmH43JvU7RQXM --server=https://api.xxxx.ocp1.openshiftapps.com:6443
Logged into "https://api.xxxx.ocp1.openshiftapps.com:6443" as "user1" using the token provided.

You have one project on this server: "user1-codeready"

Using project "user1-codeready".
Welcome! See 'oc help' to get started.
```

ここまでで一旦皆さんの到着をまちます。

---
### Option 2-4 寄り道
ここで作業の早い方向けの寄り道をしてみましょう。
まず、CodeReadyWorkspacesのTerminalがコンテナ内にあることを確認するためにいくつかのコマンドを実行してみましょう。

実行コマンド
```
cat /etc/redhat-release
```
出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ cat /etc/redhat-release 
Red Hat Enterprise Linux release 8.5 (Ootpa)
```

一見するとRHEL8.5のようにみえます。通常のマシンと区別は付きません。

実行コマンド
```
ls /
```
出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ ls /
bin   dev  home  lib64       lost+found  mnt  proc      public-certs  run   srv  tmp  var
boot  etc  lib   lombok.jar  media       opt  projects  root          sbin  sys  usr  workspace_logs
```

Linuxを普段触っている方にとってはおおよそ見慣れたディレクトリが並んでいるように見えることでしょう。こちらでも通常のマシンとの区別はつきません。

実行コマンド
```
ps aux
```
出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
jboss          1  0.0  0.0  23056  1456 ?        Ss   Mar08   0:01 /usr/bin/coreutils --coreutils-prog-shebang=tail /usr/bin/tail -f /dev/null
jboss         32  0.0  0.0  11924  2780 pts/0    Ss   Mar08   0:00 /bin/bash -c cd /projects/quarkus-quickstarts; /bin/bash
jboss         38  0.0  0.1  39020 23408 pts/0    S    Mar08   0:00 /bin/bash
jboss         95  0.0  0.0  51868  3660 pts/0    R+   00:49   0:00 ps aux
```

通常のマシンでこのコマンドを実行すると大量のプロセスが見つかるはずですが、psコマンド自体をいれてもたったの４つしか表示されません。
特にPID 1のプロセスに注目してください。通常のマシンであればPID 1は init になるはずです。しかし、ここはコンテナの中なので tail プロセスになっているのが特徴的です。

次に oc コマンドで何が起きたかを見てみましょう。

実行コマンド
```
cat  cat ~/.kube/config 
```

結果
```
apiVersion: v1
clusters:
- cluster:
    server: https://api.xxxx.ocp1.openshiftapps.com:6443
  name: api-xxxx-ocp1-openshiftapps-com:6443
contexts:
- context:
    cluster: api-xxxx-ocp1-openshiftapps-com:6443
    namespace: user1-codeready
    user: user1/api-xxxx-ocp1-openshiftapps-com:6443
  name: user1-codeready/api-xxxx-ocp1-openshiftapps-com:6443/user1
current-context: user1-codeready/api-xxxx-ocp1-openshiftapps-com:6443/user1
kind: Config
preferences: {}
users:
- name: user1/api-xxxx-ocp1-openshiftapps-com:6443
  user:
    token: sha256~nTF1VCPiraXSCxXwmdAnZjYlf7gI2TAmH43JvU7RQXM
```

これはKubeconfigと呼ばれるファイルです。KuberenetesへAPIを発行する場合、予めこのファイルを自分で用意しておく必要があります。oc loginコマンドは、 oAuth を通して token を得た後にこのファイルを所定の位置に配置することで、以降の Kubernetes の API サーバーへの通信を可能にしています。

kubeconfigについての詳細は下記のURLを御覧ください。

https://kubernetes.io/ja/docs/concepts/configuration/organize-cluster-access-kubeconfig/

この Terminl からは Kubernetes のコントロールコマンドである kubectl も実行することができます。

コマンド
```
kubectl config view
```

先ほどと同じ内容が見えたはずです。

---
## ３. モノリスアプリケーションのデプロイ

OpenShift へのログインが完了したら、いよいよモノリスをデプロイしていきます。
モノリスデプロイでは OpenShift がKubernetes 互換であることを確認していくために、oc コマンドではなくkubectl （Kubernetesのコントロールコマンド）をつかってデプロイを行っていきます。

ここで利用するモノリスアプリケーションは、このような構造をしています。

![monolith1.png](./monolith1.png)

---
## 3.1 Manifestを用意する

Manifest とは Kubernetes に行いたい設定を記述したファイルのことをいいます。 YAML 形式と JSON 形式が使えますが、一般的に YAML を使うことが多いので、 Manifest の別の呼び方として YAML ファイルと呼んだりすることもあります。

Kubernetes アプリをデプロイする最も基本的な流れは以下のような順序になります。

1. アプリケーションを用意する
1. Docker ファイルを準備する
1. Docker Build を実行してアプリケーションイメージを作る
1. アプリケーションイメージを、Kubernetes の利用するレジストリに登録( Push )する
1. Manifest を用意する
1. Manifest をKubernetesに適用する
1. Kubernetes が Manifest に従ってアプリケーション Pod を起動する

モノリスアプリケーションのデプロイでは、１〜４は完了しており Kubernetes にデプロイするばかりという状況から実施していきます。

ここで利用する Manifest は以下のような内容になっています。

monolith.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monolith
  labels:
    app: monolith
    app.kubernetes.io/component: monolith
    app.kubernetes.io/instance: monolith
    app.kubernetes.io/name: monolith
    app.kubernetes.io/part-of: monolith
    app.openshift.io/runtime: spring-boot 
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monolith
  template:
    metadata:
      labels:
        app: monolith
    spec:
      containers:
      - name: monolith-service
        image: image-registry.openshift-image-registry.svc:5000/lab-infra/monolith-service:latest
        ports:
         - containerPort: 8081
           protocol: TCP
      - name: monolith-ui
        image: image-registry.openshift-image-registry.svc:5000/lab-infra/monolith-ui:latest
        ports:
         - containerPort: 8080
           protocol: TCP
  strategy:
    type: Recreate
---
apiVersion: v1
kind: Service
metadata:
  name: monolith
spec:
  selector:
    app: monolith
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

いくつかのポイントを確認していきます。

API バージョンと Kind
```
apiVersion: apps/v1
kind: Deployment
~
---
apiVersion: v1
kind: Service
```

この Manifest では Deployment　と Service を定義していきます。
Deployment はアプリケーションをデプロイするうえで最も基本的なリソースになります。
Service は Deployment から起動される Pod を Kubernetes ネットワークに接続するためのリソースです。











