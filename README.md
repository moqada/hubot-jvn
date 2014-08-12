# hubot-jvn

JVN(https://jvn.jp/) の脆弱性情報を返す hubot-scripts。

CronJob で定期的に RSS を取得、最新情報が存在する場合は投稿する。

## Configuration

**HUBOT_JVN_ROOM**

CronJob から定期的にメッセージを投稿するルーム (<JID>@conf.hipchat.com)

## Installation

1. package.json の dependencies に hubot-jvn を追加
2. "hubot-jvn" を external-scripts.json に追加
3. npm install
4. Reboot Hubot

## Commands

```
hubot jvn <count> - 最新の記事を <count> 分取得する。<count> を指定しない場合は最新5つだけ取得する。
```
