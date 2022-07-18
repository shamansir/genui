module GenUI.Dhall.Encode exposing (Dhall, encode, toString)


{-| Converting to DHALL representation.

@docs Dhall, encode, toString
-}



import GenUI as G

import Util.Indent exposing (Indented, indent, indented)

import GenUI.Color as Color
import GenUI.Gradient as Gradient


type Selects = Dict String G.SelectItem


type alias Dhall = ( Selects, Indented )


fi : Int -> String
fi i =
    if i < 0 then String.fromInt i
    else "+" ++ String.fromInt i


ff : Float -> String
ff f =
    if f - toFloat (floor f) == 0 then
        String.fromFloat f ++ ".0"
    else String.fromFloat f


q : String -> String
q s = "\"" ++ s ++ "\""


def : String -> G.Def -> ( List G.SelectItem, Indented )
def name d =
    let
        intDef id =
            ( []
            ,
                [ ( 0, "b.int " ++ q name ++ " " ++
                    " { min = " ++ fi id.min ++
                    " , max = " ++ fi id.max ++
                    " , step = " ++ fi id.step ++
                    " , current = " ++ fi id.current ++ "}" ) ]
            )

        floatDef fd =
            ( []
            ,
                [ ( 0, "b.float " ++ q name ++ " " ++
                    " { min = " ++ ff fd.min ++
                    " , max = " ++ ff fd.max ++
                    " , step = " ++ ff fd.step ++
                    " , current = " ++ ff fd.current ++ "}" ) ]
            )

        xyDef xyd =
            ( []
            ,
                [ ( 0, "b.xy " ++ q name )
                , ( 1, "{ x = " ++
                    " { min = " ++ ff xyd.x.min ++
                    " , max = " ++ ff xyd.x.max ++
                    " , step = " ++ ff xyd.x.step ++
                    " , current = " ++ ff xyd.x.current ++ " }"
                    )
                , ( 1, ", y = " ++
                    " { min = " ++ ff xyd.y.min ++
                    " , max = " ++ ff xyd.y.max ++
                    " , step = " ++ ff xyd.y.step ++
                    " , current = " ++ ff xyd.y.current ++ " }"
                    )
                , ( 1, "}" )
                ]
            )

        toggleDef td =
            ( []
            ,
                [ ( 0
                , "b.toggle " ++ q name ++ " " ++
                        (if td.current then
                            "True"

                        else
                            "False"
                        )
                )
                ]
            )

        colorDef cd =
            ( []
            , [ ( 0, "b.color " ++ q name " (" ++ color cd.current ++ ")" ) ]
            )

        textDef cd =
            ( []
            , [ ( 0, "b.text " ++ q name ++ " " ++ q cd.current ) ]
            )

        actionDef ad =
            ( []
            , case ad.face of
                G.Default -> [ ( 0, "b.action " ++ q name ) ]
                _ ->
                    [ ( 0, "b.with_face" )
                    , ( 1, "(b.action " ++ q name ++ ")" )
                    , ( 1, "(" ++ face ad.face ++ ")")
                    ]
            )

        selectDef sd =
            ( sd.values
            ,
                [ ( 0, "b.select " ++ q name ++ " " ++ name ++ "_items " ++ q sd.current ) ]
            )

        nestDef nd =
            ( []
            ,
                [ ( 0, "b.nest" )
                , ( 1, q name )
                , ( 1, "( b.children" )
                ]
                ++ ({- List.indexedMap (\idx c -> ) <| -} List.map property nd.children)
                [ ( 1, ")")
                ]
            )

        gradientDef gd =
            [ ( 0, "gradient editor, current value is " ++ Gradient.toString gd.current ) ]

        progressDef pd =
            [ ( 0, "some progress display, its api is at " ++ url pd.api ) ]

        zoomDef zd =
            [ ( 0, "zoom control, current zoom is " ++ String.fromFloat zd.current ) ]


    in
    case d of
        G.Ghost ->
            ( [], [ ( 0, "b.ghost " ++ name ) ] )

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

        G.Gradient gd ->
            gradientDef gd

        G.Progress pd ->
            progressDef pd

        G.Zoom zd ->
            zoomDef zd


cellShape : G.CellShape -> Dhall
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


face : G.Face -> Dhall
face f =
    case f of
        G.OfColor color ->
            [ ( 0, "represented with color " ++ Color.toString color ) ]

        G.OfIcon icons ->
            ( 0, "has icons: ")
                :: (indent <| indexedList (indented << icon) icons)

        G.Default ->
            [ ( 0, "default face" ) ]


selectKind : G.SelectKind -> Dhall
selectKind sk =
    case sk of
        G.Choice c ->
               ( 0, "just a choice" )
            :: ( 1
              , "by default it is "
                    ++ (case c.form of
                            G.Expanded -> "expanded"
                            G.Collapsed -> "collapsed"
                       )
              )
            :: ( 1, "its face is:" )
            :: indent (face c.face)
            ++ ( 1, "the shape of its panel is:" )
            :: indent (nestShape c.shape)

        G.Knob ->
            [ ( 0, "a switch between values as a knob" ) ]

        G.Switch ->
            [ ( 0, "a switch between values" ) ]


selectItem : G.SelectItem -> Dhall
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


url : G.Url -> String
url u =
    case u of
        G.Local local -> "@local://" ++ local
        G.Remote remote -> remote


icon : G.Icon -> String
icon i =
    let
        themeString =
            case i.theme of
                G.Dark -> "dark"
                G.Light -> "light"
    in "for " ++ themeString ++ " theme at " ++ url i.url


property : G.Property -> Dhall
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


{-| Convert UI to DHALL
-}
encode : G.GenUI -> Dhall
encode genui =
    ( 0, "GenUI, version " ++ genui.version )
        :: (indent <| indexedList property genui.root)


{-| Convert DHALL to string.
-}
toString : Dhall -> String
toString =
    List.map (\( indent_, str ) -> (String.fromList <| List.repeat indent_ ' ') ++ str)
        >> String.join "\n"