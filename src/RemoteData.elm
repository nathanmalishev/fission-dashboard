module RemoteData exposing
    ( RemoteData(..)
    , withDefault
    )

-- RemoteData without the NotAsked state - I felt that the app didn't need a NotAsked state as that should never exist
-- (But it sort of does when the User is not logged in)


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
