module RemoteData exposing
    ( RemoteData(..)
    , withDefault
    )

-- RemoteData without the NotAsked state


type RemoteData e a
    = Loading
    | Failure e
    | Success a


withDefault : a -> RemoteData e a -> a
withDefault default data =
    case data of
        Loading ->
            default

        Failure _ ->
            default

        Success v ->
            v
