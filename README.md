# hubot-jvn

[![Greenkeeper badge](https://badges.greenkeeper.io/moqada/hubot-jvn.svg)](https://greenkeeper.io/)

JVN(https://jvn.jp/) の脆弱性情報を返す hubot-scripts。

CronJob で定期的に RSS を取得、最新情報が存在する場合は投稿する。

## Configuration

**HUBOT_JVN_ROOM**

CronJob から定期的にメッセージを投稿するルーム (<JID>@conf.hipchat.com)

**HUBOT_JVN_CRON_TIME**

CronJob の実行時間指定

**HUBOT_JVN_ERROR_MESSAGE**

エラー発生時のメッセージ

**HUBOT_JVN_REPLY_MESSAGE**

jvn コマンドによる返信時のメッセージ

**HUBOT_JVN_CRON_MESSAGE**

CronJob による投稿時のメッセージ

ex.

```
@all
＿人人人人人人人人＿
＞　新しい脆弱性　＜
￣Y^Y^Y^Y^Y^Y^Y￣
```

## Installation

1. package.json の dependencies に hubot-jvn を追加
2. "hubot-jvn" を external-scripts.json に追加
3. npm install
4. Reboot Hubot

## Commands

```
hubot jvn - 最新の記事を5つ取得する
hubot jvn <count> - 最新の記事を <count> 分取得する
```
