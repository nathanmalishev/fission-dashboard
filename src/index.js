import './main.output.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
//import 'regenerator-runtime'

import * as sdk from 'fission-sdk';

function log(...data){
  if (process.env.NODE_ENV == "development") {
    console.log(...data)
  }
}


sdk.initialise().then(async ({ scenario, state }) => {
  log('sdk', state)

  const username = await sdk.authenticatedUsername()

  let fs = { exists : () => false }
  let appData 
  if (username) {
    fs = state.fs
    appData = fs.appPath.private("fissionDeployments.json")
  }

  const app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
      user: username,
    }
  });

  app.ports.login.subscribe(sdk.redirectToLobby)

  // Saving deployments to localState
  app.ports.save.subscribe( async (data) => {
    log("recieve", data)
    try{
      //await fs.write(appData, data)
      await transaction(
        fs, fs.write, appData, data
      )
    } catch(err) {
      log("could not write nickname")
    }
    log("Saved nickname")
  })

  app.ports.create.subscribe(async () => {
    try {
      log("Creating deployment")
      const newDeployment = await sdk.apps.create()
      app.ports.createDeployment.send(newDeployment)
    } catch (err) {
      log("Error creating deployment", err)
      app.ports.createDeployment.send({err: err.toString()})
    }

  })


  app.ports.delete.subscribe( async ({key, subdomain}) => {
    try {
      await sdk.apps.deleteByURL(subdomain)
      app.ports.deleteDeployment.send(key)
    } catch (err) {
      log("Error deleting deployment", err)
      app.ports.deleteDeployment.send({key: key, err: err.toString()})
    }
    
  })

  // design a system for working with API calls & local fission stuff
  // Fetching a deployment -- what ever the API says is king
  // -> fetch from local state
  // -> fetch from API
  // -> any matching keys from local state copy `nicknames` to work state
  // -> rewrite changes (removing old keys etc)
  app.ports.fetchDeployments.subscribe(async function () {
    try {

      const remoteData = await sdk.apps.index()

      if (await fs.exists(appData)) {
        //cache exists
        const localData = await fs.cat(appData)
        const mergedData = merge(localData, remoteData)
        app.ports.recieveDeployments.send(mergedData)
        return
      } 
        log('Local data not found', remoteData)
        // still need to run merge as it's the format app is expecting
        const mergedData = merge({}, remoteData)
        app.ports.recieveDeployments.send(mergedData)

    } catch (err) {
      log("Error fetching deployments", err)
      app.ports.recieveDeployments.send({err: err.toString()})
    }
  })
})
  .catch(err => {
    log("Something went wrong setting up the app", err)
  })


/**
 * Merges the local fs state & the remote state
 * The remote state takes precendence
 *
 * @param local The local state  // looks like {key: {subdomain, nickName}}
 * @param remote The remote state // looks like {key: [subdomain]}
 */

function merge(local, remote) {
  
  let combinedObj = {}
  if (remote) {
    const keys = Object.keys(remote)
    keys.forEach((key, index) => {
      
      const subdomain = remote[key][0]
      const hackKey = "key_".concat( subdomain )

      if (local[key]) {
        combinedObj[key] = { subdomain: subdomain, nickName: local[key].nickName }
      } else if (local[hackKey]) {
        // !01 - This is a hack caused by the API returning only the subdomain when creating a new deployment
        // Because of this we create temp key of any newly created deployments like so "key_{subdomain}"
        // here we are checking for them && building their object accordingly
        combinedObj[key] = { subdomain: subdomain, nickName: local[hackKey].nickName }
      } else {
        combinedObj[key] = { subdomain: subdomain, nickName: null}
      }
    })
  }
  return combinedObj

  }


// TRANSACTIONS - enfore concurrency

const transactionQueue = []


/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param fs The filesystem to run
 * @param method The arguments for the given filesystem 
 * @param args The arguments for the given filesystem method
 */
async function transaction (fs, promise, ...args) {
  transactionQueue.push( {promise, args: args} )
  while (transactionQueue.length) {
    await Promise.all( transactionQueue.splice(0, 1).map(f => f.promise.apply(fs, f.args)) )
  }
}

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
