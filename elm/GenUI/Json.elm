module GenUI.Json exposing (..)

import GenUI as G

import Json.Decode as D
import Json.Encode as E


decodeCellShape : D.Decoder G.CellShape
decodeCellShape =
    D.map2
        G.CellShape
        (D.field "cols" <| D.int)
        (D.field "rows" <| D.int)


decodeNestShape : D.Decoder G.NestShape
decodeNestShape =
    D.map3
        G.NestShape
        (D.field "cols" <| D.int)
        (D.field "rows" <| D.int)
        (D.field "pages" <| D.int)


decodeFace : D.Decoder G.Face
decodeFace =
    D.field "face" D.string
        |> D.andThen
            (\face ->
                case face of
                    "icon" -> D.field "icon" D.string |> D.map G.Icon
                    "color" -> D.field "color" D.string |> D.map G.Color
                    _ -> D.fail <| "Unknown face: " ++ face
            )



decodeDef : String -> D.Decoder G.Def
decodeDef kind =
    case kind of

        "action" ->
            D.field "face" decodeFace
                |> D.maybe
                |> D.map (Maybe.withDefault G.Default)
                |> D.map G.ActionDef
                |> D.map G.Action

        "int" ->
           D.map4
                G.IntDef
                (D.field "min" D.int)
                (D.field "max" D.int)
                (D.field "step" D.int)
                (D.field "current" D.int)
                |> D.map G.NumInt

        "float" ->
           D.map4
                G.FloatDef
                (D.field "min" D.float)
                (D.field "max" D.float)
                (D.field "step" D.float)
                (D.field "current" D.float)
                |> D.map G.NumFloat

        _ -> D.fail <| "unknown kind " ++ kind



decodeProperty : D.Decoder G.Property
decodeProperty =
    D.field "kind" D.string
        |> D.andThen
            (\kind ->
                D.map5
                        G.Property
                        (D.field "def" <| decodeDef kind)
                        (D.field "name" D.string)
                        (D.maybe <| D.field "property" D.string)
                        (D.field "live" D.bool)
                        (D.maybe <| D.field "shape" decodeCellShape)
            )


decode : D.Decoder G.GenUI
decode =
    D.map2
        G.GenUI
        (D.field "version" D.string)
        (D.field "root" <| D.list decodeProperty)


encode : G.GenUI -> E.Value
encode _ = E.null