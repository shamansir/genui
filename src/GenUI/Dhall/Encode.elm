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


def : String -> String -> G.Def a -> Dhall
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
                G.Empty -> [ ( 0, "b.action " ++ q name ) ]
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
                ++ (indent <| indent <| array <| List.map Tuple.second children) ++
                [ ( 1, ")")
                , ( 1, case nd.panel.form of
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
            , [ ( 0, "b.zoom " ++ q name ) ] -- FIXME
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
    " { horz = " ++ unit cs.horz ++
    " , vert = " ++ unit cs.vert ++
    " }"


unit : G.Unit -> String
unit u =
    case u of
        G.Half -> "b._half"
        G.One -> "b._one"
        G.OneAndAHalf -> "b._one_and_half"
        G.Two -> "b._two"
        G.Three -> "b._three"
        G.Custom n -> "(b._unit " ++ ff n ++ ")"


pages : G.Pages -> String
pages ps =
    case ps of
        G.Auto -> "b._auto"
        G.Single -> "b._single"
        G.Distribute fit -> "(b._distribute { maxInRow = " ++ fi fit.maxInRow ++ ", maxInColumn = " ++ fi fit.maxInColumn ++ "})"
        G.Exact n -> "(b._pages " ++ fi n ++ ")"


page : G.Page -> String
page p =
    case p of
        G.First -> "b._first"
        G.Last -> "b._last"
        G.ByCurrent -> "b._by_current"
        G.Page n -> "(b._page " ++ fi n ++ ")"


form : G.Form -> String
form f =
    case f of
        G.Expanded -> "b._expanded"
        G.Collapsed -> "b._collapsed"


panel : G.Panel -> Indented
panel p =
       ( 0, "{ form = " ++ form p.form)
    :: ( 0, ", button = ")
    :: indent (face p.button)
    ++ [
        ( 0, ", allOf = " ++
            case p.allOf of
                Just cs -> "Some (" ++ cellShape cs ++ ")"
                Nothing -> "b._no_chsape"
        )
    , ( 0, ", page = " ++ page p.page )
    , ( 0, ", pages = " ++ pages p.pages )
    ]


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
            [ ( 0, "b._color_f (" ++ color color_ ++ ")") ]

        G.OfIcon icons ->
            ( 0, "b._icons_f ")
                :: (indent <| array <| List.map (indented << icon) icons)

        G.Empty ->
            [ ( 0, "b._empty_f" ) ]

        G.Title ->
            [ ( 0, "b._title_f" ) ]

        G.PanelExpandStatus ->
            [ ( 0, "b._show_expand_f" ) ]

        G.PanelFocusedItem ->
            [ ( 0, "b._show_focus_f" ) ]


selectItems : ( String, List G.SelectItem ) -> String
selectItems ( propName, items ) =
    "let " ++ propName ++ "_items = [ " ++ (String.join ", " <| List.map (q << .value) items) ++ " ]"


url : G.Url -> String
url u =
    case u of
        G.Local local -> "b._local " ++ q local
        G.Remote remote -> "b._remote " ++ q remote


icon : G.Icon -> String
icon i =
    let
        themeString =
            case i.theme of
                G.Dark -> "b._dark"
                G.Light -> "b._light"
    in "{ theme = " ++ themeString ++ ", url = " ++ url i.url ++ " }"


property : G.Property a -> Dhall
property ( prop, _ ) =
    let
        propName = prop.property |> Maybe.withDefault prop.name |> String.replace " " "_"
        ( selects, def_ ) = def propName prop.name prop.def
    in
        ( selects
        , case prop.property of
            Just boundTo ->
                def_ ++ [ (1, "// bindTo " ++ q boundTo) ]
                 -- FIXME: `live`, etc.
            Nothing -> def_
        )


{-| Convert UI to DHALL
-}
encode : G.GenUI a -> Dhall
encode genui =
    let
        children = List.map property genui.root
        selects =
            List.map Tuple.first children
            |> mergeSelects
    in
        ( selects
        , array <| List.map Tuple.second children
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
        (Dict.toList selects
            |> List.map selectItems
            |> List.map indented
            |> List.concat
        )
    ++ (0, "in b.root")
    :: (indent <| children)
    ++ [ ( 0, ": P.GenUI" )
    ]
    |>
    List.map (\( indent_, str ) -> (String.fromList <| List.repeat (indent_ * 4) ' ') ++ str)
        >> String.join "\n"