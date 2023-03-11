module Task.AndCollect exposing (andCollect)

{-|

@docs andCollect

-}

import AndCollect
import Task exposing (Task)


{-| Combinator for interdependent `Task` values. Note the type signature similarities with `Task.andThen`:

    andThen : (a -> Task e b) -> Task e a -> Task e b

    andCollect : (a -> Task e b) -> Task e a -> Task e ( a, b )

Intended usage is turning interdependent `Task` values such as this...

    computeAnswer : Task error Int
    computeAnswer =
        getA
            |> Task.andThen
                (\a ->
                    getB a
                        |> Task.andThen
                            (\b ->
                                getC a b
                                    |> Task.andThen
                                        (\c ->
                                            solve a b c
                                        )
                            )
                )

... into this:

    import Task.AndCollect as Task

    computeAnswer : Task error Int
    computeAnswer =
        getA
            |> Task.andCollect getB
            |> Task.andCollect (\( a, b ) -> getC a b)
            |> Task.andThen (\( ( a, b ), c ) -> solve a b c)

-}
andCollect : (a -> Task e b) -> Task e a -> Task e ( a, b )
andCollect callback oldTask =
    AndCollect.custom Task.andThen Task.map callback oldTask
