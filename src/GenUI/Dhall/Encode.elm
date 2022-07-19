module GenUI.Dhall.Encode exposing (Dhall, encode, toString)


{-| Converting to DHALL representation.

@docs Dhall, encode, toString
-}



import Dict

import GenUI as G

import Util.Indent exposing (Indented, indent, indented)

import GenUI.Color exposing (Color)
import GenUI.Color as Color
import GenUI.Gradient as Gradient


type alias Selects = Dict.Dict String (List G.SelectItem)


noSelects : Selects
noSelects = Dict.empty


selectsBy : String -> List G.SelectItem -> Selects
selectsBy = Dict.singleton


mergeSelects : List Selects -> Selects
mergeSelects = List.foldl Dict.union Dict.empty


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


color : Color -> String
color c =
    case c of
        Color.Rgba rgba ->
            "b._rgba " ++ ff rgba.red ++ " " ++ ff rgba.green ++ " " ++ ff rgba.blue ++ " " ++ ff rgba.alpha
        Color.Hsla hsla ->
            "b._hsla " ++ ff hsla.hue ++ " " ++ ff hsla.saturation ++ " " ++ ff hsla.lightness ++ " " ++ ff hsla.alpha
        Color.Hex hex ->
            "b._hex " ++ q hex


def : String -> String -> G.Def -> Dhall
def propName name d =
    let
        intDef id =
            ( noSelects
            ,
                [ ( 0, "b.int " ++ q name ++ " " ++
                    " { min = " ++ fi id.min ++
                    " , max = " ++ fi id.max ++
                    " , step = " ++ fi id.step ++
                    " , current = " ++ fi id.current ++ "}" ) ]
            )

        floatDef fd =
            ( noSelects
            ,
                [ ( 0, "b.float " ++ q name ++ " " ++
                    " { min = " ++ ff fd.min ++
                    " , max = " ++ ff fd.max ++
                    " , step = " ++ ff fd.step ++
                    " , current = " ++ ff fd.current ++ "}" ) ]
            )

        xyDef xyd =
            ( noSelects
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
            ( noSelects
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
            ( noSelects
            , [ ( 0, "b.color " ++ q name ++ " (" ++ color cd.current ++ ")" ) ]
            )

        textDef cd =
            ( noSelects
            , [ ( 0, "b.text " ++ q name ++ " " ++ q cd.current ) ]
            )

        actionDef ad =
            ( noSelects
            , case ad.face of
                G.Default -> [ ( 0, "b.action " ++ q name ) ]
                _ ->
                    [ ( 0, "b.with_face" )
                    , ( 1, "(b.action " ++ q name ++ ")" )
                    , ( 1, "(")
                    ] ++ face ad.face ++ [ (1, ")") ]
            )

        selectDef sd =
            ( selectsBy propName sd.values
            ,
                [ ( 0, "b.select " ++ q name ++ " " ++ propName ++ "_items " ++ q sd.current ) ]
            )

        nestDef nd =
            let
                children = List.map property nd.children
                selects =
                    List.map Tuple.first children
                    |> mergeSelects
            in

            ( selects
            ,
                [ ( 0, "b.nest" )
                , ( 1, q name )
                , ( 1, "( b.children" )
                ]
                ++ (indent <| array <| List.map Tuple.second children) ++
                [ ( 1, ")")
                , ( 1, case nd.form of
                        G.Expanded -> "b._expanded"
                        G.Collapsed -> "b._collapsed"
                  )
                ]
            )

        gradientDef gd =
            ( noSelects
            , [ ( 0, "b.gradient " ++ q name ++ " " ++ q (Gradient.toString gd.current) ) ] -- FIXME
            )

        progressDef pd =
            ( noSelects
            , [ ( 0, "b.progress " ++ q name ++ " (" ++ url pd.api ++ ")" ) ]
            )

        zoomDef zd =
            ( noSelects
            , [ ( 0, "zoom control, current zoom is " ++ String.fromFloat zd.current ) ] -- FIXME
            )


    in
    case d of
        G.Ghost ->
            ( noSelects, [ ( 0, "b.ghost " ++ name ) ] )

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


cellShape : G.CellShape -> String
cellShape cs =
    " { cols = " ++ fi cs.cols ++
    " , rows = " ++ fi cs.rows ++
    " }"


nestShape : G.NestShape -> String
nestShape ns =
    " { cols = " ++ fi ns.cols ++
    " , rows = " ++ fi ns.rows ++
    " , pages = " ++ fi ns.pages ++
    " }"


array : List Indented -> Indented
array ii =
    (List.indexedMap
        (\idx ind ->
            case List.head ind of
                    Just head ->
                        (head |> Tuple.mapSecond
                            (\str ->
                                (if idx == 0 then "[ " else ", ") ++ str

                            )
                        )
                        :: (List.tail ind |> Maybe.withDefault [])
                        -- |> indent
                    Nothing -> ind
        )
    ii |> List.concat) ++ [ ( 0, "]") ]


face : G.Face -> Indented
face f =
    case f of
        G.OfColor color_ ->
            [ ( 0, "b.color_f (" ++ color color_ ++ ")") ]

        G.OfIcon icons ->
            ( 0, "b.icons_f ")
                :: (indent <| array <| List.map (indented << icon) icons)

        G.Default ->
            [ ( 0, "b.no_face" ) ]

{-
selectKind : G.SelectKind -> Indented
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
            :: indent ([ ( 0, nestShape c.shape ) ])

        G.Knob ->
            [ ( 0, "a switch between values as a knob" ) ]

        G.Switch ->
            [ ( 0, "a switch between values" ) ]


selectItem : G.SelectItem -> String
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
        ++ indent (face si.face) -}


url : G.Url -> String
url u =
    case u of
        G.Local local -> "b._local " ++ local
        G.Remote remote -> "b._remote " ++ remote


icon : G.Icon -> String
icon i =
    let
        themeString =
            case i.theme of
                G.Dark -> "b._dark"
                G.Light -> "b._light"
    in "{ theme = " ++ themeString ++ ", url = " ++ url i.url ++ " }"


property : G.Property -> Dhall
property prop =
    let
        propName = prop.property |> Maybe.withDefault prop.name |> String.replace " " "_"
        ( selects, def_ ) = def propName prop.name prop.def
    in
        ( selects
        , def_ -- FIXME: `bindTo`, `live`, etc.
        )
    {-
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
    -}


{-| Convert UI to DHALL
-}
encode : G.GenUI -> Dhall
encode genui =
    let
        children = List.map property genui.root
        selects =
            List.map Tuple.first children
            |> mergeSelects
    in
        ( selects
        ,
            {- [ (0, "let P = ./genui.dhall") -- FIXME:
            , (0, "let b = ../genui.build.dhall") -- FIXME:
            , (0, "")
            ] ++
            [ (0, "in b.root") ] ++
            (indent <| -}
            array <| List.map Tuple.second children {- )
            ++ [ ( 0, ": P.GenUI" ) ] -}
        )


{-| Convert DHALL to string.
-}
toString : Dhall -> String
toString (selects, children) =
    [ (0, "let P = ./genui.dhall") -- FIXME:
    , (0, "let b = ../genui.build.dhall") -- FIXME:
    , (0, "")
    -- FIXME: add select items
    ] ++
    [ (0, "in b.root") ] ++
    (indent <| children)
    ++ [ ( 0, ": P.GenUI" )
    ]
    |>
    List.map (\( indent_, str ) -> (String.fromList <| List.repeat indent_ ' ') ++ str)
        >> String.join "\n"