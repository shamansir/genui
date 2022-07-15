module GenUI.Json.LoadValues exposing (loadValues)

import GenUI as G
import GenUI.Color as Color exposing (Color)
import GenUI.Gradient as Gradient exposing (Gradient)

import Json.Decode as D


type X
    = XIntV
    | XFloatV
    | XXYV
    | XBoolV
    | XColorV
    | XTextV
    | XSelectV
    | XGradientV
    | XZoomV


type V
    = IntV Int
    | FloatV Float
    | XYV { x : Float, y : Float }
    | BoolV Bool
    | ColorV Color
    | TextV String
    | SelectV String
    | GradientV Gradient
    | ZoomV Float


type alias PPath = List String


loadExpectations : G.GenUI -> List ( PPath, X )
loadExpectations =
    let
        foldF ppath _ prop list =
            case prop.def of
                G.Ghost -> list
                G.NumInt _ -> (ppath, XIntV)::list
                G.NumFloat _ -> (ppath, XFloatV)::list
                G.XY _ -> (ppath, XXYV)::list
                G.Toggle _ -> (ppath, XBoolV)::list
                G.Color _ -> (ppath, XColorV)::list
                G.Gradient _ -> (ppath, XGradientV)::list
                G.Textual _ -> (ppath, XTextV)::list
                G.Action _ -> list
                G.Select _ -> (ppath, XSelectV)::list
                G.Progress _ -> list
                G.Zoom _ -> (ppath, XZoomV)::list
                G.Nest _ -> list -- fold will visit children by itself
    in
        G.foldWithPropPath foldF []


extractExpectations : D.Value -> List ( PPath, X ) -> List ( PPath, Maybe V )
extractExpectations root _ =
    []


applyValues : List ( PPath, V ) -> G.GenUI -> G.GenUI
applyValues updates =
    let
        updateF prop v =
            { prop
            | def =
                case ( prop.def, v ) of
                    ( G.NumInt nd, IntV ci ) ->
                        G.NumInt { nd | current = ci }
                    ( G.NumFloat fd, FloatV cf ) ->
                        G.NumFloat { fd | current = cf }
                    ( G.XY xyd, XYV cxy ) ->
                        let
                            ( xd, yd ) = ( xyd.x, xyd.y )
                        in
                            G.XY
                                { x = { xd | current = cxy.x }
                                , y = { yd | current = cxy.y }
                                }
                    ( G.Toggle bd, BoolV cb ) ->
                        G.Toggle { bd | current = cb }
                    ( G.Color cd, ColorV cc ) ->
                        G.Color { cd | current = cc }
                    ( G.Gradient gd, GradientV cg ) ->
                        G.Gradient { gd | current = cg }
                    ( G.Textual td, TextV ct ) ->
                        G.Textual { td | current = ct }
                    ( G.Select sd, SelectV cs ) ->
                        G.Select { sd | current = cs }
                    ( G.Zoom zd, ZoomV cz ) ->
                        G.Zoom { zd | current = cz }
                    _ -> prop.def
            }
    in G.update
        (\(_, pPath) prop ->
            -- FIXME: veery slow, looks up through the whole list every time
            --        could be solved with `GenUI a` and every property holding a value
            updates
                |> List.foldl
                    (\(otherPath, v) justProp ->
                        if (pPath == otherPath)
                            then Just <| updateF prop v
                            else justProp
                    )
                    (Just prop)

        )


loadValues : D.Value -> G.GenUI -> G.GenUI
loadValues root ui = ui -- TODO: use `D.at`
