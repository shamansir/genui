module GenUI exposing
    ( GenUI
    , version
    , Path, Property, Def(..)
    , Face(..), NestShape, CellShape, SelectKind(..)
    , SelectItem
    , IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef
    , fold, foldWithPath
    , root, defToString
    )


version : String
version = "0.2"


type alias Path = List Int


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
    , name : Maybe String
    }


type alias IntDef = { min : Int, max : Int, step : Int, current : Int }
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
    | Root
    -- TODO: Gradient
    -- TODO: Progress


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


root : Property
root =
    { def = Root
    , name = "root"
    , property = Nothing
    , live = False
    , shape = Nothing
    }


defToString : Def -> String
defToString def =
    case def of
        Root -> "root"
        NumInt _ -> "int"
        NumFloat _ -> "float"
        XY _ -> "xy"
        Toggle _ -> "toggle"
        Color _ -> "color"
        Textual _ -> "textual"
        Action _ -> "action"
        Select _ -> "select"
        Nest _ -> "nest"


-- TODO: fold

fold : (Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
fold =
    foldWithPath << always


foldWithPath : (Path -> Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithPath f a =
    let
        foldProperty parentPath parent prop (index, a_) =
            ( index + 1
            ,
                let
                    curPath = parentPath ++ [index]
                in case prop.def of
                    Nest nestDef ->
                        f curPath parent prop
                            <| Tuple.second
                            <| List.foldl
                                (foldProperty curPath <| Just prop)
                                (0, a_)
                            <| nestDef.children
                    _ -> f curPath parent prop a_
            )
    in Tuple.second
        << List.foldl (foldProperty [] Nothing) (0, a)
        << .root
