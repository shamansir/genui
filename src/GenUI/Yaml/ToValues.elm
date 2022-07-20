module GenUI.Yaml.ToValues exposing (toValues)

{-| @docs toValues
-}

import GenUI as G
import GenUI.Color as Color
import GenUI.Gradient as Gradient

import Yaml.Encode as E


toValue : G.Property -> ( String, E.Encoder )
toValue { def, property, name } =
    ( property |> Maybe.withDefault name
    , case def of
        G.Ghost -> E.null
        G.NumInt id -> E.int id.current
        G.NumFloat fd -> E.float fd.current
        G.XY xyd ->
            E.record
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
            E.record
            <| List.map toValue nd.children
    )


{-| Extracts current values from the given UI definition as YAML. See the example of such in `loadValues`. -}
toValues : G.GenUI -> E.Encoder
toValues genui =
    E.record
        <| List.map toValue genui.root