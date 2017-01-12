# openvpn-client-tools
OpenVPN のクライアント証明書を発行するスクリプトなど

## 証明書を発行する
```
$ ./create.sh username
```

ルート証明書のパスフレーズを訊かれるので入力すると、 `username.zip` が生成される。

## 証明書を失効させる
スクリプトを書くほどではないので手でやる

```
$ cd /usr/local/EasyRSA/
$ ./easyrsa revoke username  // 証明書を失効させる
$ ./easyrsa gen-crl  // crl.pem を更新する
$ sudo service openvpn restart  // OpenVPN サーバを再起動して接続中クライアントに再接続させる
```

## OpenVPN サーバのセットアップ
OpenVPN サーバの設定は概ね以下の記事の通りにやった。

[Amazon EC2とOpenVPNでサーバ-多拠点クライアント間通信をセキュアに行う ｜ Developers.IO](http://dev.classmethod.jp/cloud/aws/ec2-ssl-vpn-use-openvpn/)

### その他変更した点
- ポートを 11194 に変更 (デフォルトは 1194)
- `push "route 10.0.0.0 255.255.255.0"` を追加
  - VPC のサブネットに合わせた
- `crl-verify  crl.pem` を追加
- `crl.pem` を毎回設置するの手間なのでシンボリックリンク貼って済ませた
- 通信が激重だったので `mssfix 1200` を追加したら速くなった
