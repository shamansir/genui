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
extractExpectations _ _ = []


applyValues : List ( PPath, V ) -> G.GenUI -> G.GenUI
applyValues _ ui = ui


loadValues : D.Value -> G.GenUI -> G.GenUI
loadValues root ui = ui
