module GenUI.Yaml.Decode exposing (decode)


{-| Decoding from YAML

@docs decode
-}


import GenUI as G

import Yaml.Decode as D


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


color : D.Decoder G.Color
color =
    D.oneOf
        [ D.map4
            (\r g b a -> G.Rgba { red = r, green = g, blue = b, alpha = a })
            (D.field "r" D.float)
            (D.field "g" D.float)
            (D.field "b" D.float)
            (D.field "a" D.float)
        , D.map4
            (\h s l a -> G.Hsla { hue = h, saturation = s, lightness = l, alpha = a })
            (D.field "h" D.float)
            (D.field "s" D.float)
            (D.field "l" D.float)
            (D.field "a" D.float)
        ]


icon : D.Decoder G.Icon
icon =
    D.map2
        G.Icon
        (D.field "theme" theme)
        (D.field "url" url)


theme : D.Decoder G.Theme
theme =
    D.string
        |> D.map
            (\s ->
                case s of
                    "light" -> G.Light
                    "dark" -> G.Dark
                    _ -> G.Light
            )


form : D.Decoder G.Form
form =
    D.string
        |> D.map
            (\s ->
                case s of
                    "expanded" -> G.Expanded
                    "collapsed" -> G.Collapsed
                    _ -> G.Expanded
            )


url : D.Decoder G.Url
url =
    D.map2
        (\t v ->
            case t of
                "local" -> G.Local v
                "remote" -> G.Remote v
                _  -> G.Remote v
        )
        (D.field "type" D.string)
        (D.field "value" D.string)



gstop1 : D.Decoder G.ColorStop
gstop1 =
    D.map2
        G.ColorStop
        (D.field "color" color)
        (D.field "position" D.float)


gstop2 : D.Decoder G.ColorStop2D
gstop2 =
    D.map3
        (\c x y -> { color = c, position = { x = x, y = y } })
        (D.field "color" color)
        (D.field "x" D.float)
        (D.field "y" D.float)


face : D.Decoder G.Face
face =
    {- D.field "face" -} D.string
        |> D.andThen
            (\face_ ->
                case face_ of
                    "icons" -> D.field "icons" (D.list icon) |> D.map G.OfIcon
                    "color" -> D.field "color" color |> D.map G.OfColor
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
                        D.map4
                            (\fr fc s p ->
                                G.Choice
                                    { form = fr, face = fc, shape = s, page = p }
                            )
                            (maybeField "form" G.Expanded form)
                            (maybeField "face" G.Default face)
                            (D.field "shape" nestShape)
                            (D.field "page" D.int)
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
                (D.field "current" color)

        textDef =
            D.map
                G.TextualDef
                (D.field "current" D.string)

        toggleDef =
            D.map
                G.ToggleDef
                (D.field "current" D.bool)

        selectDef =
            D.map4
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


        nestDef =
            D.map6
                G.NestDef
                (D.field "children" <| D.list property)
                (maybeField "form" G.Expanded form)
                (D.maybe <| D.field "nestAt" D.string)
                (D.field "shape" nestShape)
                (maybeField "face" G.Default face)
                (D.field "page" D.int)

        progressDef =
            D.map
                G.ProgressDef
                (D.field "api" url)

        gradientDef =
            D.map
                G.GradientDef
                (D.oneOf
                    [ D.map
                        G.Linear
                        (D.field "stops" <| D.list gstop1)
                    , D.map
                        G.TwoDimensional
                        (D.field "stops" <| D.list gstop2)
                    ]
                )

        zoomDef =
            D.map2
                (\current stops ->
                    { current = current
                    , kind =
                        if List.isEmpty stops then
                            G.PlusMinus else G.Steps stops
                    }
                )
                (D.field "current" D.float)
                (D.field "stops" <| D.list D.float)

    in case kind of

        "ghost" -> D.succeed G.Ghost
        "action" -> actionDef |> D.map G.Action
        "int" -> intDef |> D.map G.NumInt
        "float" -> floatDef |> D.map G.NumFloat
        "xy" -> xyDef |> D.map G.XY
        "color" -> colorDef |> D.map G.Color
        "text" -> textDef |> D.map G.Textual
        "toggle" -> toggleDef |> D.map G.Toggle
        "nest" -> nestDef |> D.map G.Nest
        "select" -> selectDef |> D.map G.Select
        "progress" -> progressDef |> D.map G.Progress
        "gradient" -> gradientDef |> D.map G.Gradient
        "zoom" -> zoomDef |> D.map G.Zoom

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


{-| JSON Decoder -}
decode : D.Decoder G.GenUI
decode =
    D.map2
        G.GenUI
        (D.field "version" D.string)
        (D.field "root" <| D.list property)