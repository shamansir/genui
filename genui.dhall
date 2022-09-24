
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
    | NotDefined
    >


let Icon =
    { theme : Theme
    , url : URL
    }


let Face =
    < Empty
    | Color : Color
    | Icon : List Icon
    | Title
    | ExpandCollapse -- expand or collapse arrow
    | Focus -- or selected item, for select box
    >


let Unit =
    < Half
    | One
    | OneAndAHalf
    | Two
    | Three
    | Custom : Double
    >


-- let Units : Type = Double

let Cells : Type = Integer


let Page =
    < First
    | Last
    | ByCurrent -- for `Select` it is the item selected, for nest it is the first or focused one
    | Page : Integer
    >


let Fit =
    { maxInRow : Cells
    , maxInColumn: Cells
    }


let FitColumns =
    { maxInRow : Cells
    }


let FitRows =
    { maxInColumn : Cells
    }


let Pages =
    < Auto
    | Single
    | Distribute : Fit
    | DistributeRows : FitRows
    | DistributeColumns : FitColumns
    | Exact : Integer
    >


let CellShape =
    { Type =
        { horz : Unit
        , vert : Unit
        }
    , default =
        { horz = Unit.One
        , vert = Unit.One
        }
    }


let Form =
    < Expanded
    | Collapsed
    >


let Panel =
    { form : Form
    , button : Face
    , allOf : Optional CellShape.Type
    , page : Page
    , pages : Pages {-, focus : Optional Int -}
    }


let SelectKind =
    < Choice : Panel
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


let IntDef : Type = { min : Integer, max : Integer, step : Integer, current : Integer {-, asText : Bool -} }
let FloatDef : Type = { min : Double, max : Double, step : Double, current : Double {-, asText : Bool -} }
let XYDef : Type = { x : FloatDef, y : FloatDef }
let ToggleDef : Type = { current : Bool }
let ColorDef : Type = { current : Color }
let TextualDef : Type = { current : Text }
let ActionDef : Type = { face : Face }
let SelectDef : Type = { values : List SelectItem, current : Text, nestProperty : Optional Text, kind : SelectKind }
let NestDef : Type = { panel : Panel, children : List JSON.Type, nestProperty : Optional Text }
let ProgressDef : Type = { api : URL } -- { cancel : Bool, link : Bool }
let GradientDef : Type = { current : Gradient, presets : List Color }
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


let Path : Type = List Text


let Property =
    { Type =
        { def : Def
        , name : Text
        , property : Optional Text
        , live : Bool
        , shape : Optional CellShape.Type
        , triggerOn : Optional Path -- trigger property when other property changed
        , statePath : Optional Path -- put the value somewhere else in the state, instead of the property
        }
    , default =
        { property = None Text
        , live = False
        , shape = None CellShape.Type
        , triggerOn = None Path
        , statePath = None Path
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
    , Path
    , Unit, CellShape, Form, Page, Pages, Cells, Face, Panel, SelectKind, SelectItem, ZoomKind, Fit, FitRows, FitColumns
    , Color, RGBAColor, HSLAColor
    , Gradient, Stop, Stop2D
    , URL, Icon, Theme
    , IntDef, FloatDef, XYDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef, ToggleDef, GradientDef, ProgressDef, ZoomDef
    }