# Description:
#   Basic interaction with the Cat API
#
# Commands:
#   hubot cat me - get a cat pic
#   hubot cat bomb <number> - get many pics (up to 5)

# Require the edge module we installed
shell = require("node-powershell")

module.exports = (robot) ->
    # Capture the user message using a regex
  robot.respond /cat( me)?$/i, (msg) ->
    # Set the search term to a varaible
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    ps.addCommand('./scripts/Get-CatPicBot.ps1').then(->
      ps.invoke()
    ).then((output) ->
      console.log output
      result = JSON.parse output
      msg.send result.output
      ps.dispose()
    ).catch (err) ->
      console.log err
      msg.send err
      ps.dispose()


    # Capture the user message using a regex
  robot.respond /cat bomb( (\d+))?/i, (msg) ->
    # Set the search term to a varaible
    count = msg.match[1] || 5
    count = 5 if count > 5
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'limit'
      value: count
    } ]
    ps.addCommand('./scripts/Get-CatPicBot.ps1', params).then(->
      ps.invoke()
    ).then((output) ->
      console.log output
      result = JSON.parse output
      msg.send result.output
      ps.dispose()
    ).catch (err) ->
      console.log err
      msg.send err
      ps.dispose()