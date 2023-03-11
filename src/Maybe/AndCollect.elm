module Maybe.AndCollect exposing (andCollect)

{-|

@docs andCollect

-}

import AndCollect


{-| Combinator for interdependent `Maybe` values. Note the type signature similarities with `Maybe.andThen`:

    andThen : (a -> Maybe b) -> Maybe a -> Maybe b

    andCollect : (a -> Maybe b) -> Maybe a -> Maybe ( a, b )

Intended usage is turning interdependent `Maybe` values such as this...

    computeAnswer : Maybe Int
    computeAnswer =
        getA
            |> Maybe.andThen
                (\a ->
                    getB a
                        |> Maybe.andThen
                            (\b ->
                                getC a b
                                    |> Maybe.andThen
                                        (\c ->
                                            solve a b c
                                        )
                            )
                )

... into this:

    import Maybe.AndCollect as Maybe

    computeAnswer : Maybe Int
    computeAnswer =
        getA
            |> Maybe.andCollect getB
            |> Maybe.andCollect (\( a, b ) -> getC a b)
            |> Maybe.andThen (\( ( a, b ), c ) -> solve a b c)

-}
andCollect : (a -> Maybe b) -> Maybe a -> Maybe ( a, b )
andCollect callback oldMaybe =
    AndCollect.custom Maybe.andThen Maybe.map callback oldMaybe
