module RemoteData exposing (RemoteData(..))

-- RemoteData without the NotAsked state


type RemoteData e a
    = Loading
    | Failure e
    | Success a
