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
- [ ] **2-1 Web Console へのログインを完了した**

すべてチェックがついたら次に進んでください

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
- [ ] **2-2 CodeReadyWorkspaces にログインして Terminal を起動した**

すべてチェックがついたら次に進んでください

---
### 2-3.OpenShiftへのCLI ログイン

OpenShift Web Consoleの画面の右上のユーザー名の部分をクリックして、ログインコマンドのコピーを選択してください。これまで通りログインメソッドは lab-login を選択してください。

![cli-login1.png](./cli-login1.png)

Display Token という文字が表示されるのでクリックしてください。

![cli-login2.png](./cli-login2.png)

Loginコマンドが表示されるので oc から始まる文字列をコピーしてください。

![cli-login3.png](./cli-login3.png)

CodeReadyWorkspacesのTerminalに戻って、コピーしてログインコマンドをはりつけてエンターキーを押してください。
このように表示されればログインは成功です。

出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ oc login --token=sha256~nTF1VCPiraXSCxXwmdAnZjYlf7gI2TAmH43JvU7RQXM --server=https://api.xxxx.ocp1.openshiftapps.com:6443
Logged into "https://api.xxxx.ocp1.openshiftapps.com:6443" as "user1" using the token provided.

You have one project on this server: "user1-codeready"

Using project "user1-codeready".
Welcome! See 'oc help' to get started.
```

### 2-3-1.環境変数保存

ユーザー名を後のタイミングでコマンド内で利用することがあるため、以下の
```
export USER_NAME=`oc whoami`
cat << EOF > ~/.bashrc
export USER_NAME=$USER_NAME
EOF
```

### 2-3-２.プロジェクト作成
後のためにプロジェクトを作成します。

```
oc new-project ${USER_NAME}-monolith
oc new-project ${USER_NAME}-msa
oc project ${USER_NAME}-monolith
```

ここまでで一旦皆さんの到着をまちます。

---

- [ ] **2-3 CLIでログインした**
- [ ] **2-3-1 環境変数を保存した**
- [ ] **2-3-2 プロジェクトを作成した**

すべてチェックがついたら次に進んでください

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

この Terminal からは Kubernetes のコントロールコマンドである kubectl も実行することができます。

コマンド
```
kubectl config view
```

先ほどと同じ内容が見えたはずです。

---

## ３. モノリスアプリケーションのデプロイ

OpenShift へのログインが完了したら、いよいよモノリスをデプロイしていきます。

サンプルとして利用するモノリスアプリケーションは、このような構造をしています。
Apache + PHP と Java VM の２プロセスを必要としています。

![monolith1.png](./monolith1.png)

呼び出しシーケンスはこのような流れで行われます。PHPがフロントエンドを担当し、Java(SpringBoot)がバックエンドを担当しています。

![monolith2.png](./monolith2.png)

### FAQ 1

モノリスをコンテナにする際にこういった質問がよくあります。

---

Q. 我々が利用しているアプリケーションはメインプロセス以外に、複数のプロセスをデーモンとして必要としています。１コンテナ１プロセスと聞いていますが、こういったアプリケーションはどうすればコンテナにいれられるのでしょうか？

A. 方法は２つあります。１つはメインとなるアプリケーションをフォワードプロセスとして起動しておき、その他のデーモンをバックグラウンドプロセスとして起動する方法です。ただし、これは以下のような理由であまりオススメしません。

1. コンテナはバックグラウンドプロセスを起動したままメインプロセスの再起動しようとしても、コンテナ自体が終了してしまうので全体まるごとでしか再起動できなくなる
1. メインアプリケーションもバックグラウンド化する方法があるが、ここまでやってしまうと仮想マシンと同じ使い方になってしまい、コンテナ化するメリットをすべて享受できなくなる
1. コンテナイメージは軽量化するためにsystemdを起動していないことが多いので、デーモンを管理する方法が手動になってしまう（systemdをもつコンテナイメージも存在する）

Kubernetes においてはサイドカーパターンを利用することが正解になるケースがあります。サイドカーとは1つのPodの中に複数コンテナを起動することです。Pod 内に起動した複数コンテナは以下のような特徴を持ちます。

1. Pod 内のコンテナは同じ Node で起動することが保証されている
1. 同一 Pod 内のコンテナはネットワークとマウントした外部ストレージを共有している（ファイルシステムは共有していない）

２番めの特徴によって、コンテナ内のプロセス同士は、loopback インターフェース( localhost もしくは127.0.0.1 )か、マウントした外部ストレージを経由して通信することが可能になります。

---

本ハンズオンでは、サイドカーパターンを採用して、モノリスを２つのコンテナに分けて起動することにします。

![monolith3.png](./monolith3.png)

サイドカー構成にすることによる端的なメリットとして、ベースイメージが探しやすくなることがあります。apache + PHP 、もしくは Java のみ、といったコンテナイメージはコミュニティが公式イメージとして公開していることが多いですが、両方が入っているコンテナイメージはあまり存在しません。カスタムイメージを作ることも可能ですが、わざわざそこまでするよりはサイドカーパターンを適用するほうが、Kubernetes Way といえます。

---

## 3.1 デプロイに必要なリソースを準備する

Kubernetes にアプリをデプロイする基本的な流れは以下のような順序になります。

1. アプリケーションを用意する
1. Docker ファイルを準備する
1. Docker Build を実行してアプリケーションイメージを作る
1. アプリケーションイメージを、Kubernetes の利用するレジストリに登録( Push )する
1. Manifest を用意する
1. Manifest をKubernetesに適用する
1. Kubernetes が Manifest に従ってアプリケーション Pod を起動する

モノリスアプリケーションのデプロイでは、１〜４は完了しており Kubernetes にデプロイするばかりという状況から実施していきます。

## 3.2 Manifestの準備

Manifest とは Kubernetes に行いたい設定を記述したファイルのことをいいます。 YAML 形式と JSON 形式が使えます。一般的に YAML 形式を使うことが多いので、 Manifest の別の呼び方として YAML ファイルと呼んだりすることもあります。

YAMLとJSONは相互に互換性があり、人間が読むときはYAML,コンピューターが解釈するときはJSON形式が使われています。

モノリスアプリケーションのデプロイで利用する Manifest は以下のようなものを使います。

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

ここで注目すべきポイントは２つです。

注目ポイント1
```
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
```
サイドカーパターンを利用するので、コンテナは２つ指定されています。ネットワークを共有するので Portの競合を避けるようになっています。

注目ポイント2
```
  strategy:
    type: Recreate
```

Deployment の strategy は、コンテナイメージなどを変更してアプリケーションを再デプロイする際にどういった戦略でコンテナを置き換えるかという設定です。
ここで指定している Recreate は、先に Pod を停止した後に、改めて Pod を作るという戦略です。停止→起動という順序であるためダウンタイムが発生します。

一方 Kubernetes におけるデフォルトの戦略は Rolling という戦略です。 Rolling の場合は、先に新しい Pod が作られてからネットワークのルーティング先を変更するイメージで切り替えが行われます。Rolling はダウンタイムを発生させないための戦略です。

では、なぜ Recreate を指定しているのでしょうか。
ステートを持つモノリスの場合、ブロックストレージをマウントしているケースがあります。ブロックストレージは安全のために単一の VM からしかマウントできないので、Rolling 戦略を実行してしまうと、別の Node に新しい Pod がスケジュールされたケースでは Pod が起動できなくなります（仮にできたとしてもアプリケーションが複数起動できるかは別問題として存在）。これを避けるために Recreate を指定していることとします。

では、手元に Manifest を準備しましょう。

```
cd /projects
git clone https://gitlab.com/openshift-starter-kit/msa-guide.git
cd msa-guide/manifest
cat monolith.yaml
```

CodeReadyWorkspaces の左下の WORKSPACE のペインから開いていくとエディタ上で表示することもできます。

![monolith4.png](./monolith4.png)

## 3.3 モノリスアプリケーションのデプロイ










