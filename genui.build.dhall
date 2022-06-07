let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map

let P = ./genui.dhall
let Property/encode = ./genui.encode.dhall
let VERSION = ./VERSION.dhall


let int
    = \(name : Text) -> \(def : P.IntDef) ->
    P.Property::{ name, def = P.Def.NumInt def }

let float
    = \(name : Text) -> \(def : P.FloatDef) ->
    P.Property::{ name, def = P.Def.NumFloat def }

let xy
    = \(name : Text) -> \(def : P.XYDef) ->
    P.Property::{ name, def = P.Def.XY def }

let color
    = \(name : Text) -> \(def : P.ColorDef) ->
    P.Property::{ name, def = P.Def.Color def }

let color_
    = \(name : Text) -> \(current : Text) ->
    color name { current }

let text
    = \(name : Text) -> \(def : P.TextualDef) ->
    P.Property::{ name, def = P.Def.Textual def }

let text_
    = \(name : Text) -> \(current : Text) ->
    text name { current }

let toggle
    = \(name : Text) -> \(def : P.ToggleDef) ->
    P.Property::{ name, def = P.Def.Toggle def }

let toggle_
    = \(name : Text) -> \(current : Bool) ->
    toggle name { current }

let action
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Action {=} }

let select
    = \(name : Text) -> \(def : P.SelectDef) ->
    P.Property::{ name, def = P.Def.Select def }

let select_
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    select name { values, current }

let nest
    = \(name : Text) -> \(def : P.NestDef) ->
    P.Property::{ name, def = P.Def.Nest def }

let nest_
    = \(name : Text) -> \(children : List JSON.Type) -> \(expand : Bool) ->
    nest name { children, expand, nest = None Text }

let children
    = \(children : List P.Property.Type) ->
    List/map P.Property.Type JSON.Type Property/encode children

let root
    = \(items : List P.Property.Type) ->
    { version = VERSION
    , root = children items
    } : P.GenUI

-- let addIcon
--     = \(url : Text) -> \(toProp : P.Property.Type) ->
--     (toProp // { icon = Some url })


in
    { int, float, xy, color, text, toggle, action, select, nest
    , color_, text_, toggle_, select_, nest_
    , root, children
    }