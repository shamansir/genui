let P = ./genui.dhall

let int
    = \(name : Text) -> \(current : Integer) -> \(min : Integer) -> \(max : Integer) -> \(step : Integer) ->
    P.Property::{ name, def = P.Def.NumInt { min, max, step, current } }

let float
    = \(name : Text) -> \(def : P.FloatDef) ->
    P.Property::{ name, def = P.Def.NumFloat def }

let xy
    = \(name : Text) -> \(def : P.XYDef) ->
    P.Property::{ name, def = P.Def.XY def }

let color
    = \(name : Text) -> \(def : P.ColorDef) ->
    P.Property::{ name, def = P.Def.Color def }

-- let addIcon
--     = \(url : Text) -> \(toProp : P.Property.Type) ->
--     (toProp // { icon = Some url })


in { int, float, xy, color }