# node-powershell-coffescripts

![Status](https://img.shields.io/badge/Bots-Rule-brightgreen.svg)

Coffescripts &amp; associated powershell scripts to be used with node-powershell and hubot

This can now be considered deprecated since hubot doesn't apparently work with slack anymore!!!!!!

To see them working you can grab a docker image from https://hub.docker.com/r/twoodling/snowbot/
use the sample config.json file with your added slack api key.  If you have a computer vision api
key for Microsoft Cognitive Services you can add that too and snowbot will describe pictures and
respond in your channel - https://www.microsoft.com/cognitive-services/en-us/computer-vision-api

This is a pair of scripts to demo interaction with services for a hubot - e.g.
Get-ServiceCrobot.coffee - works like the example scripts  
described at https://hodgkins.io/chatops-on-windows-with-hubot-and-powershell
it functions alongside Get-ServiceCrobot.ps1 (see scripts folder).

Get-ServiceCrobot.coffee:

```
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
      
```
