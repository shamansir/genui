module GenUI.Yaml.Decode exposing (decode, decode_)


{-| Decoding from YAML

@docs decode, decode_
-}


import GenUI as G
import GenUI.Color as G
import GenUI.Gradient as G

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
        (D.field "horz" unit)
        (D.field "vert" unit)


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
        , D.map
            G.Hex
            (D.field "hex" D.string)
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



gstop1 : D.Decoder G.Stop
gstop1 =
    D.map2
        G.Stop
        (D.field "color" color)
        (D.field "position" D.float)


gstop2 : D.Decoder G.Stop2D
gstop2 =
    D.map3
        (\c x y -> { color = c, position = { x = x, y = y } })
        (D.field "color" color)
        (D.field "x" D.float)
        (D.field "y" D.float)


face : D.Decoder G.Face
face =
    D.field "face" D.string
        |> D.andThen
            (\face_ ->
                case face_ of
                    "icon" -> D.field "icons" (D.list icon) |> D.map G.OfIcon
                    "color" -> D.field "color" color |> D.map G.OfColor
                    "title" -> D.succeed G.Title
                    "expand" -> D.succeed G.PanelExpandStatus
                    "focus" -> D.succeed G.PanelFocusedItem
                    _ -> D.fail <| "Unknown face: " ++ face_
            )


unit : D.Decoder G.Unit
unit =
    let
        allowed_error = 0.001
        closeTo expected actual = abs (actual - expected) < allowed_error
    in D.float
        |> D.map
        (\f ->
            if closeTo 0.5 f then G.Half
            else if closeTo 1.0 f then G.One
            else if closeTo 1.5 f then G.OneAndAHalf
            else if closeTo 2.0 f then G.Two
            else if closeTo 4.0 f then G.Three
            else G.Custom f
        )


page : D.Decoder G.Page
page =
    D.field "page" D.string
        |> D.andThen (\s ->
            case s of
                "first" -> D.succeed G.First
                "last" -> D.succeed G.Last
                "current" -> D.succeed G.ByCurrent
                "n" -> D.field "n" D.int |> D.map G.Page
                _ -> D.fail <| "unknown page def " ++ s
        )



pages : D.Decoder G.Pages
pages =
    D.field "distribute" D.string
        |> D.andThen (\s ->
            case s of
                "auto" -> D.succeed G.Auto
                "single" -> D.succeed G.Single
                "values" ->
                    D.map2
                        (\mr mc -> G.Distribute { maxInRow = mr, maxInColumn = mc })
                        (D.field "maxInRow" D.int)
                        (D.field "maxInColumn" D.int)
                "exact" ->
                    D.field "exact" D.int |> D.map G.Exact
                _ -> D.fail <| "unknown pages def " ++ s
        )


panel : D.Decoder G.Panel
panel =
    D.map5
        G.Panel
        (D.field "form" form)
        (D.field "button" face)
        (D.maybe <| D.field "allOf" cellShape)
        (D.field "page" page)
        (D.field "pages" pages)



selectItem : D.Decoder G.SelectItem
selectItem =
    D.map3
        G.SelectItem
        (D.field "value" D.string)
        (maybeField "face" G.Empty face)
        (D.maybe <| D.field "name" D.string)


selectKind : D.Decoder G.SelectKind
selectKind =
    D.field "kind" D.string
        |> D.andThen
            (\kind_ ->
                case kind_ of
                    "choice" ->
                        D.map G.Choice <| D.field "panel" panel
                    "knob" -> D.succeed G.Knob
                    "switch" -> D.succeed G.Switch
                    _ -> D.fail <| "Unknown face: " ++ kind_
            )


def : D.Decoder a -> String -> D.Decoder (G.Def (Maybe a))
def decodeA kind =
    let

        actionDef =
           maybeField "face" G.Empty face
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
            D.map5
                G.SelectDef
                (D.field "current" D.string)
                (D.field "values" <|
                    D.oneOf
                        [ D.list selectItem
                        , D.map (List.map (\v -> { value = v, face = G.Title, name = Nothing } )) <| D.list D.string
                        ]
                )
                (D.maybe <| D.field "allOf" cellShape)
                (D.maybe <| D.field "nestAt" D.string)
                (D.field "kind" selectKind)


        nestDef =
            D.map3
                G.NestDef
                (D.field "children" <| D.list (property_ decodeA))
                (D.maybe <| D.field "nestAt" D.string)
                (D.field "panel" panel)

        progressDef =
            D.map
                G.ProgressDef
                (D.field "api" url)

        gradientDef =
            D.map2
                G.GradientDef
                (D.field "current"
                    <| D.oneOf
                        [ D.map
                            G.Linear
                            (D.list gstop1)
                        , D.map
                            G.TwoDimensional
                            (D.list gstop2)
                        ]
                )
                (D.field "presets" <| D.list color)

        zoomDef =
            D.map2
                (\current steps ->
                    { current = current
                    , kind =
                        if List.isEmpty steps then
                            G.PlusMinus else G.Steps steps
                    }
                )
                (D.field "current" D.float)
                (D.field "steps" <| D.list D.float)

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




property : D.Decoder (G.Property ())
property =
    D.map (G.mapProperty <| always ()) <| property_ <| D.succeed ()


property_ : D.Decoder a -> D.Decoder (G.Property (Maybe a))
property_ decodeA =
    D.field "kind" D.string
        |> D.andThen
            (\kind ->
                D.map7
                    G.PropertyRec
                    (D.field "def" <| def decodeA kind)
                    (D.field "name" D.string)
                    (D.maybe <| D.field "property" D.string)
                    (D.field "live" D.bool)
                    (D.maybe <| D.field "shape" cellShape)
                    (D.maybe <| D.field "triggerOn" <| D.list D.string)
                    (D.maybe <| D.field "statePath" <| D.list D.string)
                |> D.andThen
                    (\rec ->
                        D.field "_value_" decodeA
                            |> D.maybe
                            |> D.map (Tuple.pair rec)
                    )
            )


{-| YAML Decoder -}
decode : D.Decoder (G.GenUI ())
decode =
    D.map2
        G.GenUI
        (D.field "version" D.string)
        (D.field "root" <| D.list property)


{-| YAML Decoder for the cases when value was included in data at the `_value_` field (see `Yaml.Encode.encode_`) -}
decode_ : D.Decoder a -> D.Decoder (G.GenUI (Maybe a))
decode_ decodeA =
    D.map2
        G.GenUI
        (D.field "version" D.string)
        (D.field "root" <| D.list <| property_ decodeA)