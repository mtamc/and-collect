# and-collect

The goal of this experimental package is to simplify interdependent computations such as...

```elm
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
```

...by allowing you to write them this way instead:

```elm
import Maybe.AndCollect as Maybe

computeAnswer : Maybe Int
computeAnswer =
    getA
        |> Maybe.andCollect getB
        |> Maybe.andCollect (\( a, b ) -> getC a b)
        |> Maybe.andThen (\( ( a, b ), c ) -> solve a b c)
```

This is much cleaner, even with `elm-format`, whose rules can make it difficult to
work with interdependent computations. As this collects values into nested
tuples, chaining `andCollect` too many times might still cause hard-to-read
code.

The type signature for `Maybe.AndCollect.andCollect` is very similar to `Maybe.andThen`:

```elm
andThen    : (a -> Maybe b) -> Maybe a -> Maybe b
andCollect : (a -> Maybe b) -> Maybe a -> Maybe ( a, b )
```

This package provides `andCollect` combinators for `Maybe`,  `Result`, `Task`, as well as a generic `custom` combinator for your own monad-like data types:

```elm
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
```

This is how `custom` is implemented. (The LSP's inferred signature was used. Feedback or experimentation should be gathered to ensure this is the lack of higher-kinded types aren't causing any weird gotchas.)

```elm
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
```
