
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let NestKind =
    < Switch
    | Toggle
    >


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatDef : Type = { min : Double, max : Double, step : Double, current : Double }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ToggleDef : Type = { current : Bool }
let ColorDef : Type = { current : Text }
let TextualDef : Type = { current : Text }
let ActionDef : Type = {}
let SelectDef : Type = { current : Text, values : List Text }
let NestDef : Type = { children : List JSON.Type, expand : Bool, nest : Optional Text }


let Def : Type =
    < NumInt : IntDef
    | NumFloat : FloatDef
    | XY : XYDef
    | Toggle : ToggleDef
    | Color : ColorDef
    | Textual : TextualDef
    | Action : ActionDef
    | Select : SelectDef
    | Nest : NestDef
    >


let Property =
    { Type =
        { def : Def
        , name : Text
        , icon : Optional Text
        , property : Optional Text
        , live : Bool
        }
    , default =
        { icon = None Text
        , property = None Text
        , live = False
        }
    }


let GenUI =
    { version : Text
    , root : List JSON.Type
    }

in
    { GenUI
    , Property
    , Def
    , IntDef, FloatDef, XYDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef, ToggleDef
    }