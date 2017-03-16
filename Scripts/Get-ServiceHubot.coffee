# Description:
#   Testing Node-Powershell
#
# Commands:
#   hubot get service <name> - returns service state details for <name>

# Require Node-Powershell
shell = require('../node_modules/node-powershell/dist/index.js')





module.exports = (robot) ->
    # Capture the user message using a regex
  robot.respond /get service (.*)$/i, (msg) ->
      # Set the search term to a varaible
    serNa = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'Name'
      value: serNa
    } ]
    ps.addCommand('./scripts/Get-ServiceHubot.ps1', params).then(->
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