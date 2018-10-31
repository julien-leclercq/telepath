import "phoenix_html"
import '../css/app.sass'
import Elm from '../elm/Main.elm'

let track
let playing = false
const container = document.querySelector("#app")
console.log('elm main', Elm)
const app = Elm.Elm.Main.init({ node: container, flags: "" })
console.log(app)

app.ports.playerCmdOut.subscribe(function (ctrl) {
  const actions = {
    "playTrack": (ctrl) => swapTrack(ctrl.track.route),
    "togglePlay": (_ctrl) => {
      if (track) {
        track.paused ? track.play() : track.pause()
      }
    }
  }

  actions[ctrl.action](ctrl)
  console.log(ctrl)
})

function swapTrack(trackPath) {
  if (track) {
    track.pause()
  }
  track = new Audio(trackPath)
  track.ontimeupdate = (e) => handleTimeChange(e.target)
  track.onpause = (e) => handlePause(e.target)
  track.play()
  playing = true
}

function handleTimeChange(track) {
  app.ports.playerCmdIn.send(track.currentTime)
}

function handlePause(track) {
  track.ended ? app.ports.playerCmdIn.send('end') : app.ports.playerCmdIn.send('pause')
}
