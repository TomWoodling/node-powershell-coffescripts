# Description:
#   When Hubot hears "thanks' it says "You're welcome!"
#
# Commands:
#   Thanks Hubot - express your gratitude

pick_one = (array) ->
  i = Math.floor(Math.random() * array.length)
  array[i]

phrases = [
  "You're welcome",
  "No problem",
  "No prob",
  "np",
  "Sure thing",
  "Anytime, human",
  "Anytime",
  "Anything for you",
  "De nada, amigo",
  "Don't worry about it",
  "My pleasure"
]

punc = [
  "", "!", ".", "!!"
]

emoji = ["", "", ":muscle:", ":smile:", ":+1:", ":ok_hand:", ":punch:",
      ":bowtie:", ":smiley:", ":joy_cat:", ":heart:", ":robot_face:",
      ":heartbeat:", ":sparkles:", ":star:", ":star2:", ":smirk:",
      ":grinning:", ":smiley_cat:", ":sunflower:", ":tulip:",
      ":hibiscus:", ":cherry_blossom:", ":ghost:", ":eyes:"]

youre_welcome = () ->
  [pick_one(phrases), pick_one(punc), " ", pick_one(emoji)].join('')

module.exports = (robot) ->
  robot.hear ///(thx|thanks|thank\s+you),?\s+#{robot.name}///i, (msg) ->
    msg.send youre_welcome()

  robot.respond /(thx|thanks|thank you)/i, (msg) ->
    msg.send youre_welcome()