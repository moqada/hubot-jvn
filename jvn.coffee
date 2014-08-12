# Description:
#   JVN(https://jvn.jp/) の脆弱性情報を返す。
#   crontab で定期的に RSS を取得、最新情報が存在する場合は投稿する。
#
# Dependencies:
#   "cron": "1.0.4"
#   "xml2js": "0.4.4"
#
# Configuration:
#   HUBOT_JVN_ROOM - CronJob から定期的にメッセージを投稿するルーム (<JID>@conf.hipchat.com)
#   HUBOT_JVN_CRON_TIME - CronJob の実行時間指定
#   HUBOT_JVN_ERROR_MESSAGE - エラー発生時のメッセージ
#   HUBOT_JVN_REPLY_MESSAGE - jvn コマンドによる返信時のメッセージ
#   HUBOT_JVN_CRON_MESSAGE - CronJob による投稿時のメッセージ
#
# Commands:
#   hubot jvn <count> - 最新の記事を <count> 分取得する。<count> を指定しない場合は最新5つだけ取得する。
#
# Author:
#   moqada

BRAIN_KEY = 'jvn::modified'
FEED_URL = 'https://jvn.jp/rss/jvn.rdf'
CRON_TIME = process.env.HUBOT_JVN_CRON_TIME or '00 15 * * * *'
CRON_MESSAGE = process.env.HUBOT_JVN_CRON_MESSAGE or ''
ERROR_MESSAGE = process.env.HUBOT_JVN_ERROR_MESSAGE or ''
REPLY_MESSAGE = process.env.HUBOT_JVN_REPLY_MESSAGE or ''
xml2js = require 'xml2js'
cron = require 'cron'

module.exports = (robot) ->

  getItems = (callback) ->
    robot.http(FEED_URL).get() (err, res, body) ->
      if res.statusCode is not 200
        callback {statusCode: res.statusCode}
      else
        (new xml2js.Parser()).parseString body, (err, json) ->
          if err
            callback err
          else
            callback null, json['rdf:RDF'].item

  createMessage = (items, prefix) ->
    resStr = ("#{i.title} #{i.link[0]}" for i in items).join('\n')
    if resStr and prefix
      resStr = "#{prefix}\n#{resStr}"
    resStr

  robot.respond /jvn( (\d+))?/i, (msg) ->
    getItems (err, items) ->
      if err and ERROR_MESSAGE
        msg.send ERROR_MESSAGE
      else
        count = msg.match[2] or 5
        msg.send createMessage items[...count], REPLY_MESSAGE

  new cron.CronJob CRON_TIME, ->
    getItems (err, items) ->
      if items and items.length > 0
        modified = robot.brain.get BRAIN_KEY
        modified = modified and new Date modified
        items = items.filter (i) ->
          date = new Date(i['dcterms:modified'][0])
          not modified or date > modified
        resStr = createMessage items, CRON_MESSAGE
        resStr and robot.messageRoom process.env.HUBOT_JVN_ROOM, resStr

        robot.brain.set BRAIN_KEY, new Date().toString()
        robot.brain.save()
  , null, true
