import './main.output.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
//import 'regenerator-runtime'

import * as sdk from 'fission-sdk';

console.log('sdk', sdk)


sdk.initialise().then(async ({ scenario, state }) => {
  //const { authenticated, newUser, throughLobby, username } = state
  console.log('sdk', state)

  const username = await sdk.authenticatedUsername()


  const app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
      user: username,
    }
  });

  app.ports.login.subscribe(sdk.redirectToLobby)

  app.ports.create.subscribe(async () => {
    try {
      console.log("Creating deployment")
      const newDeployment = await sdk.apps.create()
      app.ports.createDeployment.send(newDeployment)
    } catch (err) {
      console.log("Error createing deployment", err)
      app.ports.createDeployment.send({err: err.toString()})
    }

  })

  app.ports.delete.subscribe( async ({key, subdomain}) => {
    try {
      await sdk.apps.deleteByURL(subdomain)
      app.ports.deleteDeployment.send(key)
    } catch (err) {
      // error case
      console.log("error delete deployment", err)
      app.ports.deleteDeployment.send({key: key, err: err.toString()})
    }
    
  })

  app.ports.fetchDeployments.subscribe(async function () {
    try {
      app.ports.recieveDeployments.send(await sdk.apps.index())
    } catch (err) {
      app.ports.recieveDeployments.send(err.toString())
    }
  })
})
  .catch(err => {
    console.log("Something went wrong setting up the app", err)
  })



// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
