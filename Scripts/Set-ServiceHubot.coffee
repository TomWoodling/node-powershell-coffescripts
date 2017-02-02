# Description:
#   Testing Node-Powershell
#
# Commands:
#   hubot set service <name> <status> - changes service <name> to <status>

# Require the node-powershell module we installed
shell = require('../node_modules/node-powershell/dist/index.js')

module.exports = (robot) ->
    # Capture the user message using
  robot.respond /set service (.*)$/i, (msg) ->
      # Set the search term to a varaible
    handOff = msg.match[0]
    splits = handOff.split(' ')
    serNa = splits[3]
    serSta = splits[4]   
    sendRoom = msg.message.room

    ps = new shell(
      executionPolicy: 'Bypass'
      debugMsg: true)
    params = [ {
      name: 'Serv'
      value: serNa
    }
    {
      name:'Status'
      value: serSta
    } ]
    ps.addCommand('./scripts/Set-ServiceHubot.ps1', params).then(->
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