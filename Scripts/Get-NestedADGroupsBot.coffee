# Description:
#   Gets AD groups nested under another.
#
# Commands:
#   hubot get nested groups in <group name> - gets nested groups

# Require the edge module we installed
shell = require("node-powershell")

module.exports = (robot) ->
    # Capture the user message using a regex
  robot.respond /get nested groups in (.*)$/i, (msg) ->
    # Set the search term to a varaible
    grpName = msg.match[1]
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'group'
      value: grpName
    }
    {
      name: 'channel'
      value: sendRoom
    } ]
    ps.addCommand('./scripts/Get-NestedADGroupsBot.ps1', params).then(->
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