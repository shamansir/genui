module GenUI exposing (..)


version : String
version = "0.2"


type Face
    = OfColor String
    | Icon String
    | Default


type alias NestShape =
    { cols : Int
    , rows : Int
    , pages : Int
    }


type alias CellShape =
    { cols : Int
    , rows : Int
    }


type SelectKind
    = Choice { expand : Bool, face : Face }
    | Knob
    | Switch


type alias SelectItem =
    { value : String
    , face : Face
    }


type alias IntDef = {  min : Int, max : Int, step : Int, current : Int }
type alias FloatDef = { min : Float, max : Float, step : Float, current : Float }
type alias XYDef = { x : FloatDef, y : FloatDef }
type alias ToggleDef = { current : Bool }
type alias ColorDef = { current : String }
type alias TextualDef = { current : String }
type alias ActionDef = { face : Face }
type alias SelectDef = { current : String, values : List SelectItem, nestAt : Maybe String, kind : SelectKind, shape : NestShape }
type alias NestDef = { children : List Property, expand : Bool, nestAt : Maybe String, shape : NestShape, face : Face }


type Def
    = NumInt IntDef
    | NumFloat FloatDef
    | XY XYDef
    | Toggle ToggleDef
    | Color ColorDef
    | Textual TextualDef
    | Action ActionDef
    | Select SelectDef
    | Nest NestDef


type alias Property =
    { def : Def
    , name : String
    , property : Maybe String
    , live : Bool
    , shape : Maybe CellShape
    }


type alias GenUI =
    { version : String
    , root : List Property
    }


-- TODO: fold