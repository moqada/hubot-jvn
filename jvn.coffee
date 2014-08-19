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
CRON_TIME = '00 15 * * * *'
xml2js = require 'xml2js'
cron = require 'cron'

module.exports = (robot) ->

  robot.respond /jvn( (\d+))?/i, (msg) ->
    getItems (err, items) ->
      if err and process.env.HUBOT_JVN_ERROR_MESSAGE
        msg.send process.env.HUBOT_JVN_ERROR_MESSAGE
      else
        count = msg.match[2] or 5
        res_str = process.env.HUBOT_JVN_REPLY_MESSAGE or ''
        for item in items[...count]
          res_str += "#{item.title} #{item.link[0]}\n"
        msg.send res_str

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

  new cron.CronJob process.env.HUBOT_JVN_CRON_TIME or CRON_TIME, ->
    getItems (err, items) ->
      res_str = ''
      if items and items.length > 0
        modified = robot.brain.get BRAIN_KEY
        modified = modified and new Date modified
        for item in items
          date = new Date(item['dcterms:modified'][0])
          if not modified or date > modified
            res_str += "#{item.title} #{item.link[0]}\n"
        if res_str
          res_str = (process.env.HUBOT_JVN_CRON_MESSAGE or '') + res_str
          robot.messageRoom process.env.HUBOT_JVN_ROOM, res_str

        robot.brain.set BRAIN_KEY, new Date().toString()
        robot.brain.save()
  , null, true
