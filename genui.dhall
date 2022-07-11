
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let Theme =
    < Dark
    | Light
    >


let URL =
    < Local : Text
    | Remote : Text
    >


let Icon =
    { theme : Theme
    , url : URL
    }


let Face =
    < Color : Text
    | Icon : List Icon
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
    < Pages : { expand : Bool, face : Face, shape : NestShape.Type, page : Integer }
    | Knob
    | Switch
    >


let SelectItem =
    { value : Text
    , face : Face
    , name : Optional Text
    }


let Color =
    < RGBA : { red : Double, green: Double, blue : Double, alpha : Double }
    | HSLA : { hue : Double, saturation: Double, lightness : Double, alpha : Double }
    -- | HEX : { }
    >


let Gradient =
    < Linear : List { color: Color, position : Double }
    | TwoDimensional : List { color: Color, position : { x : Double, y : Double } }
    {- | Radial :
        { start : { x : Double, y : Double }
        , end : { x : Double, y : Double }
        , stops : List { color: Color, position : Double }
        } -}
    >


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatDef : Type = { min : Double, max : Double, step : Double, current : Double }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ToggleDef : Type = { current : Bool }
let ColorDef : Type = { current : Text }
let TextualDef : Type = { current : Text }
let ActionDef : Type = { face : Face }
let SelectDef : Type = { current : Text, values : List SelectItem, nestProperty : Optional Text, kind : SelectKind }
let NestDef : Type = { face : Face, children : List JSON.Type, expand : Bool, nestProperty : Optional Text, shape : NestShape.Type }
let ProgressDef : Type = { api : URL } -- { cancel : Bool, link : Bool }
let GradientDef : Type = { current : Gradient }


let Def : Type =
    < Ghost
    | NumInt : IntDef
    | NumFloat : FloatDef
    | XY : XYDef
    | Toggle : ToggleDef
    | Color : ColorDef
    | Textual : TextualDef
    | Action : ActionDef
    | Select : SelectDef
    | Nest : NestDef
    | Gradient : GradientDef
    | Progress : ProgressDef
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