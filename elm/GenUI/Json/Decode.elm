module GenUI.Json.Decode exposing (..)


import GenUI as G

import Json.Decode as D


maybeField : String -> a -> D.Decoder a -> D.Decoder a
maybeField name default decoder =
    D.field name decoder
        |> D.maybe
        |> D.map (Maybe.withDefault default)


cellShape : D.Decoder G.CellShape
cellShape =
    D.map2
        G.CellShape
        (D.field "cols" D.int)
        (D.field "rows" D.int)


nestShape : D.Decoder G.NestShape
nestShape =
    D.map3
        G.NestShape
        (D.field "cols" D.int)
        (D.field "rows" D.int)
        (D.field "pages" D.int)


face : D.Decoder G.Face
face =
    {- D.field "face" -} D.string
        |> D.andThen
            (\face_ ->
                case face_ of
                    "icon" -> D.field "icon" D.string |> D.map G.Icon
                    "color" -> D.field "color" D.string |> D.map G.OfColor
                    _ -> D.fail <| "Unknown face: " ++ face_
            )


selectItem : D.Decoder G.SelectItem
selectItem =
    D.map3
        G.SelectItem
        (D.field "value" D.string)
        (maybeField "face" G.Default face)
        (D.maybe <| D.field "name" D.string)


selectKind : D.Decoder G.SelectKind
selectKind =
    D.field "kind" D.string
        |> D.andThen
            (\kind_ ->
                case kind_ of
                    "choice" ->
                        D.map2
                            (\e f -> G.Choice { expand = e, face = f })
                            (D.field "expand" D.bool)
                            (maybeField "face" G.Default face)
                    "knob" -> D.succeed G.Knob
                    "switch" -> D.succeed G.Switch
                    _ -> D.fail <| "Unknown face: " ++ kind_
            )


def : String -> D.Decoder G.Def
def kind =
    let

        actionDef =
           maybeField "face" G.Default face
                |> D.map G.ActionDef

        intDef =
            D.map4
                G.IntDef
                (D.field "min" D.int)
                (D.field "max" D.int)
                (D.field "step" D.int)
                (D.field "current" D.int)


        floatDef =
            D.map4
                G.FloatDef
                (D.field "min" D.float)
                (D.field "max" D.float)
                (D.field "step" D.float)
                (D.field "current" D.float)


        xyDef =
            D.map2
                G.XYDef
                (D.field "x" floatDef)
                (D.field "y" floatDef)

        colorDef =
            D.map
                G.ColorDef
                (D.field "current" D.string)

        textDef =
            D.map
                G.TextualDef
                (D.field "current" D.string)

        toggleDef =
            D.map
                G.ToggleDef
                (D.field "current" D.bool)

        selectDef =
            D.map5
                G.SelectDef
                (D.field "current" D.string)
                (D.field "values" <|
                    D.oneOf
                        [ D.list selectItem
                        , D.map (List.map (\v -> { value = v, face = G.Default, name = Nothing } )) <| D.list D.string
                        ]
                )
                (D.maybe <| D.field "nestAt" D.string)
                (D.field "kind" selectKind)
                (D.field "shape" nestShape)


        nestDef =
            D.map5
                G.NestDef
                (D.field "children" <| D.list property)
                (D.field "expand" D.bool)
                (D.maybe <| D.field "nestAt" D.string)
                (D.field "shape" nestShape)
                (maybeField "face" G.Default face)

    in case kind of

        "root" -> D.succeed G.Root
        "action" -> actionDef |> D.map G.Action
        "int" -> intDef |> D.map G.NumInt
        "float" -> floatDef |> D.map G.NumFloat
        "xy" -> xyDef |> D.map G.XY
        "color" -> colorDef |> D.map G.Color
        "text" -> textDef |> D.map G.Textual
        "toggle" -> toggleDef |> D.map G.Toggle
        "nest" -> nestDef |> D.map G.Nest
        "select" -> selectDef |> D.map G.Select


        _ -> D.fail <| "unknown kind " ++ kind




property : D.Decoder G.Property
property =
    D.field "kind" D.string
        |> D.andThen
            (\kind ->
                D.map5
                    G.Property
                    (D.field "def" <| def kind)
                    (D.field "name" D.string)
                    (D.maybe <| D.field "property" D.string)
                    (D.field "live" D.bool)
                    (D.maybe <| D.field "shape" cellShape)
            )


decode : D.Decoder G.GenUI
decode =
    D.map2
        G.GenUI
        (D.field "version" D.string)
        (D.field "root" <| D.list property)