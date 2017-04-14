# Crystal Signal for Docker armhf/alpine container

[インフィニットループ社](https://www.infiniteloop.co.jp) が 販売している [Crystal Signal Pi](http://crystal-signal.com) の ミドルウェア を、Raspberry Pi に 構築した Docker 環境 で 動作させるための `Dockerfile` および `install.sh` を 提供するプロジェクトです.


## Description
本プロジェクトでは、Raspberry Pi に Docker 環境が構築されているものとして、その Docker 環境 で Crystal Signal Pi の ミドルウェア を コンテナで動作させるための `Dockerfile` および `install.sh` を 提供するもので、ミドルウェア本体はオフィシャルのものを使います.

Crystal Signal Pi は Apache2 と Python2 に 依存しています. Docker を 使うことで、これらの依存関係をコンテナ内に安全に分離することができ、他のアプリケーションで使用している SDK や ミドルウェア、ライブラリ などと、競合しないようにすることができます.


## Requirement
- Crystal Signal Pi
- Raspbian Jessie
- Docker
- pigpio


## Install
以下の手順でインストールします.
1. Raspbian Jessie に Docker を 導入する
2. Raspbian Jessie に pigpio を 導入する
3. Docker イメージ を ビルドして実行する

### 1. Raspbian Jessie に Docker を 導入する
以下のコマンドを実行し
```shell-session
$ curl -sSL https://get.docker.com/ | sh
$ sudo usermod -aG docker pi
$ sudo systemctl enable docker.service
$ sudo systemctl restart docker.service
$ sudo reboot
```

### 2. Raspbian Jessie に pigpio を 導入する
以下のコマンドを実行し、pigpio を インストール および サービスを実行します.
```shell-session
$ sudo apt-get update
$ sudo apt-get install -y --no-install-recommends pigpio
$ sudo systemctl enable pigpiod.service
$ sudo systemctl restart pigpiod.service
```

### 3. Docker イメージ を ビルドして実行する
以下のコマンドを実行し、Docker イメージをビルドし実行します.
`--tag=repository/tag` は 自身のリポジトリとタグ名を設定します.
```shell-session
$ wget https://raw.githubusercontent.com/azriton/crystal-signal-docker-armhf-alpine/master/Dockerfile
$ docker build --force-rm --no-cache --tag=repository/tag .
$ docker run -d -p 80:80 --net host --device /dev/gpiomem --name crystal-signal-pi repository/tag
```


## Licence
This project is released under the [MIT](https://github.com/azriton/slack-oauth-helper/blob/master/LICENSE) License.

※ Crystal Signal Pi の ミドルウェア 本体 の ライセンス は [infiniteloop-inc/crystal-signal](https://github.com/infiniteloop-inc/crystal-signal) を 参照ください.
