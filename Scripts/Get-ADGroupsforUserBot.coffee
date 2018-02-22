# Description:
#  Gets AD groups for username
#
# Commands:
#   hubot membership <username> - recursively list all groups user is in

# Require the node-powershell module we installed
shell = require('../node_modules/node-powershell/dist/index.js')

module.exports = (robot) ->
    # Capture the user message using regex
  robot.respond /membership (.*)$/i, (msg) ->
      # Set the search term to a varaible
    userName = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'User'
      value: userName
    }
    {
      name:'Channel'
      value: sendRoom
    } ]
    ps.addCommand('./scripts/Get-ADGroupsForUserBot.ps1', params).then(->
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