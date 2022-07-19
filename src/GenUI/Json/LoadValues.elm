module GenUI.Json.LoadValues exposing (loadValues)

import GenUI as G
import GenUI.Color as Color exposing (Color)
import GenUI.Gradient as Gradient exposing (Gradient)
import Json.Decode as D


loadValues : D.Value -> G.GenUI -> G.GenUI
loadValues root =
    let
        updateDef pPath def =
            case def of
                G.NumInt nd ->
                    helper pPath D.int <| \ci -> G.NumInt { nd | current = ci }

                G.NumFloat fd ->
                    helper pPath D.float <| \cf -> G.NumFloat { fd | current = cf }

                G.XY xyd ->
                    helper pPath
                        (D.map2
                            (\x y -> { x = x, y = y })
                            (D.field "x" D.float)
                            (D.field "y" D.float)
                        )
                    <|
                        \cxy ->
                            let
                                ( xd, yd ) =
                                    ( xyd.x, xyd.y )
                            in
                            G.XY
                                { x = { xd | current = cxy.x }
                                , y = { yd | current = cxy.y }
                                }

                G.Toggle bd ->
                    helper pPath D.bool <| \cb -> G.Toggle { bd | current = cb }

                G.Color cd ->
                    helper pPath
                        (D.string
                            |> D.map Color.fromString
                            |> D.andThen
                                (\resColor ->
                                    case resColor of
                                        Ok color ->
                                            D.succeed color

                                        Err failure ->
                                            D.fail <| Color.errorToString failure
                                )
                        )
                    <|
                        \cc -> G.Color { cd | current = cc }

                G.Gradient gd ->
                    helper pPath
                        (D.string
                            |> D.map Gradient.fromString
                            |> D.andThen
                                (\resColor ->
                                    case resColor of
                                        Ok color ->
                                            D.succeed color

                                        Err failure ->
                                            D.fail failure
                                )
                        )
                    <|
                        \cg -> G.Gradient { gd | current = cg }

                G.Textual td ->
                    helper pPath D.string <| \ct -> G.Textual { td | current = ct }

                G.Select sd ->
                    helper pPath D.string <| \cs -> G.Select { sd | current = cs }

                G.Zoom zd ->
                    helper pPath D.float <| \cz -> G.Zoom { zd | current = cz }

                _ ->
                    Result.Ok def

        helper : G.PropPath -> D.Decoder x -> (x -> G.Def) -> Result D.Error G.Def
        helper pPath decoder modifyDef =
            root
                |> D.decodeValue (D.at pPath decoder)
                |> Result.map modifyDef
    in
    G.update
        (\( _, pPath ) prop ->
            Just
                { prop
                | def = updateDef pPath prop.def
                    |> Result.withDefault prop.def
                }
        )