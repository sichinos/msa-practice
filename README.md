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
### 2-3. CodeReadyWorkspaces ログイン

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

コンテナであることを確認するためにいくつかのコマンドを実行してみましょう。

```
cat /etc/redhat-release
```
出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ cat /etc/redhat-release 
Red Hat Enterprise Linux release 8.5 (Ootpa)
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ ls /
bin   dev  home  lib64       lost+found  mnt  proc      public-certs  run   srv  tmp  var
boot  etc  lib   lombok.jar  media       opt  projects  root          sbin  sys  usr  workspace_logs
```

```
ls /
```
出力
```
[jboss@workspacefj04s6sm57jsfjaz quarkus-quickstarts]$ ls /
bin   dev  home  lib64       lost+found  mnt  proc      public-certs  run   srv  tmp  var
boot  etc  lib   lombok.jar  media       opt  projects  root          sbin  sys  usr  workspace_logs
```

```
top
```
出力
```
top - 06:56:01 up 28 days, 21:16,  0 users,  load average: 0.13, 0.24, 0.40
Tasks:   4 total,   1 running,   3 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.2 us,  3.3 sy,  0.0 ni, 90.3 id,  0.0 wa,  0.8 hi,  0.4 si,  0.0 st
MiB Mem :  15728.8 total,    648.0 free,   6550.2 used,   8530.6 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   8800.2 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                                                          
      1 jboss     20   0   23056   1456   1268 S   0.0   0.0   0:00.05 tail                                                                             
     32 jboss     20   0   11924   2780   2520 S   0.0   0.0   0:00.00 bash                                                                             
     38 jboss     20   0   39020  23408   3160 S   0.0   0.1   0:00.15 bash                                                                             
     91 jboss     20   0   56328   4068   3444 R   0.0   0.0   0:00.00 top  
```

top画面は q を押して抜けてください。
PID 1のプロセスは通常のマシンであれば init になるはずですが tail になっています。コンテナを起動し続けるためには






