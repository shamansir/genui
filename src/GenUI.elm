module GenUI exposing
    ( GenUI
    , version
    , Path, Property, Def(..)
    , Theme(..), Url(..), Icon, Color(..), Gradient(..)
    , Face(..), NestShape, CellShape, SelectKind(..)
    , SelectItem
    , IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef
    , fold, foldWithParent, foldWithPath
    , root, defToString
    )


{-| The core definition of the UI.

# Core

@docs GenUI, version

# Property

@docs Path, Property, root

# Concrete property definitions

@docs Def, IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef

# Folding

@docs fold, foldWithParent, foldWithPath

# Helpers

@docs defToString

# Subtypes

@docs Face, NestShape, CellShape, SelectKind, SelectItem

-}


{-| Current version, to be accessible from code. -}
version : String
version = "2.0.0"


{-| A path to the property in the tree. So, all the first-level properties have the path of `[0]`.
The second property that lies in the folder at index `3` has a path `[0, 3, 1]`. -}
type alias Path = List Int


{-| Icon theme: Light or Dark -}
type Theme
    = Dark
    | Light


{-| Icon URL: Remote or local -}
type Url
    = Local String
    | Remote String


{-| Icon: its theme and URL -}
type alias Icon =
    { theme : Theme
    , url : Url
    }


{-| The face of the UI cell, used for Tron UI. -}
type Face
    = OfColor String
    | OfIcon (List Icon)
    | Default


{-| How many space takes the nested panel, used for Tron UI. -}
type alias NestShape =
    { cols : Int
    , rows : Int
    , pages : Int
    }


{-| How many space takes the cell itself, used for Tron UI. -}
type alias CellShape =
    { cols : Int
    , rows : Int
    }


{-| How the select switch looks and acts, used for Tron UI. -}
type SelectKind
    = Pages { expand : Bool, face : Face, shape : NestShape, page : Int }
    | Knob
    | Switch


{-| The item in the select box, a.k.a. `option`. `value` can be different from `name`, so if `name` exists, `name` should be shown to the user, but the `value` should be sent -}
type alias SelectItem =
    { value : String
    , face : Face
    , name : Maybe String
    }


type Color
    = Rgba { red : Float, green : Float, blue : Float, alpha : Float }
    | Hsla { hue : Float, lighness : Float, alpha : Float }


type Gradient
    = Linear (List { color : Color, position : Float })
    | TwoDimensional (List { color : Color, position : { x : Float, y : Float } })


{-| -}
type alias IntDef = { min : Int, max : Int, step : Int, current : Int }
{-| -}
type alias FloatDef = { min : Float, max : Float, step : Float, current : Float }
{-| -}
type alias XYDef = { x : FloatDef, y : FloatDef }
{-| -}
type alias ToggleDef = { current : Bool }
{-| -}
type alias ColorDef = { current : Color }
{-| -}
type alias TextualDef = { current : String }
{-| -}
type alias ActionDef = { face : Face }
{-| -}
type alias SelectDef = { current : String, values : List SelectItem, nestAt : Maybe String, kind : SelectKind }
{-| -}
type alias NestDef = { children : List Property, expand : Bool, nestAt : Maybe String, shape : NestShape, face : Face }
{-| -}
type alias ProgressDef = { api : Url }
{-| -}
type alias GradientDef = { current : Gradient }


{-| -}
type Def
    = Ghost
    | NumInt IntDef
    | NumFloat FloatDef
    | XY XYDef
    | Toggle ToggleDef
    | Color ColorDef
    | Textual TextualDef
    | Action ActionDef
    | Select SelectDef
    | Nest NestDef
    | Gradient GradientDef
    | Progress ProgressDef

    -- TODO: Gradient
    -- TODO: Progress


{-| -}
type alias Property =
    { def : Def
    , name : String
    , property : Maybe String
    , live : Bool
    , shape : Maybe CellShape
    }


{-| -}
type alias GenUI =
    { version : String
    , root : List Property
    }


{-| Truly optional to use. If you want to attach the controls to some common parrent, this is the way to do it.
Don't use it anywhere in the tree except as in the root. -}
root : Property
root =
    { def = Ghost
    , name = "root"
    , property = Nothing
    , live = False
    , shape = Nothing
    }


{-| Convert kind of the property to string, i.e. returns "int" for integer control and "xy" for XY control. -}
defToString : Def -> String
defToString def =
    case def of
        Ghost -> "ghost"
        NumInt _ -> "int"
        NumFloat _ -> "float"
        XY _ -> "xy"
        Toggle _ -> "toggle"
        Color _ -> "color"
        Textual _ -> "textual"
        Action _ -> "action"
        Select _ -> "select"
        Nest _ -> "nest"
        Gradient _ -> "gradient"
        Progress _ -> "progress"


{-| Fold the interface structure from top to bottom. -}
fold : (Property -> a -> a) -> a -> GenUI -> a
fold =
    foldWithPath << always << always


{-| Fold the interface structure from top to bottom. The first argument is the parent property and the second one is the property being folded itselfs. -}
foldWithParent : (Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithParent =
    foldWithPath << always


{-| Fold the interface structure from top to bottom. The function gets path and the parent property and the second argument and the third one is the property being folded itselfs. -}
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
