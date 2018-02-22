# Description:
#   Shows who reports (directly and indirectly) to a specified user.
#
# Commands:
#   hubot reports to <user> - enumerate the direct & indirect reports for the user (eg a.username)

# Require the node-powershell module we installed
shell = require('../node_modules/node-powershell/dist/index.js')

module.exports = (robot) ->
    # Capture the user message using regex
  robot.respond /reports to (.*)$/i, (msg) ->
      # Set the search term to a varaible
    repUsr = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'User'
      value: repUsr
    }
    {
      name:'Channel'
      value: sendRoom
    } ]
    ps.addCommand('./scripts/Get-ADDirectRepsBot.ps1', params).then(->
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