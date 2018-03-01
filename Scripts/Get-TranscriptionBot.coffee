# Description:
#   Transcribes a phrase to the specified language
#
# Commands:
#   hubot transcribe <phrase> to <language> - tries to transcribe <phrase>

# Require the edge module we installed
shell = require("node-powershell")

module.exports = (robot) ->
    # Capture the user message using a regex
  robot.respond /transcribe (.*) to (.*)$/i, (msg) ->
    # Set the search term to a varaible
    newText = msg.match[1]
    toLang = msg.match[2]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'phrase'
      value: newText
    }
    {
      name: 'language'
      value: toLang
    }
    {
      name: 'channel'
      value: sendRoom
    }     ]
    ps.addCommand('./scripts/Get-TranscriptionBot.ps1', params).then(->
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