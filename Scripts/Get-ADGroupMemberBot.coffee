# Description:
#   Gets members of AD groups.
#
# Commands:
#   hubot ADGroup <group name> - recursively list all members of an AD group.

# Require the node-powershell module we installed
shell = require('../node_modules/node-powershell/dist/index.js')

module.exports = (robot) ->
    # Capture the user message using regex
  robot.respond /ADGroup (.*)$/i, (msg) ->
      # Set the search term to a varaible
    adGrp = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'Group'
      value: adGrp
    }
    {
      name:'Channel'
      value: sendRoom
    } ]
    ps.addCommand('./scripts/Get-ADGroupMembsBot.ps1', params).then(->
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