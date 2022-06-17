
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall



let Face =
    < Color : Text
    | Icon : Text
    | Default
    >


let NestShape =
    { Type =
        { cols : Integer
        , rows : Integer
        , pages : Integer
        }
    , default =
        { cols = +0
        , rows = +0
        , pages = +1
        }
    }


let CellShape =
    { Type =
        { cols : Integer
        , rows : Integer
        }
    , default =
        { cols = +1
        , rows = +1
        }
    }


let SelectKind =
    < Choice : { expand : Bool, face : Face }
    | Knob
    | Switch
    >


let SelectItem =
    { value : Text
    , face : Face
    , name : Optional Text
    }


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatDef : Type = { min : Double, max : Double, step : Double, current : Double }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ToggleDef : Type = { current : Bool }
let ColorDef : Type = { current : Text }
let TextualDef : Type = { current : Text }
let ActionDef : Type = { face : Face }
let SelectDef : Type = { current : Text, values : List SelectItem, nestProperty : Optional Text, kind : SelectKind, shape : NestShape.Type }
let NestDef : Type = { face : Face, children : List JSON.Type, expand : Bool, nestProperty : Optional Text, shape : NestShape.Type }


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
        , property : Optional Text
        , live : Bool
        , shape : Optional CellShape.Type
        }
    , default =
        { property = None Text
        , live = False
        , shape = None CellShape.Type
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
    , NestShape, CellShape, Face, SelectKind, SelectItem
    , IntDef, FloatDef, XYDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef, ToggleDef
    }