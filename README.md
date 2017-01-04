# node-powershell-coffescripts
Coffescripts &amp; associated powershell scripts to be used with node-powershell and hubot

This is a pair of scripts to demo interaction with services for a hubot - e.g.
Get-ServiceCrobot.coffee - works like the example scripts for edge-ps 
described at (https://hodgkins.io/chatops-on-windows-with-hubot-and-powershell)
it functions alongside Get-ServiceCrobot.ps1 (see scripts folder).

Get-ServiceCrobot.coffee:

```shell = require('../node_modules/node-powershell/dist/index.js')
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
    )```  
