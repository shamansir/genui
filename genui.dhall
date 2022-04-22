
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let IntSpec : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatSpec : Type = { min : Natural, max : Natural, step : Natural, current : Natural }
let ColorSpec : Type = { current : Text }
let TextualSpec : Type = { current : Text }
let ActionSpec : Type = {}
let SelectSpec : Type = { current : Text, values : List Text }
let GroupSpec : Type = { children : List JSON.Type, expand : Bool, nest : Optional Text }
let SwitchSpec : Type = { current : Bool }


let Spec : Type =
    < NumInt : IntSpec
    | NumFloat : FloatSpec
    -- TODO: XY
    | Color : ColorSpec
    | Textual : TextualSpec
    | Action : ActionSpec
    | Select : SelectSpec
    | Group : GroupSpec
    | Switch : SwitchSpec
    >


let Property =
    { Type =
        { spec : Spec
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
    , Spec
    , IntSpec, FloatSpec, ColorSpec, TextualSpec, ActionSpec, SelectSpec, GroupSpec, SwitchSpec
    }