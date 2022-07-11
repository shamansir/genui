module GenUI.Dhall.Encode exposing (Dhall, encode, toString)


{-| Converting to DHALL representation.

@docs Dhall, encode, toString
-}


import GenUI as G
import Indent exposing (Indented, indent)


{-| -}
type alias Dhall =
    Indented


{-| Encode UI to DHALL.
-}
encode : G.GenUI -> Dhall
encode genui =
    ( 0, "GenUI, version " ++ genui.version )
        :: (indent <| List.map property genui.root)


{-| Convert DHALL to string.
-}
toString : Dhall -> String
toString =
    List.map (\( indent_, str ) -> (String.fromList <| List.repeat indent_ ' ') ++ str)
        >> String.join "\n"


indent : Dhall -> Dhall
indent =
    indentBy 1


indentBy : Int -> Dhall -> Dhall
indentBy amount =
    List.map (Tuple.mapFirst ((+) amount))


def : G.Def -> Descriptive
def d =
    let
        intDef id =
            [ ( 0, "integer number field, current value is " ++ String.fromInt id.current )
            , ( 1, "minimum value is " ++ String.fromInt id.min )
            , ( 1, "maximum value is " ++ String.fromInt id.max )
            , ( 1, "and the steps are in amount of  " ++ String.fromInt id.step )
            ]

        floatDef fd =
            [ ( 0, "float number field, current value is " ++ String.fromFloat fd.current )
            , ( 1, "minimum value is " ++ String.fromFloat fd.min )
            , ( 1, "maximum value is " ++ String.fromFloat fd.max )
            , ( 1, "and the steps are in amount of  " ++ String.fromFloat fd.step )
            ]

        xyDef xyd =
            ( 0, "XY field, where X is" )
                :: indent (floatDef xyd.x)
                ++ ( 0, "and Y is " )
                :: indent (floatDef xyd.y)

        toggleDef td =
            [ ( 0
              , "toggle field, currently is "
                    ++ (if td.current then
                            "enabled"

                        else
                            "disabled"
                       )
              )
            ]

        colorDef cd =
            [ ( 0, "color field, current value is " ++ cd.current ) ]

        textDef cd =
            [ ( 0, "text field, current value is \"" ++ cd.current ++ "\"" ) ]

        actionDef ad =
            ( 0, "action button with" )
                :: indent (face ad.face)

        selectDef sd =
            [ ( 0, "it is selection box" )
            , ( 1, "its current value is \"" ++ sd.current ++ "\"" )
            , ( 1, "its possible values are: " )
            ]
                ++ (indent <| indexedList selectItem sd.values)
                ++ [ ( 1
                     , case sd.nestAt of
                        Just p ->
                            "nested at property \"" ++ p ++ "\""

                        Nothing ->
                            "not nested at any property"
                     )
                   , ( 1, "visually it is:" )
                   ]
                ++ indent (selectKind sd.kind)
                ++ ( 1, "the shape of its panel is:" )
                :: indent (nestShape sd.shape)

        nestDef nd =
            [ ( 0, "nested panel" )
            , ( 1
              , "by default it is "
                    ++ (if nd.expand then
                            "expanded"

                        else
                            "collapsed"
                       )
              )
            , ( 1, "its inner components are: " )
            ]
                ++ (indent <| indexedList property nd.children)
                ++ [ ( 1
                     , case nd.nestAt of
                        Just p ->
                            "nested at JS property \"" ++ p ++ "\""

                        Nothing ->
                            "not nested at any JS property (stored plain in the state)"
                     )
                   , ( 1, "its face is:" )
                   ]
                ++ indent (face nd.face)
                ++ ( 1, "the shape of its panel is:" )
                :: indent (nestShape nd.shape)
    in
    case d of
        G.Root ->
            [ ( 0, "root" ) ]

        G.NumInt id ->
            intDef id

        G.NumFloat fd ->
            floatDef fd

        G.XY xyd ->
            xyDef xyd

        G.Toggle td ->
            toggleDef td

        G.Color cd ->
            colorDef cd

        G.Textual td ->
            textDef td

        G.Action ad ->
            actionDef ad

        G.Select sd ->
            selectDef sd

        G.Nest nd ->
            nestDef nd


cellShape : G.CellShape -> Descriptive
cellShape cs =
    [ ( 0, "cell shape with" )
    , ( 1, String.fromInt cs.cols ++ " columns" )
    , ( 1, String.fromInt cs.rows ++ " rows" )
    ]


nestShape : G.NestShape -> Dhall
nestShape ns =
    [ ( 0, "nesting shape with" )
    , ( 1, String.fromInt ns.cols ++ " columns" )
    , ( 1, String.fromInt ns.rows ++ " rows" )
    , ( 1, String.fromInt ns.pages ++ " pages" )
    ]


face : G.Face -> Descriptive
face f =
    case f of
        G.OfColor color ->
            [ ( 0, "represented with color " ++ color ) ]

        G.Icon icon ->
            [ ( 0, "has icon " ++ icon ) ]

        G.Default ->
            [ ( 0, "default face" ) ]


selectKind : G.SelectKind -> Descriptive
selectKind sk =
    case sk of
        G.Choice c ->
            [ ( 0, "just a choice" )
            , ( 1
              , "by default it is "
                    ++ (if c.expand then
                            "expanded"

                        else
                            "collapsed"
                       )
              )
            , ( 1, "its face is:" )
            ]
                ++ indent (face c.face)

        G.Knob ->
            [ ( 0, "a switch between values as a knob" ) ]

        G.Switch ->
            [ ( 0, "a switch between values" ) ]


selectItem : G.SelectItem -> Descriptive
selectItem si =
    [ ( 0, "the value: \"" ++ si.value ++ "\"" )
    , ( 1
      , "and the name is "
            ++ (case si.name of
                    Just name ->
                        "\"" ++ name ++ "\""

                    Nothing ->
                        "the same as the value"
               )
      )
    , ( 1, "its face is:" )
    ]
        ++ indent (face si.face)


property : G.Property -> Descriptive
property prop =
    [ ( 0, "property \"" ++ prop.name ++ "\"" )
    , ( 1
      , case prop.property of
            Just p ->
                "bound to JS property \"" ++ p ++ "\""

            Nothing ->
                "not nested at any property"
      )
    , ( 1
      , if prop.live then
            "its values are monitored live"

        else
            "the changes in the value outside of controls are not tracked"
      )
    ]
        ++ indent (def prop.def)
        ++ (case prop.shape of
                Just cs ->
                    ( 1, "the shape of its cell is:" )
                        :: indent (cellShape cs)

                Nothing ->
                    []
           )
