module GenUI.Json.ToValues exposing (toValues)


{-| @docs toValues
-}

import GenUI as G
import GenUI.Color as Color
import GenUI.Gradient as Gradient

import Json.Encode as E


toValue : G.Property a -> ( String, E.Value )
toValue ( { def, property, name }, _ ) =
    ( property |> Maybe.withDefault name
    , case def of
        G.Ghost -> E.null
        G.NumInt id -> E.int id.current
        G.NumFloat fd -> E.float fd.current
        G.XY xyd ->
            E.object
                [ ( "x", E.float xyd.x.current )
                , ( "y", E.float xyd.y.current )
                ]
        G.Toggle td ->
            E.bool td.current
        G.Color cd ->
            E.string <| Color.toString cd.current
        G.Gradient gd ->
            E.string <| Gradient.toString gd.current
        G.Textual td ->
            E.string td.current
        G.Action _ ->
            E.string "[[action]]"
        G.Select sd ->
            E.string sd.current
        G.Progress _ ->
            E.string "[[progress]]"
        G.Zoom zd ->
            E.float zd.current
        G.Nest nd ->
            E.object
            <| List.map toValue nd.children
    )


{-| Extracts current values from the given UI definition as JSON. See the example in `loadValues`. -}
toValues : G.GenUI a -> E.Value
toValues genui =
    E.object
        <| List.map toValue genui.root