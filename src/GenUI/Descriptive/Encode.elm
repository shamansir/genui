module GenUI.Descriptive.Encode exposing (Descriptive, encode, toString)

{-| Converting to Descriptive representation.

@docs Descriptive, encode, toString

-}

import GenUI as G

import Util.Indent exposing (Indented, indent, indented)

import GenUI.Color as Color
import GenUI.Gradient as Gradient



{-| -}
type alias Descriptive = Indented


def : G.Def ( G.Path, G.PropPath ) -> Descriptive
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
            [ ( 0, "color field, current value is " ++ Color.toString cd.current ) ]

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

        nestDef nd =
            [ ( 0, "nested group" )
            , ( 1, "its inner components are: " )
            ]
                ++ (indent <| indexedList property nd.children)
                ++ ( 1
                     , case nd.nestAt of
                        Just p ->
                            "nested at JS property \"" ++ p ++ "\""

                        Nothing ->
                            "not nested at any JS property (stored plain in the state)"
                     )
                :: panel nd.panel

        gradientDef gd =
            [ ( 0, "gradient editor, current value is " ++ Gradient.toString gd.current ) ]

        progressDef pd =
            [ ( 0, "some progress display, its api is at " ++ url pd.api ) ]

        zoomDef zd =
            [ ( 0, "zoom control, current zoom is " ++ String.fromFloat zd.current ) ]


    in
    case d of
        G.Ghost ->
            [ ( 0, "ghost" ) ]

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


unit : G.Unit -> String
unit u =
    case u of
        G.Half -> "half of the cell"
        G.One -> "one cell"
        G.OneAndAHalf -> "one cell and a half"
        G.Two -> "two cells"
        G.Three -> "three cells"
        G.Custom n -> String.fromFloat n ++ " cells"


cellShape : G.CellShape -> Descriptive
cellShape cs =
    [ ( 0, "the control takes" )
    , ( 1, unit cs.horz ++ " horizontally" )
    , ( 1, unit cs.vert ++ " vertically" )
    ]


face : G.Face -> Descriptive
face f =
    case f of
        G.Empty ->
            [ ( 0, "empty" ) ]

        G.OfColor color ->
            [ ( 0, "represented with color " ++ Color.toString color ) ]

        G.OfIcon icons ->
            ( 0, "has icons: ")
                :: (indent <| indexedList (indented << icon) icons)

        G.Title ->
            [ ( 0, "shows label of the button" ) ]

        G.PanelFocusedItem ->
            [ ( 0, "shows either selected item or focused item of the panel" ) ]

        G.PanelExpandStatus ->
            [ ( 0, "shows if panel is expanded or collapsed" ) ]


selectKind : G.SelectKind -> Descriptive
selectKind sk =
    case sk of
        G.Choice c ->
            ( 0, "just a choice" )
            :: panel c

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


panel : G.Panel -> Descriptive
panel p =
    ( 0, "with the panel" )
    ::  ( 1
        , "by default it is "
        ++ (case p.form of
                G.Expanded -> "expanded"
                G.Collapsed -> "collapsed"
            )
        )
    :: ( 1, "the button that opens this panel has a face:" )
    :: indent (face p.button)
    ++ ( 1, "the items of the panel all take" )
    :: indent (p.allOf |> Maybe.map cellShape |> Maybe.withDefault (indented "different sizes"))
    ++
        [ ( 1, "current page is " ++ page p.page )
        , ( 1, "and the cells in this panel " ++ pages p.pages )
        ]


page : G.Page -> String
page p =
    case p of
        G.First -> "the first one"
        G.Last -> "the last one"
        G.ByCurrent -> "the one with selected or focused item"
        G.Page n -> "page " ++ String.fromInt n


pages : G.Pages -> String
pages p =
    case p of
        G.Auto -> "automatically distributed"
        G.Single -> "all fit on one page"
        G.Distribute { maxInColumn, maxInRow } -> "distributed over pages with maximum " ++ String.fromInt maxInColumn ++ " cells in a column and maximum " ++ String.fromInt maxInRow ++ " cells in a row"
        G.Exact n -> "distributed over " ++ String.fromInt n ++ " pages"


property : G.Property ( G.Path, G.PropPath ) -> Descriptive
property ( prop, ( path, propPath ) ) =
    [ ( 0, "property \"" ++ prop.name ++ "\"" )
    , ( 1, "its full path is: root -> " ++ String.join " -> " propPath )
    , ( 1, "its path by indices is: -1 -> " ++ (String.join " -> " <| List.map String.fromInt path) )
    ]
    ++ indent (def prop.def)
    ++ (case prop.shape of
            Just cs ->
                ( 1, "the shape of its cell is:" )
                    :: indent (cellShape cs)

            Nothing ->
                []
        )
    ++ [
            ( 1
            , case prop.property of
                    Just p ->
                        "bound to JS property \"" ++ p ++ "\""

                    Nothing ->
                        "not nested at any property"
            )
        ,
            ( 1
            , if prop.live then
                    "its values are monitored live"

                else
                    "the changes in the value outside of controls are not tracked"
            )
        ]


{-| Encode UI to descriptive representation.
-}
encode : G.GenUI a -> Descriptive
encode genui =
    let
        pgenui = G.withPath genui |> G.map Tuple.first
    in
    ( 0, "GenUI, version " ++ pgenui.version )
        :: (indent <| indexedList property pgenui.root)


{-| Convert descriptive representation to string.
-}
toString : Descriptive -> String
toString =
    List.map (\( indent_, str ) -> (String.fromList <| List.repeat indent_ ' ') ++ str)
        >> String.join "\n"


indexedList : (a -> Indented) -> List a -> Indented
indexedList f =
    List.indexedMap
        (\idx ->
            List.indexedMap
                (\iidx ( indent_, str ) ->
                    if iidx == 0 then
                        ( indent_, String.fromInt idx ++ ". " ++ str )

                    else
                        ( indent_, str )
                )
                << f
        )
        >> List.concat