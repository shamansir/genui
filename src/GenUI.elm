module GenUI exposing
    ( GenUI, version
    , Path, Property, root
    , Def(..), IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef
    , fold, foldWithParent, foldWithPath, foldWithPropPath, foldWithPaths
    , find, findByIndices, update, updateAt
    , defToString
    , Face(..), NestShape, CellShape, SelectKind(..), SelectItem
    , Form(..), GradientDef, Icon, ProgressDef, PropPath, Theme(..), Url(..), ZoomDef, ZoomKind(..)
    )

{-| The core definition of the UI.


# Core

@docs GenUI, version


# Property

@docs Path, Property, root


# Concrete property definitions

@docs Def, IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef


# Folding

@docs fold, foldWithParent, foldWithPath, foldWithPropPath, foldWithPaths


# Find & Update

@docs find, findP, update


# Helpers

@docs defToString


# Subtypes

@docs Face, NestShape, CellShape, SelectKind, SelectItem

-}

import GenUI.Color exposing (Color(..))
import GenUI.Gradient exposing (Gradient(..), Stop, Stop2D)


{-| Current version, to be accessible from code.
-}
version : String
version =
    "2.0.0"


{-| A path to the property in the tree. So, all the first-level properties have the path of `[0]`.
The second property that lies in the folder at index `3` has a path `[0, 3, 1]`.
-}
type alias Path =
    List Int


{-| A path to the property in the tree. So, all the first-level properties have the path of `[0]`.
The second property that lies in the folder at index `3` has a path `[0, 3, 1]`.
-}
type alias PropPath =
    List String


{-| Icon theme: Light or Dark
-}
type Theme
    = Dark
    | Light


{-| Icon URL: Remote or local
-}
type Url
    = Local String
    | Remote String


{-| Icon: its theme and URL
-}
type alias Icon =
    { theme : Theme
    , url : Url
    }


{-| The face of the UI cell, used for Tron UI.
-}
type Face
    = OfColor Color
    | OfIcon (List Icon)
    | Default


{-| How many space takes the nested panel, used for Tron UI.
-}
type alias NestShape =
    { cols : Int
    , rows : Int
    , pages : Int
    }


{-| How many space takes the cell itself, used for Tron UI.
-}
type alias CellShape =
    { cols : Int
    , rows : Int
    }


{-| How the select switch looks and acts, used for Tron UI.
-}
type SelectKind
    = Choice { form : Form, face : Face, shape : NestShape, page : Int }
    | Knob
    | Switch


{-| The item in the select box, a.k.a. `option`. `value` can be different from `name`, so if `name` exists, `name` should be shown to the user, but the `value` should be sent
-}
type alias SelectItem =
    { value : String
    , face : Face
    , name : Maybe String
    }


{-| -}
type Form
    = Expanded
    | Collapsed


{-| -}
type ZoomKind
    = PlusMinus
    | Steps (List Float)


{-| -}
type alias IntDef =
    { min : Int, max : Int, step : Int, current : Int }


{-| -}
type alias FloatDef =
    { min : Float, max : Float, step : Float, current : Float }


{-| -}
type alias XYDef =
    { x : FloatDef, y : FloatDef }


{-| -}
type alias ToggleDef =
    { current : Bool }


{-| -}
type alias ColorDef =
    { current : Color }


{-| -}
type alias TextualDef =
    { current : String }


{-| -}
type alias ActionDef =
    { face : Face }


{-| -}
type alias SelectDef =
    { current : String, values : List SelectItem, nestAt : Maybe String, kind : SelectKind }


{-| -}
type alias NestDef =
    { children : List Property, form : Form, nestAt : Maybe String, shape : NestShape, face : Face, page : Int }


{-| -}
type alias ProgressDef =
    { api : Url }


{-| -}
type alias ZoomDef =
    { current : Float, kind : ZoomKind }


{-| -}
type alias GradientDef =
    { current : Gradient }


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
    | Zoom ZoomDef


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
Don't use it anywhere in the tree except as in the root.
-}
root : Property
root =
    { def = Ghost
    , name = "root"
    , property = Nothing
    , live = False
    , shape = Nothing
    }


{-| Convert kind of the property to string, i.e. returns "int" for integer control and "xy" for XY control.
-}
defToString : Def -> String
defToString def =
    case def of
        Ghost ->
            "ghost"

        NumInt _ ->
            "int"

        NumFloat _ ->
            "float"

        XY _ ->
            "xy"

        Toggle _ ->
            "toggle"

        Color _ ->
            "color"

        Textual _ ->
            "textual"

        Action _ ->
            "action"

        Select _ ->
            "select"

        Nest _ ->
            "nest"

        Gradient _ ->
            "gradient"

        Progress _ ->
            "progress"

        Zoom _ ->
            "zoom"


{-| Fold the interface structure from top to bottom.
-}
fold : (Property -> a -> a) -> a -> GenUI -> a
fold =
    foldWithPath << always << always


{-| Fold the interface structure from top to bottom. The first argument is the parent property and the second one is the property being folded itselfs.
-}
foldWithParent : (Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithParent =
    foldWithPath << always


{-| Fold the interface structure from top to bottom. The function gets path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithPath : (Path -> Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithPath f =
    foldWithPaths (f << Tuple.first)


{-| Fold the interface structure from top to bottom. The function gets property-path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithPropPath : (PropPath -> Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithPropPath f =
    foldWithPaths (f << Tuple.second)


{-| Fold the interface structure from top to bottom. The function gets index-path, property-name-path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithPaths : (( Path, PropPath ) -> Maybe Property -> Property -> a -> a) -> a -> GenUI -> a
foldWithPaths f a =
    let
        foldProperty ( iPath, sPath ) parent prop ( index, a_ ) =
            ( index + 1
            , let
                curPath =
                    ( iPath ++ [ index ]
                    , sPath
                        ++ [ prop.property |> Maybe.withDefault prop.name ]
                    )
              in
              case prop.def of
                Nest nestDef ->
                    f curPath parent prop <|
                        Tuple.second <|
                            List.foldl
                                (foldProperty curPath <| Just prop)
                                ( 0, a_ )
                            <|
                                nestDef.children

                _ ->
                    f curPath parent prop a_
            )
    in
    Tuple.second
        << List.foldl (foldProperty ( [], [] ) Nothing) ( 0, a )
        << .root


{-| Find property by index-based path. Traverses/folds the tree, so could be slow for a complex structure
-}
findByIndices : Path -> GenUI -> Maybe Property
findByIndices iPath =
    foldWithPath
        (\oPath _ prop foundBefore ->
            case foundBefore of
                Just found ->
                    Just found

                Nothing ->
                    if oPath == iPath then
                        Just prop

                    else
                        Nothing
        )
        Nothing


{-| Find property by property-based path. Traverses/folds the tree, so could be slow for a complex structure
-}
find : PropPath -> GenUI -> Maybe Property
find pPath =
    foldWithPropPath
        (\oPath _ prop foundBefore ->
            case foundBefore of
                Just found ->
                    Just found

                Nothing ->
                    if oPath == pPath then
                        Just prop

                    else
                        Nothing
        )
        Nothing


{-| Update every property in the tree by applying the given function to it. If the function returns `Nothing`, the property is removed, even if it's a nesting.
-}
update : (( Path, PropPath ) -> Property -> Maybe Property) -> GenUI -> GenUI
update f gui =
    let
        foldProperty ( iPath, sPath ) prop ( index, prev ) =
            ( index + 1
            , (let
                curPath =
                    ( iPath ++ [ index ]
                    , sPath
                        ++ [ prop.property |> Maybe.withDefault prop.name ]
                    )
               in
               case prop.def of
                Nest nestDef ->
                    case f curPath prop of
                        -- if the property at this path stayed
                        Just nextProp ->
                            case nextProp.def of
                                -- and it is still a nested property
                                Nest nextDef ->
                                    -- then recusively update its children
                                    Just <|
                                        { nextProp
                                            | def =
                                                Nest
                                                    { nextDef
                                                        | children =
                                                            nestDef.children
                                                                |> List.foldl (foldProperty curPath) ( 0, [] )
                                                                |> Tuple.second
                                                                |> List.filterMap identity
                                                    }
                                        }

                                -- or else just leave as the new one
                                _ ->
                                    Just nextProp

                        -- if property at this point is removed, no sense in updating it
                        Nothing ->
                            Nothing

                _ ->
                    f curPath prop
              )
                :: prev
            )
    in
    { version = gui.version
    , root =
        gui.root
            |> List.foldl (foldProperty ( [], [] )) ( 0, [] )
            |> Tuple.second
            |> List.filterMap identity
    }


{-| Find property by property-based path and update it with given function.
The function gets `Nothing` if the property wasn't found at path.
Traverses/folds the tree, so could be slow for a complex structure
-}
updateAt : PropPath -> (Property -> Maybe Property) -> GenUI -> GenUI
updateAt pPath f =
    update
        (\(_, otherPath) prop ->
            if (pPath == otherPath) then f prop
            else Just prop
        )