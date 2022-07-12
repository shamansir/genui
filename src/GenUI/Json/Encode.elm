module GenUI.Json.Encode exposing (encode)


{-| Encoding to JSON

@docs encode
-}


import GenUI as G
import Json.Encode as E


def : G.Def -> E.Value
def d =
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
                [ ( "nestAt", Maybe.withDefault E.null <| Maybe.map E.string nd.nestAt )
                , ( "expand", E.bool nd.expand )
                , ( "children", E.list property nd.children )
                , ( "shape", nestShape nd.shape )
                , ( "face", face nd.face )
                ]
        gradientDef gd =
            E.object
                [
                    ( "current"
                    , case gd.current of
                        G.Linear linear ->
                            E.object
                                [ ( "type", E.string "linear" )
                                , ( "stops", E.list gstop1 linear )
                                ]
                        G.TwoDimensional twod ->
                            E.object
                                [ ( "type", E.string "2d" )
                                , ( "stops", E.list gstop2 twod )
                                ]
                    )
                ]
        progressDef pd =
            E.object
                [ ( "api", url pd.api )
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


cellShape : G.CellShape -> E.Value
cellShape cs =
    E.object
        [ ( "cols", E.int cs.cols )
        , ( "rows", E.int cs.rows )
        ]


nestShape : G.NestShape -> E.Value
nestShape ns =
    E.object
        [ ( "cols", E.int ns.cols )
        , ( "rows", E.int ns.rows )
        , ( "pages", E.int ns.pages )
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


gstop1 : { color : G.Color, position : Float } -> E.Value
gstop1 s =
    E.object
        [ ( "color", color s.color )
        , ( "position", E.float s.position )
        ]


gstop2 : { color : G.Color, position : { x : Float, y : Float } } -> E.Value
gstop2 s =
    E.object
        [ ( "color", color s.color )
        , ( "x", E.float s.position.x )
        , ( "y", E.float s.position.y )
        ]


face : G.Face -> E.Value
face f =
    case f of
        G.OfColor c ->
            E.object
                [ ( "face", E.string "color" )
                , ( "color", color c )
                ]
        G.OfIcon is ->
            E.object
                [ ( "face", E.string "icon" )
                , ( "icons", E.list icon is )
                ]
        G.Default ->
            E.null


selectKind : G.SelectKind -> E.Value
selectKind sk =
    case sk of
        G.Pages c ->
            E.object
                [ ( "kind", E.string "pages" )
                , ( "expand", E.bool c.expand )
                , ( "face", face c.face )
                , ( "shape", nestShape c.shape )
                , ( "page", E.int c.page )
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


property : G.Property -> E.Value
property prop =
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
    in
    E.object
        [ ( "def", def prop.def )
        , ( "kind", E.string <| kind prop.def )
        , ( "name", E.string prop.name )
        , ( "property", Maybe.withDefault E.null <| Maybe.map E.string prop.property )
        , ( "live", E.bool prop.live )
        , ( "shape", Maybe.withDefault E.null <| Maybe.map cellShape prop.shape )
        ]



{-| YAML encoder -}
encode : G.GenUI -> E.Value
encode genui =
    E.object
        [ ( "version", E.string genui.version  )
        , ( "root", E.list property genui.root )
        ]