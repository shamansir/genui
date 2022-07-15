
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let RGBAColor = { red : Double, green: Double, blue : Double, alpha : Double }


let HSLAColor = { hue : Double, saturation: Double, lightness : Double, alpha : Double }


let Color =
    < RGBA : RGBAColor
    | HSLA : HSLAColor
    | HEX : Text
    >


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
    < Color : Color
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

let NestForm =
    < Expanded
    | Collapsed
    >


let Choice =
    { form : NestForm, face : Face, shape : NestShape.Type, page : Integer }


let SelectKind =
    < Choice : Choice
    | Knob
    | Switch
    >


let SelectItem =
    { value : Text
    , face : Face
    , name : Optional Text
    }


let Stop =
    { color: Color, position : Double }


let Stop2D =
    { color: Color, position : { x : Double, y : Double } }


let Gradient =
    < Linear : List Stop
    | TwoDimensional : List Stop2D
    {- | Radial :
        { start : { x : Double, y : Double }
        , end : { x : Double, y : Double }
        , stops : List { color: Color, position : Double }
        } -}
    >

let ZoomKind =
    < PlusMinus
    | Steps : List Double
    >


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer }
let FloatDef : Type = { min : Double, max : Double, step : Double, current : Double }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ToggleDef : Type = { current : Bool }
let ColorDef : Type = { current : Color }
let TextualDef : Type = { current : Text }
let ActionDef : Type = { face : Face }
let SelectDef : Type = { current : Text, values : List SelectItem, nestProperty : Optional Text, kind : SelectKind }
let NestDef : Type = { face : Face, children : List JSON.Type, form : NestForm, nestProperty : Optional Text, shape : NestShape.Type, page : Integer }
let ProgressDef : Type = { api : URL } -- { cancel : Bool, link : Bool }
let GradientDef : Type = { current : Gradient }
let ZoomDef : Type = { current : Double, kind : ZoomKind }


let Def : Type =
    < Ghost
    | NumInt : IntDef
    | NumFloat : FloatDef
    | XY : XYDef
    | Toggle : ToggleDef
    | Color : ColorDef
    | Textual : TextualDef
    | Action : ActionDef
    | Zoom : ZoomDef
    | Progress : ProgressDef
    | Gradient : GradientDef
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
    , NestShape, CellShape, NestForm, Face, SelectKind, SelectItem, Choice, ZoomKind
    , Color, RGBAColor, HSLAColor
    , Gradient, Stop, Stop2D
    , URL, Icon, Theme
    , IntDef, FloatDef, XYDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef, ToggleDef, GradientDef, ProgressDef, ZoomDef
    }