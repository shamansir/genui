module GenUI.Json.Encode exposing (..)


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
                [ ( "current", E.string cd.current )
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
                , ( "shape", nestShape sd.shape )
                ]
        nestDef nd =
            E.object
                [ ( "nestAt", Maybe.withDefault E.null <| Maybe.map E.string nd.nestAt )
                , ( "expand", E.bool nd.expand )
                , ( "children", E.list property nd.children )
                , ( "shape", nestShape nd.shape )
                , ( "face", face nd.face )
                ]
    in case d of
        G.Root -> E.object []
        G.NumInt id -> intDef id
        G.NumFloat fd -> floatDef fd
        G.XY xyd -> xyDef xyd
        G.Toggle td -> toggleDef td
        G.Color cd -> colorDef cd
        G.Textual td -> textDef td
        G.Action ad -> actionDef ad
        G.Select sd -> selectDef sd
        G.Nest nd -> nestDef nd


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


face : G.Face -> E.Value
face f =
    case f of
        G.OfColor color ->
            E.object
                [ ( "face", E.string "color" )
                , ( "color", E.string color )
                ]
        G.Icon icon ->
            E.object
                [ ( "face", E.string "icon" )
                , ( "icon", E.string icon )
                ]
        G.Default ->
            E.null


selectKind : G.SelectKind -> E.Value
selectKind sk =
    case sk of
        G.Choice c ->
            E.object
                [ ( "kind", E.string "choice" )
                , ( "expand", E.bool c.expand )
                , ( "face", face c.face )
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
                G.Root -> "root"
                G.NumInt _ -> "int"
                G.NumFloat _ -> "float"
                G.XY _ -> "xy"
                G.Color _ -> "color"
                G.Textual _ -> "text"
                G.Action _ -> "action"
                G.Toggle _ -> "toggle"
                G.Nest _ -> "nest"
                G.Select _ -> "select"
    in
    E.object
        [ ( "def", def prop.def )
        , ( "kind", E.string <| kind prop.def )
        , ( "name", E.string prop.name )
        , ( "property", Maybe.withDefault E.null <| Maybe.map E.string prop.property )
        , ( "live", E.bool prop.live )
        , ( "shape", Maybe.withDefault E.null <| Maybe.map cellShape prop.shape )
        ]


encode : G.GenUI -> E.Value
encode genui =
    E.object
        [ ( "version", E.string genui.version  )
        , ( "root", E.list property genui.root )
        ]