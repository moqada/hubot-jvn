# Description:
#   JVN(https://jvn.jp/) の脆弱性情報を返す。
#   crontab で定期的に RSS を取得、最新情報が存在する場合は投稿する。
#
# Dependencies:
#   "cron": "1.0.4"
#   "xml2js": "0.4.4"
#
# Configuration:
#   HUBOT_JVN_ROOM - crontab から定期的にメッセージを投稿するルーム
#
# Commands:
#   hubot jvn <count> - 最新の記事を <count> 分取得する。<count> を指定しない場合は最新5つだけ取得する。
#
# Author
#   moqada

BRAIN_KEY = 'jvn::modified'
FEED_URL = 'https://jvn.jp/rss/jvn.rdf'
xml2js = require 'xml2js'
cron = require 'cron'

module.exports = (robot) ->

  robot.respond /jvn( (\d+))?/i, (msg) ->
    getItems (err, items) ->
      if err
        msg.send 'なんかRSS取得できんかったっぽい'
      else
        count = msg.match[2] | 5
        res_str = 'ほい、最新の脆弱性情報やで:\n\n'
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

  new cron.CronJob '15 * * * *', ->
    getItems (err, items) ->
      res_str = ''
      if items and items.length > 0
        modified = robot.brain.get BRAIN_KEY
        for item in items
          date = new Date(item['dcterms:modified'][0])
          if not modified or date > modified
            res_str += "#{item.title} #{item.link[0]}\n"
        if res_str
          robot.messageRoom process.env.HUBOT_JVN_ROOM, "新しい脆弱性情報、出てたで:\n\n#{res_str}"

        robot.brain.set BRAIN_KEY, new Date()
        robot.brain.save()
  , null, true
