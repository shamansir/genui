
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatDef : Type = { min : Natural, max : Natural, step : Natural, current : Natural }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ColorDef : Type = { current : Text }
let TextualDef : Type = { current : Text }
let ActionDef : Type = {}
let SelectDef : Type = { current : Text, values : List Text }
let GroupDef : Type = { children : List JSON.Type, expand : Bool, nest : Optional Text }
let SwitchDef : Type = { current : Bool }


let Def : Type =
    < NumInt : IntDef
    | NumFloat : FloatDef
    | XY : XYDef
    | Color : ColorDef
    | Textual : TextualDef
    | Action : ActionDef
    | Select : SelectDef
    | Group : GroupDef
    | Switch : SwitchDef
    >


let Property =
    { Type =
        { def : Def
        , name : Text
        , icon : Optional Text
        , property : Optional Text
        }
    , default =
        { icon = None Text
        , property = None Text
        }
    }

in
    { Property
    , Def
    , IntDef, FloatDef, XYDef, ColorDef, TextualDef, ActionDef, SelectDef, GroupDef, SwitchDef
    }