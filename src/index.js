import './main.output.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import * as wn from 'webnative';

function log(...data){
  if (process.env.NODE_ENV == "development") {
    console.log(...data)
  }
}

/* render elm app */

const elmApp = Elm.Main.init({
  node: document.getElementById('root')
});

const PERMISSIONS = {
    app: {
      name: "FissionDeployments",
      creator: "Nathan Malishev"
    }
}

/* try sdk magic */
wn
  .initialise({ permissions: PERMISSIONS })
  .catch(temporaryAlphaCodeHandler)
  .then(async state => {
    const { authenticated, newUser, throughLobby, username } = state
  log('state', state)

  let fs = state.fs
  const elmAppData = fs.appPath(["fissionDeployments.json"])


  //
  // Login (API)
  // 
  elmApp.ports.login.subscribe(() => wn.redirectToLobby(prerequisites))

  //
  // Saving nickname state (asking fs)
  // 
  elmApp.ports.save.subscribe( async (data) => {
    log("recieve", data)
    try{
      //await transaction(
        //fs, fs.write, elmAppData, data
      //)
      await fs.write(elmAppData, data)
    } catch(err) {
      log("could not write nickname")
    }
    log("Saved nickname")
  })

  //
  // Creating deployment (asking API)
  // 
  elmApp.ports.create.subscribe(async () => {
    try {
      log("Creating deployment")
      const newDeployment = await wn.apps.create()
      elmApp.ports.createDeployment.send(newDeployment)
    } catch (err) {
      log("Error creating deployment", err)
      elmApp.ports.createDeployment.send({err: err.toString()})
    }

  })


  //
  // Deleting deployment (asking API)
  //
  elmApp.ports.delete.subscribe( async ({key, subdomain}) => {
    try {
      await wn.apps.deleteByURL(subdomain)
      elmApp.ports.deleteDeployment.send(key)
    } catch (err) {
      log("Error deleting deployment", err)
      elmApp.ports.deleteDeployment.send({key: key, err: err.toString()})
    }
    
  })

  // Fetching Deployment (API && fs)
  //
  // Fetching a deployment stemps -- API takes precendence
  // -> fetch from local state
  // -> fetch from API
  // -> any matching keys from local state copy `nicknames` to merged state
  // -> any think that isn't in the remote state gets deleted
  elmApp.ports.fetchDeployments.subscribe(async function () {
    log('Fetching deployments')
    try {

      const remoteData = await wn.apps.index()

      if (await fs.exists(elmAppData)) {
        //cache exists
        const localData = await fs.cat(elmAppData)
        const mergedData = merge(localData, remoteData)
        elmApp.ports.recieveDeployments.send(mergedData)
        return
      } 
        log('Local data not found', remoteData)
        // still need to run merge as it's the format elmApp is expecting
        const mergedData = merge({}, remoteData)
        elmApp.ports.recieveDeployments.send(mergedData)

    } catch (err) {
      log("Error fetching deployments", err)
      elmApp.ports.recieveDeployments.send({err: err.toString()})
    }
  })


  /* This code needs to be at the bottom as `recieveUsername` needs the rest of the ports
       loaded into the script or what not     */
  if (username) {
    //
    // recieve username
    //
    elmApp.ports.recieveUsername.send({username})
  } else {
    elmApp.ports.recieveUsername.send({username: null})
  }

})
  .catch(err => {
    log("Something went wrong setting up the elmApp", err)
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


/**
 * TODO:
 * Remove this temporary code when the alpha-tester folks
 * have upgraded their code. Later we'll have filesystem versioning.
 */
async function temporaryAlphaCodeHandler(err) {
  console.error(err)

  if (
    err.message.indexOf("Could not find header value: metadata") > -1 ||
    err.message.indexOf("Could not find index for node") > -1 ||
    err.message.indexOf("Could not parse a valid private tree using the given key") > -1
  ) {
    const result = confirm("Thanks for testing the alpha version of the webnative sdk. We refactored the file system which is not backwards compatible. Do you want to create a new file system?")

    if (result) {
      fs = await wn.fs.empty({ keyName: "filesystem-lobby", permissions: PERMISSIONS })
      await saveSelectionHistory([]) // do a crud operation to trigger a mutation + publicise
      return fs
    }

  } else {
    throw new Error(err)

  }
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
