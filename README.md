# Starter Kit MSA体験 ハンズオン

Container Stater Kit で実施するハンズオンの手順を紹介します。  
当ハンズオンによって、簡単なモノリスアプリケーションのマイクロサービスへの分割を体験することができます。


## 1. 【管理者向け】 環境準備

## 2. OpenShiftへのログイン

### 2-1. OpenShiftへのWeb Console ログイン

OpenShiftのWeb Consoleにログインしましょう。URLとユーザー/パスワードは管理者から割り当てられたものを使用してください。

![webconsole-login-1.png](./webconsole-login-1.png)

![webconsole-login-2.png](./webconsole-login-2.png)

![webconsole-login-3.png](./webconsole-login-3.png)

Developer パースペクティブへようこそというダイアログが出ればログインは成功です。ツアーはスキップしてください。

- [ ] **2-1 Web Console へのログインを完了した**

すべてチェックがついたら次に進んでください

### 2-2. CodeReadyWorkspaces ログイン

今回のハンズオンは、簡単なモノリスを分解してJavaを利用したマイクロサービスをビルド・デプロイという体験を含んでいます。お手元にJavaの環境がなかったり、コーディングの経験がなく
てもスムーズに進められるようにCodeReadyWorspacesというWebIDEを利用します。

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

- [ ] **2-2 CodeReadyWorkspaces にログインして Terminal を起動した**

すべてチェックがついたら次に進んでください

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

後のためにプロジェクトを作成します。プロジェクトは Kubernetes でいう Namespace と同じで、リソースの名前を一意にするエリアです。
xx環境、というようなイメージでしょうか。

```
oc new-project ${USER_NAME}-monolith
oc new-project ${USER_NAME}-msa
oc project ${USER_NAME}-monolith
```

ここまでで一旦皆さんの到着をまちます。


- [ ] **2-3 CLIでログインした**
- [ ] **2-3-1 環境変数を保存した**
- [ ] **2-3-2 プロジェクトを作成した**

すべてチェックがついたら次に進んでください


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

## ３. モノリスアプリケーションのデプロイ

OpenShift へのログインが完了したら、いよいよモノリスをデプロイしていきます。

サンプルとして利用するモノリスアプリケーションは、このような構造をしています。
Apache + PHP と Java VM の２プロセスを必要としています。

![monolith1.png](./monolith1.png)

呼び出しシーケンスはこのような流れで行われます。PHPがフロントエンドを担当し、Java(SpringBoot)がバックエンドを担当しています。

![monolith2.png](./monolith2.png)

### FAQ 1
---

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
ステートを持つモノリスの場合、ブロックストレージをマウントしているケースがあります。ブロックストレージは安全のために単一の VM からしかマウントできないので、Rolling 戦略を実行してしまうと、別の Node に新しい Pod がスケジュールされたケースでは Pod が起動できなくなります（仮にできたとしてもアプリケーションが複数起動できるかは別問題として存在）。これを避けるために Recreate を指定しています。

## 3.3 モノリスアプリケーションのデプロイ
---

デプロイを行うために手元に Manifest を準備しましょう。

```
cd /projects
git clone https://gitlab.com/openshift-starter-kit/msa-guide.git
cd msa-guide/manifest
cat monolith.yaml
```

ダウンロードしたファイルは、CodeReadyWorkspaces の左下の WORKSPACE のペインから開いてGUI上で表示することもできます。

![monolith4.png](./monolith4.png)

それではモノリスアプリケーションをデプロイしていきましょう。３通りの方法があります。

Kubernetes Way
```
kubectl apply -f monolith.yaml
```

OpenShift Way
```
oc apply -f monolith.yaml
```

Web Console から

![monolith5.png](./monolith5.png)

どれも結果は同一になります。確認してみましょう。

Kubernetes Way
```
kubectl get all
```

OpenShift Way
```
oc get all
```

Web Console から

![monolith6.png](./monolith6.png)


## 3.4 モノリスアプリケーションへのアクセス


ここでは OpenShift Kubernetes がどうやって Pod へのアクセス手段を提供しているか見ていきます。
Service と Route というリソースです。

### 3.4.1 Service の動作確認 

ではデプロイで来たモノリスアプリケーションの動作を確認してみましょう。 CodeReadyWorkspaces の Terminal 内から curl で確認します。

```
echo monolith.${USER_NAME}-monolith.svc
curl http://monolith.${USER_NAME}-monolith.svc
```

結果
```
[jboss@workspacefj04s6sm57jsfjaz manifest]$ echo monolith.${USER_NAME}-monolith.svc
monolith.user1-monolith.svc
[jboss@workspacefj04s6sm57jsfjaz manifest]$ curl http://monolith.${USER_NAME}-monolith.svc
<!DOCTYPE html>
<html>
        <head>
                <title>MicroService Demo</title>
        </head>
        <body>
        <form action="/index.php" method="POST">
                <input type="checkbox" value="200" name="item[]" />Pizza&nbsp;&nbsp;&nbsp;200<br/><input type="checkbox" value="150" name="item[]" />Ola&nbsp;&nbsp;&nbsp;150<br/><input type="checkbox" value="200" name="item[]" />Movie&nbsp;&nbsp;&nbsp;200<br/>      <br/>
        <input type="submit" Value="Buy" name="buy" onclick="showInput()"/>
        </form>
        </body>
</html>
```

html が表示されたはずです。 

Kubernetes においては Service の名称と Namespace の名称を組み合わせて内部DNSのAレコードとして解決することができます。（Aレコードは ホスト名→IP の対応付けがされている DNS レコード）
Aレコードは下記のようなルールです。

```
my-svc.my-namespace.svc.cluster.local
```

詳しくは下記URLを参照してください。

https://kubernetes.io/ja/docs/concepts/services-networking/dns-pod-service/

以下のような省略も可能です。

同一 Project(Namespace) 内では Service名のみでOK

```
my-svc
```

異なる Project(Namespace) では、cluster.local が省略可能

```
my-svc.my-namespace.svc
```



### 3.4.2 Route の追加と動作確認

Service 名でアクセスが可能なのは同一 Kubernetes 内に限定されます。
OpenShift においては クラスタ外から Pod にアクセスする方法はいくつかあります。

- type: Load Balancer の Service を利用する
- External IP, NodePort の Serviceを利用する
- Router,Ingressを利用する

httpアクセスの場合は Router を利用するのが便利です。では Route リソースをつくってみましょう。

CLIから
```
oc expose service monolith
```

URLの確認方法

CLIから
```
oc get route monolith
```

出力結果
```
[jboss@workspacefj04s6sm57jsfjaz projects]$ oc get route
NAME       HOST/PORT                                                     PATH   SERVICES   PORT   TERMINATION   WILDCARD
monolith   monolith-user1-monolith.apps.xxx.ocp1.openshiftapps.com          monolith   8080                 None
```

Web Console から

![monolith7.png](./monolith7.png)

URLをブラウザーで開いた状態

![monolith8.png](./monolith8.png)

#### OpenShift Router とは

OpenShift Router は OpenShift v3 の初期からあった、 OpenShift の外からの通信を Pod に流すための仕組みです。
実態は HAProxy であるため、やろうと思えばかなり高度な設定ができます。

- L7 ロードバランシング (複数サービスでのA/Bデプロイメント)
- TSL終端
- IP White List
- Rate Limit
- など多数

一方、 Kubernetes では Ingress を用います。 Ingress は 2015年９月の Kubernetes 1.1.0 以降、alpha/Beta の期間が長かったのですが、 OpenShift はエンタープライズ用途での商業利用を開始していただくために、独自の道を歩んだ時代がありました。

その後、両者は歩み寄っていき、 Kubernetes 上で HAProxy を利用したり、 OpenShift 上で Ingress を利用したり、相互の垣根はどんどんなくなってきています。


## 3.5 基本的な運用方法

最も基本的な運用方法として、アプリケーションのログの参照とアプリケーションの再起動の仕方を見ていきましょう。

### 3.5.1 アプリケーションのログの見方

OpenShift や Kubernetes においては、アプリケーションログは標準出力に出力することが推奨されています。標準出力に出力しておくことで、ログの収集や閲覧をオーケストレーター側の機能にまかせることができます。

サンプルのモノリスアプリケーションもログは標準出力に出力しています。ログの内容をみてみましょう。

CLIから
```
oc logs deploy/monolith -c monolith-service

```
サイドカーパターンであるため、-c で対象コンテナを指定していますが、1 Pod 1 Container の場合には、指定する必要はありません。

出力結果
```
bash-4.4$ oc logs deploy/monolith -c monolith-service
Starting the Java application using /opt/jboss/container/java/run/run-java.sh ...
INFO exec  java -javaagent:/usr/share/java/jolokia-jvm-agent/jolokia-jvm.jar=config=/opt/jboss/container/jolokia/etc/jolokia.properties -XX:+UseParallelGC -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -XX:+ExitOnOutOfMemoryError -cp "." -jar /deployments/monolithic-1.4.4.RELEASE.jar 
OpenJDK 64-Bit Server VM warning: If the number of processors is expected to increase from one, then you should configure the number of parallel GC threads appropriately using -XX:ParallelGCThreads=N

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.4.4.RELEASE)

methods in repositoryRestExceptionHandler

~~

2022-03-09 11:11:37.449  INFO 1 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2022-03-09 11:11:37.510  INFO 1 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8081 (http)
2022-03-09 11:11:37.516  INFO 1 --- [           main] w.weave.socks.broker.BrokerApplication   : Started BrokerApplication in 4.092 seconds (JVM running for 4.905)
2022-03-09 11:29:17.997  INFO 1 --- [nio-8081-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring FrameworkServlet 'dispatcherServlet'
2022-03-09 11:29:17.998  INFO 1 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization started
2022-03-09 11:29:18.013  INFO 1 --- [nio-8081-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization completed in 15 ms

```

Web Console から

![monolith9.png](./monolith9.png)

![monolith10.png](./monolith10.png)

### 3.5.2 アプリケーションの再起動の仕方

次はアプリケーションの再起動の仕方をみていきます。
OpenShift Kubernetes においては再起動は Pod の削除と再作成を意味します。

Deployment においては、再起動の仕方は Pod を削除するか、 rollout をさせるかの２つがメジャーな方法となります。

#### 3.5.2.1 Pod を削除する

これは Deployment や StatefulSet といった Pod の面倒をみてくれるリソース経由で Pod が維持されている場合に有効な手段で、もっとも原始的な方法になります。

CLIより
```
oc delete pods -l=app=monolith
oc get pods -w

```
簡単のためラベル指定で Pod を削除していますが、通常の運用では Pod 名を調べて直接指定するほうがよいでしょう。（Pod 名にランダム文字列がはいるためです）

出力
```
bash-4.4$ oc delete  pods -l=app=monolith
pod "monolith-6c6c9cd894-r6zr5" deleted
bash-4.4$ oc get pods -w
NAME                        READY   STATUS              RESTARTS   AGE
monolith-6c6c9cd894-cbw4m   0/2     ContainerCreating   0          2s
monolith-6c6c9cd894-cbw4m   0/2     ContainerCreating   0          3s
monolith-6c6c9cd894-cbw4m   2/2     Running             0      
```

STATUS が ContainerCreating から Running に変化したら、CTRL ＋　C でコマンドを中断してください。

削除されると、 Deployment が内部で利用している replication controler によって、 Pod 数を 1 に戻そうとする動きになり、結果として再起動となります。

#### 3.5.2.２ ロールアウトさせる

削除ではいかにも危険な雰囲気を感じる場合や、 Deployment strategy を Rolling にしてあり、もっと安全に再起動が行われてほしいときはこちらが有効です。

CLIから
```
oc rollout restart deploy monolith
oc get pods -w

```

Web Console には同じ操作をするメニューはありません。ただし、deployment とよく似た deploymentconfig であればメニューが存在します。

![monolith11.png](./monolith11.png)

実は deployment における rollout は比較的新しいコマンドになります。下記の Issue で長いあいだ議論されていました。 
https://github.com/kubernetes/kubernetes/issues/13488

一方、 OpenShift における deployment config においては、 OpenShift v3 の最初から rollout の実行は行うことができました。 細かいところですが、OpenShift と Kubernetes が近づいているところの１つです。

## 4 Micro Service Archtecture への移行

ここまでコンテナ化したモノリスアプリケーションを扱ってきました。ここからは Micro Service Architecture への移行を体験していきます。
今回コンテナ環境にリフトしたモノリスアプリケーションは、すでに Front End と Back End が Pod 内部で別コンテナとして別れていました。わざわざサイドカーパターンを使うより、別 Pod にしたほうが合理的ではないかと考えた方もいるのではないかと思います。






