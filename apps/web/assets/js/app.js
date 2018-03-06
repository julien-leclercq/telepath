import "phoenix_html"
import '../css/app.sass'
import Elm from '../elm/Main.elm'

const container = document.querySelector("#app")
const app = Elm.Main.embed(container)
