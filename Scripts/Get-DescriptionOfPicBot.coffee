# Description:
#   Makes connection to Microsoft Cognitive Services to get a description
#
# Commands:
#   hubot describe <URL> - tries to describe the picture at the URL given

# Require the edge module we installed
shell = require("node-powershell")

module.exports = (robot) ->
    # Capture the user message using a regex
  robot.respond /Describe (.*)$/i, (msg) ->
    # Set the search term to a varaible
    picSend = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'Pic'
      value: picSend
    } ]
    ps.addCommand('./scripts/Get-DescriptionOfPicBot.ps1', params).then(->
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