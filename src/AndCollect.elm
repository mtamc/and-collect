module AndCollect exposing (custom)

{-|

@docs custom

-}


{-| Example usage:

    module RemoteData.Extra exposing (andCollect)

    import AndCollect
    import RemoteData exposing (RemoteData)

    andCollect :
        (a -> RemoteData e b)
        -> RemoteData e a
        -> RemoteData e ( a, b )
    andCollect callback oldRemoteData =
        AndCollect.custom
            RemoteData.andThen
            RemoteData.map
            callback
            oldRemoteData

You may then use RemoteData.Extra.andCollect by turning code such as this...

    import RemoteData

    getRemoteAnswer : RemoteData error Int
    getRemoteAnswer =
        getA
            |> RemoteData.andThen
                (\a ->
                    getB a
                        |> RemoteData.andThen
                            (\b ->
                                getC a b
                                    |> remoteData.andThen
                                        (\c ->
                                            solve a b c
                                        )
                            )
                )

...into this:

    import RemoteData
    import RemoteData.Extra as RemoteData

    getRemoteAnswer : RemoteData error Int
    getRemoteAnswer =
        getA
            |> RemoteData.andCollect getB
            |> RemoteData.andCollect (\( a, b ) -> getC a b)
            |> RemoteData.andThen (\( ( a, b ), c ) -> solve a b c)

(The LSP's inferred signature was used. Feedback or experimentation should be gathered to ensure the lack of higher-kinded types aren't causing any weird gotchas.)

-}
custom :
    ((a -> mb) -> ma -> mab)
    -> ((x -> ( a, x )) -> b -> mb)
    -> (a -> b)
    -> ma
    -> mab
custom andThenFn mapFn callback input =
    input
        |> andThenFn
            (\inputUnwrapped ->
                callback inputUnwrapped
                    |> mapFn
                        (\callbackOutputUnwrapped ->
                            ( inputUnwrapped, callbackOutputUnwrapped )
                        )
            )
