
import '../css/app.sass'
import "phoenix_html"
import bulma from 'bulma/bulma.sass';
import Elm from '../elm/Main.elm'

const container = document.querySelector("#app")
const app = Elm.Main.embed(container)
