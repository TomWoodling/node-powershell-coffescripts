# Description:
#   Test for hubot auth roles
#
# Commands:
#   hubot test roles - tells you if you are in particular roles

authorizedRoles = [
    'friend'
    ]



module.exports = (robot) ->
    # Capture the user message using
  robot.respond /(testing roles|test roles)/i, (msg) ->
    user = robot.brain.userForId(msg.envelope.user['id'])
    if (r for r in robot.auth.userRoles(user) when r in authorizedRoles).length > 0
      # Set the search term to a varaible
      sendUser = msg.message.user.name
      msg.send "Hi #{sendUser} - your roles are valid #{authorizedRoles}"

    else
      sendUser = msg.message.user.name
      console.log sendUser
      msg.send "Sorry #{sendUser} you are not authorised to make this request - you need one of the following roles: #{authorizedRoles}"