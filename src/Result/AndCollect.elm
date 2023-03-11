module Result.AndCollect exposing (andCollect)

{-|

@docs andCollect

-}

import AndCollect


{-| Combinator for interdependent `Result` values. Note the type signature similarities with `Result.andThen`:

    andThen : (a -> Result e b) -> Result e a -> Result e b

    andCollect : (a -> Result e b) -> Result e a -> Result e ( a, b )

Intended usage is turning interdependent `Result` values such as this...

    computeAnswer : Result error Int
    computeAnswer =
        getA
            |> Result.andThen
                (\a ->
                    getB a
                        |> Result.andThen
                            (\b ->
                                getC a b
                                    |> Result.andThen
                                        (\c ->
                                            solve a b c
                                        )
                            )
                )

... into this:

    import Result.AndCollect as Result

    computeAnswer : Result error Int
    computeAnswer =
        getA
            |> Result.andCollect getB
            |> Result.andCollect (\( a, b ) -> getC a b)
            |> Result.andThen (\( ( a, b ), c ) -> solve a b c)

-}
andCollect : (a -> Result e b) -> Result e a -> Result e ( a, b )
andCollect callback oldResult =
    AndCollect.custom Result.andThen Result.map callback oldResult
