# setup device for presentation
device = new Framer.DeviceView();
Framer.Extras.Hints.disable()

device.setupContext()
device.deviceType = "apple-iphone-6s-space-gray"
device.contentScale = 1

# Load Modules
CameraLayer = require "CameraLayer"
makeGradientModule = require("makeGradient")
{ Chat } = require 'chat'

# Create a layer
camera = new CameraLayer

camera.width = Screen.width
camera.height = Screen.height

# Start accessing to the camera
camera.start()

#Create our gradients
topGrad = new Layer
  x: 0
  y: 0
  width: Screen.width
  height: 100
  opacity: 0.5
  backgroundColor: "rgba(0,0,0,0)"
makeGradientModule.linear( topGrad, ["rgba(0,0,0,0)", "rgba(0,0,0,1)"], "0deg" )

bottomGrad = new Layer
  x: 0
  y: Screen.height - 200
  width: Screen.width
  height: 200
  opacity: 0.8
  backgroundColor: "rgba(0,0,0,0)"
makeGradientModule.linear( bottomGrad, ["rgba(0,0,0,0)", "rgba(0,0,0,1)"], "180deg" )

#Create our emoji
emojiGroup = "1"
emojis =
  sad: "😭"
  happy: "😀"
  angry: "😡"
  surprised: "😳"
  fear: "😱"
  disgusted: "🤢"
emojiSource = "framer/images/emoji_group_0" + emojiGroup + "/"
emojiOverlay = new Layer
    x: 0
    y: 0
    width: 350
    height: 350
    borderRadius: 350
    opacity: 1
    image: emojiSource + "happy.png"

emojiContent = new TextLayer
    fontSize: 0
    text: emojis.happy
    fontFamily: "-apple-system"
    parent: emojiOverlay

emojiGroupSelection = new Layer
    width: screen.width
    height: 100
    x: 0
    y: 0
    backgroundColor: null

emojiGroupSelection.onClick ->
  this.animate
    height: 400
    options:
      curve: Spring(damping: 0.6)
      time: 0.25

  topGrad.animate
    height: 400
    options:
      curve: Spring(damping: 0.6)
      time: 0.25

  if this.height = 400
    this.animate
      height: 100
      options:
        curve: Spring(damping: 0.6)
        time: 0.25

    topGrad.animate
      height: 100
      options:
        curve: Spring(damping: 0.6)
        time: 0.25

#emojiGroupSelectionText = new TextLayer
#  width: screen.Width
#  fontSize: 32
#  text: "Mood: Animal"
#  fontFamily: "-apple-system"
#  textAlign: Align.center


# Start getting emotions
ctrack = new clm.tracker {useWebGL : false}
ctrack.init pModel
ctrack.start camera.player

ec = new emotionClassifier()
emotionData = ec.getBlank()
ec.init emotionModel

# Variables
pageCount = 8
gutter = 0
userToAnimate = null
parent = null
user = []
pages = []
userNames = ['','Dr. Petrovic','Maria','Andy','Fabian','Kamila','Max','Phillip','test1','test2']
count = 0
curPage = null
er = null
nosePos = null
chatmode = false

getPosition = ->
  setInterval ->
    positions = ctrack.getCurrentPosition()
    if !chatmode
      if positions
        nosePos = positions[27]
        emojiOverlay.x = nosePos[0]*2-(emojiOverlay.width/2)
        emojiOverlay.y = nosePos[1]*2+(emojiOverlay.height/6)
  , 100
  true
getPosition()

getEmotion = ->
  setInterval ->
    cp = ctrack.getCurrentParameters()
    er = ec.meanPredict cp

    emotionObj =
      value: 0

    if er

      for i in er
        if i.value > 0.4 and ( emotionObj.value < i.value )
          emotionObj = i
          lol = emotionObj.emotion
          console.log lol
          emojiContent.text = emojis[lol]
          emojiOverlay.image = emojiSource + emotionObj.emotion + ".png"
    if !cp
      emojiOverlay.image = "framer/images/noface.png"
  , 100
  true
getEmotion()

# Create PageComponent
pageScroller = new PageComponent
  x: 0
  y: Screen.height - 500
  width: Screen.width
  height: Screen.height
  scrollVertical: false

# Loop to create pages
mychats = for index in [1...pageCount]
  count = count + 1

  page = new Layer
    width: 700
    height: 700
    x: 200 * index
    backgroundColor: "rgba(255,255,255,0.5)"
    parent: pageScroller.content
    scale: 0.2
    borderRadius: 400
    name: count

  pages.push(page)

  chat = new Chat
    fontSize: 24
    lineHeight: 36
    borderRadius: 40
    padding: 30
    bubbleColor:
      right: '#00A8FF'
      left: 'white'
    bubbleText:
      right: 'white'
      left: '#434E55'
    data: [
      {
        author: 2
        message: 'Hey how are you?'
      }
    ]
    users: [
      {
        id: 2
        name: userNames[count]
        avatar: 'framer/images/people/' + count + '.jpg'
      }
      {
        id: 1
        name: 'me'
        avatar: 'framer/images/people/' + count + '.jpg'
      }
    ]

  chat.wrapper.parent = page

  page.clip = true

  page.curPos = 200 * index
  page.id = index

  header = new Layer
    x: 0
    y: 0
    width: page.width
    height: 160
    backgroundColor: 'white'
    color: '#3B505E'
    html: userNames[count] + '<br><span style="font-size: 24px; color: #687E8C; ">Last online: 13:37</span>'
    parent: page
    style:
      "padding": "1.5em 1em 0 5.5em"
      "font-size": "32px"

  user = new Layer
    x: 0
    y: 0
    width: 700
    height: 700
    borderRadius: 350
    borderWidth: 20
    borderColor: "white"
    image: "framer/images/people/" + index + ".jpg"
    parent: page
    name: "user" + page.id
    id: page.idea

  close = new Layer
    parent: page
    image: "framer/images/icons/close.png"
    width: 80
    height: 80
    x: page.width - 110
    y: 30
    opacity: 0.5

  page.onClick ->

    if not chatmode

      chatmode = true
      pageScroller.snapToPage(this)
      parent = this
      curPage = this.name

      userToAnimate = this.children[2]

      userToAnimate.animate
        width: 120
        height: 120
        x: 20
        y: 20
        borderWidth: 0
        options:
          curve: Spring(damping: 0.7)
          time: 0.3

      this.animate
        scale: 1
        height: Screen.height - 60
        borderRadius: 20
        x: this.curPos
        y: 0
        options:
          curve: Spring(damping: 0.8)
          time: 0.3

      this.bringToFront()

      emojiOverlay.bringToFront()
      emojiOverlay.animate
        x: -70
        y: 1050
        scale: 0.3
        options:
          curve: Spring(damping: 0.7)
          time: 0.3

      camera.blur = 20

      pageScroller.scrollHorizontal = false
      pageScroller.animate
        y: 30

      Utils.delay 0.1, ->
        refit()

  close.onClick ->

    if chatmode

      emojiOverlay.animate
        scale: 1
        x: nosePos[0]*2-(emojiOverlay.width/2)
        y: nosePos[1]*2+(emojiOverlay.height/6)
        options:
          curve: Spring(damping: 0.6)
          time: 0.25

      pageScroller.animate
        y: Screen.height - 500
        x: 0
        z: 0
      pageScroller.scrollHorizontal = true

      camera.blur = 0

      parent.animate
        borderRadius: 400
        scale: 0.2
        x: this.curPos
        height: 700
        options:
          curve: Spring(damping: 0.75)
          time: 0.35

      userToAnimate.animate
        width: 700
        height: 700
        borderWidth: 20
        x: 0
        y: 0
        options:
          curve: Spring(damping: 0.6)
          time: 0.3

      Utils.delay 0.1, ->
        chatmode = false
        refitBack()

  chat

refit = ->
  p = pages.slice(0, curPage-1 )
  f = pages.slice(curPage, pageCount )

  p.forEach((layer) ->
    layer.x = layer.x - 260
  )
  f.forEach((layer) ->
    layer.x = layer.x + 260
  )

refitBack = ->
  p = pages.slice(0, curPage-1 )
  f = pages.slice(curPage, pageCount )

  p.forEach((layer) ->
    layer.x = layer.x + 260
  )
  f.forEach((layer) ->
    layer.x = layer.x - 260
  )

emojiOverlay.onClick ->
  if chatmode = true

    newComment =
    	author: 1
    	message: emojiContent.text

    mychats[(curPage-1)].renderComment newComment, 'right'
