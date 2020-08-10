import './main.output.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import 'regenerator-runtime'

import * as sdk from 'fission-sdk';


//(async () => {
  console.log('sdk', sdk)
  sdk.isAuthenticated().then (props => {
    console.log('authed', props)

    if (props.authenticated) {

    } else {
      sdk.redirectToLobby()
    }
  })

//const { scenario, state } = await sdk.initialise()

//if (scenario.authCancelled) {
  //// User was redirected to lobby,
  //// but cancelled the authorisation.

//} else if (scenario.authSucceeded || scenario.continuum) {
  //// State:
  //// state.authenticated    -  Will always be `true` in these scenarios
  //// state.newUser          -  If the user is new to Fission
  //// state.throughLobby     -  If the user authenticated through the lobby, or just came back.
  //// state.username         -  The user's username.
  ////
  //// ☞ We can now interact with our file system (more on that later)
  //state.fs

//} else if (scenario.notAuthenticated) {
  //sdk.redirectToLobby()

//}
//})();




Elm.Main.init({
  node: document.getElementById('root')
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
