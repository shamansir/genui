module GenUI.Json.Encode exposing (encode, encode_)


{-| Encoding to JSON

@docs encode, encode_
-}


import GenUI as G
import GenUI.Color as G
import GenUI.Gradient as G

import Json.Encode as E


def : (a -> E.Value) -> G.Def a -> E.Value
def encodeA d =
    let
        intDef id =
            E.object
                [ ( "min", E.int id.min )
                , ( "max", E.int id.max )
                , ( "step", E.int id.step )
                , ( "current", E.int id.current )
                ]
        floatDef fd =
            E.object
                [ ( "min", E.float fd.min )
                , ( "max", E.float fd.max )
                , ( "step", E.float fd.step )
                , ( "current", E.float fd.current )
                ]
        xyDef xyd =
            E.object
                [ ( "x", floatDef xyd.x )
                , ( "y", floatDef xyd.y )
                ]
        toggleDef td =
            E.object
                [ ( "current", E.bool td.current )
                ]
        colorDef cd =
            E.object
                [ ( "current", color cd.current )
                ]
        textDef cd =
            E.object
                [ ( "current", E.string cd.current )
                ]
        actionDef ad =
            E.object
                [ ( "face", face ad.face )
                ]
        selectDef sd =
            E.object
                [ ( "nestAt", Maybe.withDefault E.null <| Maybe.map E.string sd.nestAt )
                , ( "kind", selectKind sd.kind )
                , ( "values", E.list selectItem sd.values )
                , ( "current", E.string sd.current )
                ]
        nestDef nd =
            E.object
                [ ( "children", E.list (property encodeA) nd.children )
                , ( "panel", panel nd.panel )
                , ( "nestAt", Maybe.withDefault E.null <| Maybe.map E.string nd.nestAt )
                ]
        gradientDef gd =
            case gd.current of
                G.Linear linear ->
                    E.object
                        [ ( "type", E.string "linear" )
                        , ( "current", E.list gstop1 linear )
                        , ( "presets", E.list color gd.presets )
                        ]
                G.TwoDimensional twod ->
                    E.object
                        [ ( "type", E.string "2d" )
                        , ( "current", E.list gstop2 twod )
                        , ( "presets", E.list color gd.presets )
                        ]
        progressDef pd =
            E.object
                [ ( "api", url pd.api )
                ]
        zoomDef zd =
            E.object
                [ ( "current", E.float zd.current )
                , ( "kind", zoomKind zd.kind )
                , ( "steps", zoomSteps zd.kind )
                ]
    in case d of
        G.Ghost -> E.object []
        G.NumInt id -> intDef id
        G.NumFloat fd -> floatDef fd
        G.XY xyd -> xyDef xyd
        G.Toggle td -> toggleDef td
        G.Color cd -> colorDef cd
        G.Textual td -> textDef td
        G.Action ad -> actionDef ad
        G.Select sd -> selectDef sd
        G.Nest nd -> nestDef nd
        G.Gradient gd -> gradientDef gd
        G.Progress pd -> progressDef pd
        G.Zoom zd -> zoomDef zd



unit : G.Unit -> E.Value
unit u =
    E.float
        <| case u of
            G.Half -> 0.5
            G.One -> 1.0
            G.OneAndAHalf -> 1.5
            G.Two -> 2.0
            G.Three -> 3.0
            G.Custom n -> n


cellShape : G.CellShape -> E.Value
cellShape cs =
    E.object
        [ ( "horz", unit cs.horz )
        , ( "vert", unit cs.vert )
        ]


color : G.Color -> E.Value
color c =
    case c of
        G.Rgba rgba ->
            E.object
                [ ( "r", E.float rgba.red )
                , ( "g", E.float rgba.green )
                , ( "b", E.float rgba.blue )
                , ( "a", E.float rgba.alpha )
                ]
        G.Hsla hsla ->
            E.object
                [ ( "h", E.float hsla.hue )
                , ( "s", E.float hsla.saturation )
                , ( "l", E.float hsla.lightness )
                , ( "a", E.float hsla.alpha )
                ]
        G.Hex hex ->
            E.object
                [ ( "hex", E.string hex )
                ]


icon : G.Icon -> E.Value
icon i =
    E.object
        [ ( "url", url i.url )
        , ( "theme", theme i.theme )
        ]


url : G.Url -> E.Value
url u =
    case u of
        G.Local local ->
            E.object
                [ ( "type", E.string "local" )
                , ( "value", E.string local )
                ]
        G.Remote remote ->
            E.object
                [ ( "type", E.string "remote" )
                , ( "value", E.string remote )
                ]


theme : G.Theme -> E.Value
theme t = E.string <| case t of
    G.Dark -> "dark"
    G.Light -> "light"


gstop1 : G.Stop -> E.Value
gstop1 s =
    E.object
        [ ( "color", color s.color )
        , ( "position", E.float s.position )
        ]


gstop2 : G.Stop2D -> E.Value
gstop2 s =
    E.object
        [ ( "color", color s.color )
        , ( "x", E.float s.position.x )
        , ( "y", E.float s.position.y )
        ]


face : G.Face -> E.Value
face f =
    E.object <| case f of
        G.OfColor c ->
            [ ( "face", E.string "color" )
            , ( "color", color c )
            ]
        G.OfIcon is ->
            [ ( "face", E.string "icon" )
            , ( "icons", E.list icon is )
            ]
        G.Empty ->
            [ ( "face", E.string "empty" )
            ]
        G.Title ->
            [ ( "face", E.string "title" )
            ]
        G.PanelExpandStatus ->
            [ ( "face", E.string "expand" )
            ]
        G.PanelFocusedItem ->
            [ ( "face", E.string "focus" )
            ]


form : G.Form -> E.Value
form f =
    E.string <| case f of
        G.Expanded -> "expanded"
        G.Collapsed -> "collapsed"


zoomKind : G.ZoomKind -> E.Value
zoomKind zk =
    E.string <| case zk of
        G.PlusMinus -> "plusminus"
        G.Steps _ -> "steps"


zoomSteps : G.ZoomKind -> E.Value
zoomSteps zk =
    E.list E.float <| case zk of
        G.PlusMinus -> []
        G.Steps steps -> steps


page : G.Page -> E.Value
page p =
    E.object <| case p of
        G.Page n ->
            [ ( "page", E.string "n" )
            , ( "n", E.int n )
            ]
        G.First ->
            [ ( "page", E.string "first" )
            ]
        G.Last ->
            [ ( "page", E.string "last" )
            ]
        G.ByCurrent ->
            [ ( "face", E.string "current" )
            ]


pages : G.Pages -> E.Value
pages ps =
    E.object <| case ps of
        G.Exact n ->
            [ ( "distribute", E.string "exact" )
            , ( "exact", E.int n )
            ]
        G.Distribute f ->
            [ ( "distribute", E.string "values" )
            , ( "maxInRow", E.int f.maxInRow )
            , ( "maxInColumn", E.int f.maxInColumn )
            ]
        G.Single ->
            [ ( "distribute", E.string "single" )
            ]
        G.Auto ->
            [ ( "distribute", E.string "auto" )
            ]


panel : G.Panel -> E.Value
panel p =
    E.object
        [ ( "form", form p.form )
        , ( "button", face p.button )
        , ( "allOf",
                case p.allOf of
                Just cs -> cellShape cs
                Nothing -> E.null
            )
        , ( "page", page p.page )
        , ( "pages", pages p.pages )
        ]


selectKind : G.SelectKind -> E.Value
selectKind sk =
    case sk of
        G.Choice c ->
            E.object
                [ ( "kind", E.string "choice" )
                , ( "panel", panel c )
                ]
        G.Knob ->
            E.object
                [ ( "kind", E.string "knob" )
                ]
        G.Switch ->
            E.object
                [ ( "kind", E.string "switch" )
                ]


selectItem : G.SelectItem -> E.Value
selectItem si =
    E.object
        [ ( "value", E.string si.value )
        , ( "name",
            case si.name of
                Just n -> E.string n
                Nothing -> E.null
          )
        , ( "face", face si.face )
        ]


property : (a -> E.Value) -> G.Property a -> E.Value
property encodeA ( prop, val ) =
    let
        kind k =
            case k of
                G.Ghost -> "ghost"
                G.NumInt _ -> "int"
                G.NumFloat _ -> "float"
                G.XY _ -> "xy"
                G.Color _ -> "color"
                G.Textual _ -> "text"
                G.Action _ -> "action"
                G.Toggle _ -> "toggle"
                G.Nest _ -> "nest"
                G.Select _ -> "select"
                G.Gradient _ -> "gradient"
                G.Progress _ -> "progress"
                G.Zoom _ -> "zoom"
    in
    E.object
        [ ( "def", def encodeA prop.def )
        , ( "kind", E.string <| kind prop.def )
        , ( "name", E.string prop.name )
        , ( "property", Maybe.withDefault E.null <| Maybe.map E.string prop.property )
        , ( "live", E.bool prop.live )
        , ( "shape", Maybe.withDefault E.null <| Maybe.map cellShape prop.shape )
        , ( "triggerOn", Maybe.withDefault E.null <| Maybe.map (E.list E.string) prop.triggerOn )
        , ( "statePath", Maybe.withDefault E.null <| Maybe.map (E.list E.string) prop.statePath )
        , ( "_value_", encodeA val )
        ]



{-| JSON encoder -}
encode : G.GenUI () -> E.Value
encode =
    encode_ <| always E.null


{-| JSON encoder that includes value in the `value` field -}
encode_ : (a -> E.Value) -> G.GenUI a -> E.Value
encode_ encodeValue genui =
    E.object
        [ ( "version", E.string genui.version  )
        , ( "root", E.list (property encodeValue) genui.root )
        ]