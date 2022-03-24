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

ユーザー名を後のタイミングでコマンド内で利用することがあるため、以下のコマンドを実施してください。
```
export USER_NAME=`oc whoami`
cat << EOF > ~/.bashrc
export USER_NAME=$USER_NAME
EOF
```

### 2-3-２.プロジェクト作成

後のためにプロジェクトを作成します。プロジェクトは Kubernetes でいう Namespace と同じで、リソースの名前を一意にするエリアです。

```
oc new-project ${USER_NAME}-monolith
oc new-project ${USER_NAME}-msa
oc project ${USER_NAME}-monolith
```

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

コンテナの内部からは、そこがコンテナであるかどうかというのはなかなか分かりづらいことがおわかりいただけたでしょうか。

次は oc login コマンドは何を行ったかを見てみましょう。

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

実は、この Terminal からは Kubernetes のコントロールコマンドである kubectl も実行することができます。

コマンド
```
kubectl config view
```

先ほどと同じ内容が見えたはずです。 kubectl は OpenShift とも会話することができます。

## ３. モノリスアプリケーションのデプロイ

OpenShift へのログインが完了したら、いよいよモノリスをデプロイしていきます。

サンプルとして利用するモノリスアプリケーションは、このような構造をしています。
Apache + PHP と Java VM の２プロセスを必要としています。

![monolith1.png](./monolith1.png)

呼び出しシーケンスはこのような流れで行われます。PHPがフロントエンドを担当し、Java(SpringBoot)がバックエンドを担当しています。

![monolith2.png](./monolith2.png)

---

### FAQ 1

モノリスをコンテナにする際にこういった質問がよくあります。


Q. 我々が利用しているアプリケーションはメインプロセス以外に、複数のプロセスをデーモンとして必要としています。１コンテナ１プロセスと聞いていますが、こういったアプリケーションはどうすればコンテナにいれられるのでしょうか？

A. 方法は２つあります。１つはメインとなるアプリケーションをフォワードプロセスとして起動しておき、その他のデーモンをバックグラウンドプロセスとして起動する方法です。ただし、これは以下のような理由であまりおすすめしません。

1. コンテナはバックグラウンドプロセスを起動したままメインプロセスの再起動しようとしても、コンテナ自体が終了してしまうのでコンテナまるごとでしか再起動できなくなる
1. メインアプリケーションもバックグラウンド化する方法があるが、ここまでやってしまうとコンテナ化するメリットをすべて享受できなくなる
1. コンテナのもとになるコンテナイメージは、軽量化するためにsystemdを含んでいないことが多いので、デーモンを管理する方法が手動になってしまう（systemdをもつコンテナイメージも存在する）

このようなとき、 Kubernetes においてはサイドカーパターンを利用することが正解になるケースがあります。サイドカーとは1つのPodの中に複数コンテナを起動することです。Pod 内に起動した複数コンテナは以下のような特徴を持ちます。

1. Pod 内のコンテナは同じ Node で起動することが保証されている
1. 同一 Pod 内のコンテナはネットワークとマウントした外部ストレージを共有している（ファイルシステムは共有していない）
1. どれか１つのコンテナが終了すると、Pod も終了する

２番めの特徴によって、コンテナ内のプロセス同士は、loopback インターフェース( localhost もしくは127.0.0.1 )か、マウントした外部ストレージを経由して通信することが可能になります。
ですが、３番めの特徴があるため、コンテナプロセス全体は一蓮托生になってしまいます。

---

本ハンズオンでは、サイドカーパターンを採用して、モノリスを 1 Pod ２ コンテナで起動することにします。

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

Manifest とは Kubernetes に行いたい設定を記述したファイルのことをいいます。 YAML 形式と JSON 形式が使えます。一般的に 人間にとって可読性の高い YAML 形式をよく用います。

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

## 3.3 モノリスアプリケーションのデプロイ実施
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

OpenShift Router は OpenShift の外からの http 通信を Pod に流すための仕組みです。
実装は HAProxy であるため、やろうと思えばかなり高度な設定ができます。

- L7 ロードバランシング (複数サービスでのA/Bデプロイメント)
- TSL終端
- IP White List
- Rate Limit
- など多数

一方、 Kubernetes では Ingress を用います。 Ingress は 2015年９月の Kubernetes 1.1.0 以降、alpha/Beta の期間が長かったのですが、 OpenShift はエンタープライズ用途での商業利用を開始するために、独自の道を歩んだ時代がありました。

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
サイドカーパターンであるため、-c で対象コンテナを指定していますが、1 Pod 1 Container の場合には指定する必要はありません。

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

一方、 OpenShift における deployment config においては、 OpenShift v3 の最初から rollout の実行を行うことができました。 細かいところですが、OpenShift と Kubernetes が近づいているところの１つです。
(Kubernetes でも OpenShift のように xx したい、という要望があるようです)

## 4 Micro Service Archtecture への移行

ここまでコンテナ化したモノリスアプリケーションを扱ってきました。ここからは Micro Service Architecture への移行を体験していきます。
今回コンテナ環境にリフトしたモノリスアプリケーションは、すでに Front End と Back End が Pod 内部で別コンテナとして別れていました。わざわざサイドカーパターンを使うより、別 Pod にしたほうが合理的ではないかと考えた方もいるのではないかと思います。Micro Service Architecture をデプロイする方法を知っておくことがキーポイントになります。

まず最初の手順として、マイクロサービスアプリケーションのソースを手元にダウンロードしておきます。

CLIより
```
oc project $USER_NAME-msa
cd /projects
git clone http://$USER_NAME:openshift@lab-gitea.lab-infra.svc:3000/$USER_NAME/msa-app.git
cd msa-app
```

次に Java のビルドを高速化するためのおまじないをしておきます。

CLIより
```
cat << EOS > /home/jboss/.m2/settings.xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              https://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>my-mirror</id>
      <name>Maven Central Mirror</name>
      <url>http://lab-nexusrepo.lab-infra.svc/repository/maven-central/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
EOS
```


Web Console のプロジェクトを userxx-msa に切り替えておいてください。

![msa0.png](./msa0.png)

### 4.1 Frontend デプロイ

まず、 Frontend をデプロイしていきます。

CLより
```
oc new-app php:7.4-ubi8~http://lab-gitea.lab-infra.svc:3000/$USER_NAME/msa-app.git --context-dir='microservices/frontend/' --name='frontend'
```

結果
```
bash-4.4$ oc new-app php:7.4-ubi8~http://lab-gitea.lab-infra.svc:3000/$USER_NAME/msa-app.git --context-dir='microservices/frontend/' --name='frontend'
--> Found image dc56c67 (6 weeks old) in image stream "openshift/php" under tag "7.4-ubi8" for "php:7.4-ubi8"

    Apache 2.4 with PHP 7.4 
    ----------------------- 
    PHP 7.4 available as container is a base platform for building and running various PHP 7.4 applications and frameworks. PHP is an HTML-embedded scripting language. PHP attempts to make it easy for developers to write dynamically generated web pages. PHP also offers built-in database integration for several commercial and non-commercial database management systems, so writing a database-enabled webpage with PHP is fairly simple. The most common use of PHP coding is probably as a replacement for CGI scripts.

    Tags: builder, php, php74, php-74

    * A source build using source code from http://lab-gitea.lab-infra.svc:3000/user1/msa-app.git will be created
      * The resulting image will be pushed to image stream tag "frontend:latest"
      * Use 'oc start-build' to trigger a new build

--> Creating resources ...
    imagestream.image.openshift.io "frontend" created
    buildconfig.build.openshift.io "frontend" created
    deployment.apps "frontend" created
    service "frontend" created
--> Success
    Build scheduled, use 'oc logs -f buildconfig/frontend' to track its progress.
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/frontend' 
    Run 'oc status' to view your app.
```

oc new-app というコマンドを実施たところ複数の Resource が作成されました。

- imagestream
- buildconfig
- deployment
- service


このコマンドは下記のうち、２〜６を一気にやってしまえる便利コマンドです。 oc new-app できるようにアプリケーションを用意する必要はありますが、アプリケーションの開発者にとっては非常に便利なコマンドです。

1. アプリケーションを用意する
1. Docker ファイルを準備する
1. Docker Build を実行してアプリケーションイメージを作る
1. アプリケーションイメージを、Kubernetes の利用するレジストリに登録( Push )する
1. Manifest を用意する
1. Manifest をKubernetesに適用する
1. Kubernetes が Manifest に従ってアプリケーション Pod を起動する

frontend は UI を担当するので Route をつくっておきましょう。

CLより
```
oc expose service frontend
```

結果
```
bash-4.4$ oc expose service frontend
route.route.openshift.io/frontend exposed
```

### 4.2 Payment Catalog デプロイ

では次は Pyament サービスと Catalog サービスをデプロイしていきましょう。
アプリケーションの初回ビルドで大量の maven artifact をダウンロードするので時間がかかります。

Catalog サービスのデプロイ
```
cd /projects/msa-app/microservices/catalog
./mvnw clean package -Dquarkus.kubernetes.deploy=true
```

Payment サービスのデプロイ
```
cd /projects/msa-app/microservices/payment
./mvnw clean package -Dquarkus.kubernetes.deploy=true
```

ビジュアルラベル付け
```
oc label deploy frontend app.openshift.io/runtime=php
oc label deploy frontend app.kubernetes.io/part-of=microservice-app
oc label dc  catalog app.kubernetes.io/part-of=microservice-app
oc label dc  payment app.kubernetes.io/part-of=microservice-app
```
結果
![msa1.png](./msa1.png)

frontend にカーソルを乗せると矢印がでるので、ドラッグアンドドロップして、 catalog と payment につなげてみましょう。

結果
![msa2.png](./msa2.png)

このようにマイクロサービス間の関係を可視化することができます。

### 4.3 【Option】 Cloud Native Runtime *Quarkus* とは

モノリスアプリケーションのバックエンドは SpringBoot で作られていましたが、マイクロサービスのバックエンドは Quarkus というフレームワークで書き直しています。

Quarkus は Java を Kubernetes でより効率よく動かすために Fat になりすぎた JakaｒtaEE（旧 JavaEE）の仕様を踏襲せずに、クラウドネイティブなアプリケーションに必要な機能のみで作り直したフレームワークです。起動が極めて早いこととフットプリントが小さいことと開発者向けの便利な機能がたくさんあることが特徴です。

CLI より
```
oc logs deploymentconfig/payment
```

結果
```
[jboss@workspaceghtvo0pweder7x0a microservices]$ oc logs deploymentconfig/payment
__  ____  __  _____   ___  __ ____  ______ 
 --/ __ \/ / / / _ | / _ \/ //_/ / / / __/ 
 -/ /_/ / /_/ / __ |/ , _/ ,< / /_/ /\ \   
--\___\_\____/_/ |_/_/|_/_/|_|\____/___/   
2022-03-11 02:53:14,863 INFO  [io.quarkus] (main) payment 1.0.0-SNAPSHOT on JVM (powered by Quarkus 1.11.7.Final) started in 0.969s. Listening on: http://0.0.0.0:8080
2022-03-11 02:53:14,884 INFO  [io.quarkus] (main) Profile prod activated. 
2022-03-11 02:53:14,885 INFO  [io.quarkus] (main) Installed features: [cdi, kubernetes, resteasy]
2022-03-11 02:53:20,592 INFO  [com.exa.PaymentResource] (executor-thread-1) received: 350
```

Quarkus のアスキーアートのあとに *started in 0.969s* とでています。１秒かからずに起動が完了しています。

メモリの使用量もみてみましょう。

モノリスのメモリ使用率

![msa3.png](./msa3.png)

マイクロサービス(Payment)のメモリ使用率

![msa4.png](./msa4.png)

モノリスアプリケーションは apache + PHP と Java SpringBoot がサイドカーとしてデプロイされていました。対してマイクロサービスの Payment は Quarkus 単体ですが、これくらいの差があります。 

Quarkus は OpenShift のサブスクリプションに含まれており、 Red Hat のサポートをうけることができます。
コミュニティとしての Quarkus の上方は下記のガイドによくまとまっていて、特にマイクロサービス時代におけるユースケースが Developer 向けに紹介されて言いますので参考にしてください。

https://ja.quarkus.io/guides/


### 4.4 マイクロサービス内のDNS名解決のルール作り

3.4.1 にて Kubernetes の Service のルールを確認しました。
マイクロサービスにおいてはDNS名を解決する頻度がモノリスアプリケーションに比べて飛躍的に増えます。そのためアプリケーションの接続先のホスト名やIPアドレスなどをどうやって設定していくかはあらかじめルールを作っておくべきです。

ルールを作る前に以下の特性を理解しておきましょう。

- Pod の IP アドレスは Pod が再作成されるたびにかわる
- Pod 内からは my-svc.my-namespace.svc.cluster.local （省略可能） のルールに従って、Service 名から IP アドレスが透過的に解決できる
- Service がもつ Cluster-IP は固定されるが、 Service を作り直すと変わる
- Service は Port を隠蔽しない
- Service は 配下に複数 Pod がいる場合、L3 ロードバランシングのイメージで単純ラウンドロビンしか行わない

![msa5.png](./msa5.png)

例えば、本ハンズオンでサンプルとして使っている Frontend の PHP アプリケーションでは、下記のように直接 Kubernetes に依存した書き方をしています。 

```
		$total=calc_total($sel_items);
#		echo $total;
		$url = "http://payment:8080/payment?total=".$total;
		
		$client = curl_init($url);
```

```
	$t1="";
	$url = "http://Catalog:8080/getCatalog";
	$client = curl_init($url);
	curl_setopt($client,CURLOPT_RETURNTRANSFER,true);
```

「Service 名で抽象化できているのでこれでよいのではないか？」 と考えるのも１つの手ではありますが、マイクロサービスの範囲が広がってくるとこの埋め込みが技術的負債になりそうです。また、手元でテストのために動かす際に payment や catalog を PC のhosts ファイルに登録する手間もあります。

DNSの名前解決ルールの策定方針としては、サービス名とポート名は外から与える形式を採るのが望ましいでしょう。

### 4.5 ルールの中心に Infrastructer as Code

マイクロサービスの管理において中心的な考え方になってくるのが Infrastructer as Code です。
ここでは狭い範囲で Infrastructer as Code の考え方見ていきます。

OpenShift や Kubernetes は使っているだけで Infrastructer as Code であると言える部分が多々あります。
例えば、 payment service は以下のような Manifest で表現されます。 これまで手動管理してきた IP アドレス を Service 名で抽象化しながら、 Code として管理できます。
```
apiVersion: v1
kind: Service
metadata:
  name: payment
spec:
  selector:
    app: payment
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
```

サンプルアプリケーション側には Service 名が直接埋め込まれているので、これも Infrastructer as Code の考え方で整理しましょう。
Kubernetes において アプリケーションの設定という Infrastructure を Code にしてくれるリソースは大きく３つ存在します。

- ConfigMap
- Deployment などにおける Env
- Secret

ConfigMap は キー/バリューで定義するパターンと、ファイルのように定義する二種類の方法があります。

https://kubernetes.io/ja/docs/concepts/configuration/configmap/

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  # キーバリューで定義する場合
  catalog-service-host: "catalog:8080"
  payment-service-host: "payment:8080"
 
  # ファイル形式で定義する場合
  config.php: |
    <?php
    return [
        'catalog-service-host' => 'catalog:8080',
        'payment-service-host' => 'payment:8080',
    ];
    ?>
```

ConfigMap は環境変数を通して Pod に伝える方法と、読み取り専用の擬似的なファイルとして Pod 内にマウントしてしまう方法があります。

環境変数を使う方法いくつかパターンがありますが、よく使うのは以下の２つです。直接定義する場合と、ConfigMap の キー/バリュー を指定する方法です。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment
  labels:
    app: payment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment
  template:
    metadata:
      labels:
        app: payment
    spec:
      containers:
      - name: payment-service
        image: image-registry.openshift-image-registry.svc:5000/lab-user1/payment:latest
        ports:
         - containerPort: 8081
           protocol: TCP
        env:
          # 直接定義する場合
          - name: catalog-service-host
            value: 'catalog:8080'
          - name: payment-service-host
            value: 'payment:8080'
          # ConfigMap 経由で定義する場合
          - name: catalog-service-host
            valueFrom:
              configMapKeyRef:
                name: frontend-config
                key: catalog-service-host
          - name: payment-service-host
            valueFrom:
              configMapKeyRef:
                name: frontend-config
                key: payment-service-host
```


Secret は ConfigMap と似ていますが、ユーザーのロールによって中味を参照できるかできないかという差があります。ですが、OpenShift や Kubernetes の設定情報が書き込まれている etcd サービス上には、 BASE64 エンコードされておかれているだけのため、企業によっては要件に合わない可能性があります。  Secret については本ハンズオンでは紹介にとどめます。

https://kubernetes.io/ja/docs/concepts/configuration/secret/

環境変数に直接パラメーターを定義する方法と、 ConfigMap を使う方法は一長一短があります。すべてのパラメーターをConfigMap にいれておいて、複数 Deployment から参照している状態であれば、変更を一回で行える、という考え方ができますが、逆に言えば１つの変更が他に波及することになります。

保守性を考えると、マイクロサービスの面倒をみる組織単位をこえた共通化は NG としておくの一つの指針になりそうです。
また、マイクロサービスごとに必ず同じになるはずのパラメータ（例えば共通で利用する外部サービスのURLなど）と、局所性があるパラメータは別管理にしたほうがよいでしょう。

Infrastructure　as Code を行うと、コードのメンテナンス性とインフラのメンテナンス性が同一になる、ということに注目してください。Dev と Ops が一緒になって、これまでのアプリケーション・インフラの保守双方のプラクティス元に議論するべきポイントです。小さいところから DevOps をはじめてみましょう。

### 4.6 マイクロサービスに変更を加える

次はマイクロサービスに変更を加えてみましょう。 サンプルアプリケーションのデプロイメントにはかっちりしたパイプラインはまだありませんが、OpenShift をつかってアプリケーションを構築しているので、ある程度の自動化とInfrastructure as Code が実践された状態になっています。

まずは

#### 4.6.1 Frontend の パラメーター外出し化

まずは小規模な変更を行ってみましょう。動作はそのままで技術的負債を返済します。
Frontend の直接アプリケーションに記述しているパラメーターを OpenShift からインジェクションするように変更します。

##### 4.6.1.1 Deployment に環境変数を追加する

Frontend の Deployment を変更していきますが、現在マイクロサービスは開発途中ということで Manifest をまだ管理していない状況です。
ここでは Web Console から環境変数の編集を実施してみましょう。

Web Console の Topology から以下のように Frontend の Deployment を編集する画面を開いていってください。

![msa7.png](./msa7.png)

画面をスクロールしていくと環境変数の編集画面があります。

![msa8.png](./msa8.png)

下記のように編集して、保存してください。

|  名前  |  値  |
| ---- | ---- |
|  payment-service-host  |  payment:8080  |
|  catalog-service-host  |  catalog:8080  |

![msa9.png](./msa9.png)

##### 4.6.1.2 アプリケーションの変更
ではアプリケーションを変更します。

CodeReadyWorkspaces の左下のペインから msa-app → microservices → frontend と開いていき、 index.php を開いてください。

![msa6.png](./msa6.png)

３２行目と４２行目が編集対象です。
CodeReadyWorkspaces はデフォルトは AutoSave なので編集すれば自動的に保存されています。

32行目 編集前
```
		$url = "http://payment:8080/payment?total=".$total;
```

42行目 編集前

```
	$url = "http://Catalog:8080/getCatalog";
```

それぞれを下記のように変更してください。

32行目 編集後
```
		$url = "http://" . getenv("payment-service-host"). "/payment?total=" . $total;
```

42行目 編集後

```
	$url = "http://" . getenv("catalog-service-host") .  "/getCatalog";
```

変更をリポジトリに反映しましょう。

CLIより
```
cd /projects/msa-app/
git add microservices/frontend/index.php
git commit -m "Service パラメーターを外出し"
git push
```

結果
```
bash-4.4$ cd /projects/msa-app/
bash-4.4$ git add microservices/frontend/index.php
bash-4.4$ git commit -m "Service パラメーターを外出し"
[master f94a064] Service パラメーターを外出し
 1 file changed, 2 insertions(+), 2 deletions(-)
bash-4.4$ git push
Enumerating objects: 9, done.
Counting objects: 100% (9/9), done.
Delta compression using up to 4 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 582 bytes | 582.00 KiB/s, done.
Total 5 (delta 3), reused 0 (delta 0), pack-reused 0
remote: . Processing 1 references
remote: Processed 1 references in total
To http://lab-gitea.lab-infra.svc:3000/user1/msa-app.git
   06443cf..f94a064  master -> master
```

アプリケーションのビルドを実行します。

CLIより
```
oc start-build frontend
```

すぐに Web Console を開いて Frontend の Deployment の様子をみてみましょう。

まずはビルドが進行しているマークがでます。（ここをクリックするとビルドのログを見ることもできます）

![msa10.png](./msa10.png)

次にアプリケーションが Rolling Strategy で Deploy される様子が見えます。

![msa11.png](./msa11.png)

#### Option 4.6.3 Catalog の変更

進行が速い方は Catalog も編集してみましょう。少し階層が深いですが、 CatalogResource.java までたどってください。

![msa12.png](./msa12.png)

14行目が UI に表示されている在庫と価格を返却している部分です。

変更前
```
        return "Pizza,Ola,Movie:200,150,200";
```

好きなように変更してみましょう。例えば以下のように変更してみます。

変更後
```
        return "Pizza,Ola,Movie,Orage:200,150,200,100";
```

ではデプロイしましょう。 Quarkus アプリケーションが Deploy　済みの場合は、ビルドだけを行う下記のコマンドがよいでしょう。

CLIより
```
cd /projects/msa-app/microservices/catalog
./mvnw clean package -Dquarkus.container-image.build=true
```

Frontend をブラウザで開いて結果が反映されているか確認してみてください。

![msa13.png](./msa13.png)

Payment も Quarkus アプリケーションなので同じような手順で変更をすることができます。

更にアプリケーションを発展させたい場合は Quarkus ガイドが参考になります。まずはデータベースアクセスを追加してみるのはどうでしょうか。最初の一歩として「シンプルな REST CRUDサービスの書き方」がおすすめです。（ガイドのバージョン番号の指定をお忘れなく！）

https://ja.quarkus.io/version/1.11/guides/rest-data-panache

#### Option 4.6.４ Catalog に ヘルスチェック を追加

OpenShift Kubernetes 上でマイクロサービスを動かして開発を加速していく際には、個々のサービスに対する Observability を確保しておくことが推奨されます。
最も初歩的な Observability の確保の仕方として、 Readiness Probe と Livness Probe にアプリケーションを対応させる方法があります。

クラウドネイティブランタイムである Quarkus は、自動で Probe 用のエンドポイントを作成することができます。
詳しくは下記のガイドを参考にしてください。

https://ja.quarkus.io/version/1.11/guides/microprofile-health

CLIより
```
cd /projects/msa-app/microservices/catalog
./mvnw quarkus:add-extension -Dextensions="smallrye-health"
./mvnw clean package -Dquarkus.kubernetes.deploy=true
```

この Extension が追加されている状態で deploy を行い直すことで、 OpenShift 側の設定も変わります。
実施前の Deployment は、このような警告がでていましたが、 Deploy が完了すると警告は消えます。つまり Deployment に対して Probe の設定が行われたということです。

![msa15.png](./msa15.png)

どのように設定されたのか見てみましょう。 catalog の Deployment Config のアクションメニューから、ヘルスチェックの編集を選択してください。

![msa16.png](./msa16.png)

緑字で「追加済みの Rediness プローブ」 というところをクリックすると、このように設定されていることが確認できます。

![msa17.png](./msa17.png)

### ４．７. Kubernetes にスケーラブルなアプリケーションを配置することで得られるもの

ここからはスケーラビリティのあるアプリケーションがコンテナ基盤上でどのような威力をもつのか体感していきましょう。

#### 4.7.1 スケールアウト実行

まずは作成したマイクロサービス１つずつをスケールアウトさせます。

CLIより
```
oc scale deploy frontend --replicas=2
oc scale deploymentconfig catalog --replicas=2
oc scale deploymentconfig payment --replicas=2
oc get pods|grep Running
```

Web Console より

![resilience1.png](./resilience1.png)

数を直接入れたい場合

![resilience2.png](./resilience2.png)

![resilience3.png](./resilience3.png)

結果
```
bash-4.4$ oc scale deploy frontend --replicas=2
deployment.apps/frontend scaled
bash-4.4$ oc scale deploymentconfig catalog --replicas=2
W0317 07:10:34.243383    1359 warnings.go:70] extensions/v1beta1 Scale is deprecated in v1.2+, unavailable in v1.16+
deploymentconfig.apps.openshift.io/catalog scaled
bash-4.4$ oc scale deploymentconfig payment --replicas=2
W0317 07:10:34.355419    1367 warnings.go:70] extensions/v1beta1 Scale is deprecated in v1.2+, unavailable in v1.16+
deploymentconfig.apps.openshift.io/payment scaled
bash-4.4$ oc get pods|grep Running
catalog-8-hftck             1/1     Running     0          19h
catalog-8-mknxm             1/1     Running     0          10m
frontend-7d4ff9f8fc-gbq8t   1/1     Running     0          2m8s
frontend-7d4ff9f8fc-kdfmb   1/1     Running     0          19h
payment-1-g9kxv             1/1     Running     0          10m
payment-1-lkq2f             1/1     Running     0          19h
```

#### 4.7.2 MSA レジリエンス体験 （連続アクセス ＆ アプリケーションを止める）

まずは、アプリケーションに連続したアクセスをかけましょう。１秒に一回 Frontend の画面を要求します。

CLIより
```
APP_URL=http://`oc get route frontend -o jsonpath='{.spec.host}'`
for i in {0..1000}
do
    curl -I $APP_URL
    sleep 1;
done
```

アクセスを止める場合は、CTRL + C を押してください。

次はアプリケーションを断続的に停止します。Web Console の Administrator パースペクティブで Pod の一覧画面を開きます。

![resilience4.png](./resilience4.png)

![resilience5.png](./resilience5.png)

Pod に Running のフィルターをかけます。

![resilience6.png](./resilience6.png)

Web Console と CLI でのアクセス実行状況が同時に見えるようにこのようにウィンドウを配置してください。（２画面以上あるかたはそれぞれ別画面で開いても OK です）

![resilience7.png](./resilience7.png)

Web Console から適当に Pod を選んで削除してみましょう。

![resilience8.png](./resilience8.png)

CLI にでるログに注目してください。概ね１秒毎にアクセスをしているので、 Date のところが１秒ずつ進んでいるはずです。

![resilience9.png](./resilience9.png)

Pod を何度も削除してみてください。そのたびにアプリケーションが起動してきて、このログが流れることを止めるが非常に難しいことが実感できるかと思います。

*勝手に壊れた機械を人間が手動で直す* という経験はこれまで何度もあったと思いますが、 *人間が壊した機械を機械が勝手に直す* 体験ははじめてではないでしょうか。これが Kubernetes を利用する際に、最初に得るべきメリットです。 

#### 4.7.3 Option MSA 無停止アプリケーションリリース

進行が早いは、連続アクセスを実行したまま 4.6 のような手順でアプリケーションを変更してみてください。 

#### 4.7.4 MSA トラブル体験

Kubernetes OpenShift の基本的なメリットは先程体感することができました。止めようとしてもなかなか止まらないことが体験できました。
次はアプリケーションが個別に完全に止まってしまった場合にどういったことがおこるかを体験します。

まずは、 Frontend を止めてみましょう。

CLIより
```
oc scale deployment 　frontend --replicas=0
oc scale deploymentconfig catalog --replicas=2
oc scale deploymentconfig payment --replicas=2
```

CLIより
```
APP_URL=http://`oc get route frontend -o jsonpath='{.spec.host}'`
for i in {0..1000}
do
    curl -I $APP_URL
    sleep 1;
done
```

このように HTTP 503 が連続的に返却されてくるはずです。
止める場合は CTRL + C を押してください。

結果
![resilience10.png](./resilience10.png)

Frontend をブラウザで開くと、このような画面が出ています。

![resilience11.png](./resilience11.png)

これは OpenShift Router が Frontend の Redady な Pod を探したものの、１つもないのでエラーで応答してくれているのでこのようにすぐにエラーが返却されています。

では、次は Catalog が止まっている状態ではどうでしょうか。

CLIより
```
oc scale deployment 　frontend --replicas=2
oc scale deploymentconfig catalog --replicas=0
oc scale deploymentconfig payment --replicas=2
```

CLIより
```
APP_URL=http://`oc get route frontend -o jsonpath='{.spec.host}'`
for i in {0..1000}
do
    curl -I $APP_URL
    sleep 1;
done
```

結果
![resilience12.png](./resilience12.png)

エラーがすぐに返却されずに、504 Gateway Time-out が発生します。（しばらく 200 OK が交じるのはキャッシュの影響だとおもわれます）

次は Payment が止まっている状況を見てみましょう。

CLIより
```
oc scale deployment 　frontend --replicas=2
oc scale deploymentconfig catalog --replicas=2
oc scale deploymentconfig payment --replicas=0
```

CLIより
```
APP_URL=http://`oc get route frontend -o jsonpath='{.spec.host}'`
for i in {0..1000}
do
    curl -I $APP_URL
    sleep 1;
done
```

Frontend を呼び出す段階では Payment にアクセスしないので Payment が停止していても UI は問題なく表示されるようです。
では、チェックアウト相当の処理をしたらどうなるでしょうか。

CLIより
```
APP_URL=http://`oc get route frontend -o jsonpath='{.spec.host}'`
for i in {0..1000}
do
    curl -X POST $APP_URL -d 'item%5B%5D=150&item%5B%5D=200&buy=Buy'
    sleep 1;
done
```

結果
![resilience13.png](./resilience13.png)

Catalog を止めたときと同じように Gateway Timeout が発生しました。

最後にシステムを復旧しておきましょう。

CLIより
```
oc scale deployment 　frontend --replicas=2
oc scale deploymentconfig catalog --replicas=2
oc scale deploymentconfig payment --replicas=2
```

#### 4.7.5 MSA トラブルまとめ

ここまで実施してきたトラブルを表にまとめてみました。

|                  | Frontend | Catalog | Payment | E2Eの状態                                                                     | 
| ---------------- | -------- | ------- | ------- | ----------------------------------------------------------------------------- | 
| Frontend が停止  | NG       | OK      | OK      | Frontendへのアクセスは即時エラーが返却される                                  | 
| Catalogが停止    | OK       | NG      | OK      | FrontendへのアクセスはGateway Timeout を起こす                                | 
| Paymentが停止    | OK       | OK      | NG      | Frontend の画面は表示できるが、チェックアウトを行うとGateway Timeout を起こす | 
| XXXXとXXXXが停止 | ~        | ~       | ~       | ~                                                                             | 

MSA における異常時の挙動は、にみなさんのご想像どおりだったでしょうか？ おそらく Gateway TImeout が最も望ましくない挙動っだったのではないかと思います。
この体験では単一サービスの障害だけをシミュレートしましたが、フィールドに置いてはすべての組み合わせのテストを要求されることもあるでしょう。その場合にマイクロサービスが過剰に分割されていると、テストの組合せが爆発がおきることが容易に想像できます。

#### 4.7.6 Service Mesh

マイクロサービスのトラブルが発生するといったいどういうことがおきるのか、ということをすべて洗い出すのはなかなかに困難なミッションとなります。個別言語のライブラリや、 OS に属している TCP/IP ライブラリによっても少しずつ挙動が異なります。
これらをまるっとどうにかしてしまおうというのが、 Servie Mesh という考え方です。Envoy Proxy をサイドカーとして Pod の中に埋め込み、 iptables を駆使して通信を横取りすることでマイクロサービスにおける通信をオーケストレーションしてしまおうというものです。

![resilience14.png](./resilience14.png)

「Service Mesh をいつ導入するべきか」、という問いに明確な答えはありません。
導入の議論をしはじめる目安は、マイクロサービスを扱うビジネス・エンジニアのグループの単位が複数になるタイミングです。

## 5. まとめ

ここまで、サンプルアプリケーションのモノリスアプリケーションをマイクロサービスに分割、・Deploy 変更する方法を体験してきました。
また、 Deploy したマイクロサービスがどういったレジリエンスを持つのか、持たないのかについても体験しました。

ここから先は、「どの単位にマイクロサービスによいのか」、の深堀りが必要になってくるでしょう。その際は顧客側の体験と開発者側の体験、双方が重要になってきます。ビジネスとシステムの規模、複雑度、サービスを提供する組織のありかたなどの考慮が必要になります。

![msa18.png](./msa18.png)

![msa14.png](./msa14.png)

マイクロサービスはビジネスを加速させるためのプラクティスですが、テクノロジーなしではマイクロサービスを正しく操ることはできません。サービスの最適な粒度を見つけるためには不断の努力を要しますが、苦労して分割・サイズダウンしたマイクロサービスが。再びモノリス化してしまわないように、コンテナプラットフォームの機能を活かしながらサービスの複雑さをコントロールしていってください。
