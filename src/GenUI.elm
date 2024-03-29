module GenUI exposing
    ( GenUI, version
    , Path, IndexPath, PropertyRec, Property, root, ghost, get
    , Def(..), IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, SelectDef, NestDef
    , fold, foldWithParent, foldWithPath, foldWithIndexPath, foldWithPaths
    , find, findByIndices, update, updateAt
    , withPath, withIndices, defToString
    , Panel, Unit(..), CellShape, Page(..), Pages(..), Cells, Face(..), SelectKind(..), SelectItem
    , Form(..), GradientDef, Icon, ProgressDef, Theme(..), Url(..), ZoomDef, ZoomKind(..)
    , map, mapProperty, mapDef
    )

{-| The core definition of the UI.


# Core

@docs GenUI, version


# Property

@docs PropertyRec, Property, root, ghost, Path, IndexPath, get


# Concrete property definitions

@docs Def, IntDef, FloatDef, XYDef, ToggleDef, ColorDef, TextualDef, ActionDef, GradientDef, ProgressDef, ZoomDef, SelectDef, NestDef


# Folding

@docs fold, foldWithParent, foldWithPath, foldWithIndexPath, foldWithPaths


# Find & Update

@docs find, findByIndices, update, updateAt


# Helpers

@docs withPath, withIndices, defToString


# Subtypes

@docs Face, Unit, CellShape, SelectKind, SelectItem, Icon, Form, Theme, Url, Page, Pages, Panel, Cells, ZoomKind

# Mapping
@docs map, mapProperty, mapDef

-}


import GenUI.Color exposing (Color(..))
import GenUI.Gradient exposing (Gradient(..), Stop, Stop2D)


{-| Current version, to be accessible from code.
-}
version : String
version =
    "5.0.0"


{-| A path to the property in the tree. So, all the first-level properties have the path of `[0]`.
The second property that lies in the folder at index `3` has a path `[0, 3, 1]`.
-}
type alias IndexPath =
    List Int


{-| A path to the property in the tree. So, all the first-level properties have the path of `[0]`.
The second property that lies in the folder at index `3` has a path `[0, 3, 1]`.
-}
type alias Path =
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
    = Empty
    | OfColor Color
    | OfIcon (List Icon)
    | Title
    | ExpandCollapse -- expand or collapse arrow
    | Focus -- or selected item, for select box


{-| How much space takes the control in the Tron units -}
type Unit
    = Half
    | One
    | OneAndAHalf
    | Two
    | Three
    | Custom Float


{-| The number of cells as the dimension of the panel -}
type alias Cells = Int



{-| Which page should be selected on the panel, if there's paging enabled -}
type Page
    = First
    | Last
    | ByCurrent
    | Page Int



{-| How to distribute items over pages:

* `Single` page to fit them into page no matter what;
* `Distribute` is for custom distribution using `maxInRow` and `maxInColumn` (both in Cells, integer number);
* `Auto` to use the default paging algorithm == `Distribute { maxInRow = 3, maxInColumn = 3 }`;
* `Exact` for the exact number of pages and skipping the items that don't fit or having blank pages if they do;
-}
type Pages
    = Auto
    | Single
    | Distribute
        { maxInColumn: Cells
        , maxInRow : Cells
        } -- a.k.a. Fit
    | Exact Int


{-| How many space takes the cell itself, used for Tron UI.
-}
type alias CellShape =
    { horz : Unit
    , vert : Unit
    }


{-| How the select switch looks and acts, used for Tron UI.
-}
type SelectKind
    = Choice Panel
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
type alias Panel =
    { form : Form
    , button : Face
    , allOf : Maybe CellShape
    , page : Page
    , pages : Pages {-, focus : Optional Int -}
    }


{-| -}
type alias SelectDef =
    { current : String, values : List SelectItem, nestAt : Maybe String, kind : SelectKind }


{-| -}
type alias NestDef a =
    { children : List (Property a), nestAt : Maybe String, panel : Panel }


{-| -}
type alias ProgressDef =
    { api : Url }


{-| -}
type alias ZoomDef =
    { current : Float, kind : ZoomKind }


{-| -}
type alias GradientDef =
    { current : Gradient, presets : List Color }


{-| -}
type Def a
    = Ghost
    | NumInt IntDef
    | NumFloat FloatDef
    | XY XYDef
    | Toggle ToggleDef
    | Color ColorDef
    | Textual TextualDef
    | Action ActionDef
    | Select SelectDef
    | Nest (NestDef a)
    | Gradient GradientDef
    | Progress ProgressDef
    | Zoom ZoomDef


{-| -}
type alias PropertyRec a =
    { def : Def a
    , name : String
    , property : Maybe String
    , live : Bool
    , shape : Maybe CellShape -- FIXME: doesn't represent what's needed when used with TronGUI
    , triggerOn : Maybe Path
    , statePath : Maybe Path
    }


{-| -}
type alias Property a =
    ( PropertyRec a
    , a
    )


{-| -}
type alias GenUI a =
    { version : String
    , root : List (Property a)
    }


{-| Get value of the property -}
get : Property a -> a
get = Tuple.second


{-| Truly optional to use. If you want to attach the controls to some common parrent, this is the way to do it.
Don't use it anywhere in the tree except as in the root.
-}
root : a -> Property a
root =
    ghost "root"


{-| Create ghost with given name -}
ghost : String -> a -> Property a
ghost name a =
    (
        { def = Ghost
        , name = name
        , property = Nothing
        , live = False
        , shape = Nothing
        , triggerOn = Nothing
        , statePath = Nothing
        }
    , a
    )


{-| Convert kind of the property to string, i.e. returns "int" for integer control and "xy" for XY control.
-}
defToString : Def a -> String
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
fold : (Property a -> x -> x) -> x -> GenUI a -> x
fold =
    foldWithPath << always << always


{-| Fold the interface structure from top to bottom. The first argument is the parent property and the second one is the property being folded itselfs.
-}
foldWithParent : (Maybe (Property a) -> Property a -> x -> x) -> x -> GenUI a -> x
foldWithParent =
    foldWithPath << always


{-| Fold the interface structure from top to bottom. The function gets property-path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithPath : (Path -> Maybe (Property a) -> Property a -> x -> x) -> x -> GenUI a -> x
foldWithPath f =
    foldWithPaths (f << Tuple.second)


{-| Fold the interface structure from top to bottom. The function gets path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithIndexPath : (IndexPath -> Maybe (Property a) -> Property a -> x -> x) -> x -> GenUI a -> x
foldWithIndexPath f =
    foldWithPaths (f << Tuple.first)



{-| Fold the interface structure from top to bottom. The function gets index-path, property-name-path and the parent property and the second argument and the third one is the property being folded itself.
-}
foldWithPaths : (( IndexPath, Path ) -> Maybe (Property a) -> Property a -> x -> x) -> x -> GenUI a -> x
foldWithPaths f x =
    let
        foldProperty ( iPath, sPath ) parent ( prop, a ) ( index, x_ ) =
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
                    f curPath parent ( prop, a ) <|
                        Tuple.second <|
                            List.foldl
                                (foldProperty curPath <| Just ( prop, a ))
                                ( 0, x_ )
                            <|
                                nestDef.children

                _ ->
                    f curPath parent ( prop, a ) x_
            )
    in
    Tuple.second
        << List.foldl (foldProperty ( [], [] ) Nothing) ( 0, x )
        << .root


{-| Find property by index-based path. Traverses/folds the tree, so could be slow for a complex structure
-}
findByIndices : Path -> GenUI a -> Maybe (Property a)
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
find : Path -> GenUI a -> Maybe (Property a)
find pPath =
    foldWithPath
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


{-| Add path information to every property -}
withPath : GenUI a -> GenUI ( (IndexPath, Path), a )
withPath =
    update <| \paths -> Just << mapProperty (Tuple.pair paths)


{-| Update every property in the tree by applying the given function to it. If the function returns `Nothing`, the property is removed, even if it's a nesting.
-}
update : (( IndexPath, Path ) -> Property a -> Maybe (Property b)) -> GenUI a -> GenUI b
update f gui =
    let
        foldProperty ( parentIndexPath, sPath ) ( index, ( prop, a ) ) prev =
            (let
                    curIndexPath = parentIndexPath ++ [ index ]
                    curPropPath = sPath
                            ++ [ prop.property |> Maybe.withDefault prop.name ]
                    curPath =
                        ( curIndexPath
                        , curPropPath
                        )
                in
                case prop.def of
                    Nest nestDef ->
                        case f curPath ( prop, a ) of
                            -- if the property at this path stayed
                            Just ( nextProp, ia ) ->
                                case nextProp.def of
                                    -- and it is still a nested property
                                    Nest nextDef ->
                                        -- then recusively update its children
                                        Just <|
                                            (
                                                { nextProp
                                                | def =
                                                    Nest
                                                        { nextDef
                                                            | children =
                                                                nestDef.children
                                                                    |> List.indexedMap Tuple.pair
                                                                    |> List.foldl (foldProperty curPath) []
                                                                    |> List.reverse
                                                                    |> List.filterMap identity
                                                        }
                                                }
                                            , ia )

                                    -- or else just leave as the new one
                                    _ ->
                                        Just ( nextProp, ia )

                            -- if property at this point is removed, no sense in updating it
                            Nothing ->
                                Nothing

                    _ ->
                        f curPath ( prop, a )
                )
                :: prev
    in
    { version = gui.version
    , root =
        gui.root
            |> List.indexedMap Tuple.pair
            |> List.foldl (foldProperty ( [], [] )) []
            |> List.reverse
            |> List.filterMap identity
    }


{-| Find property by property-based path and update it with given function.
The function gets `Nothing` if the property wasn't found at path.
Traverses/folds the tree, so could be slow for a complex structure
-}
updateAt : Path -> (Property a -> Maybe (Property a)) -> GenUI a -> GenUI a
updateAt pPath f =
    update
        (\(_, otherPath) prop ->
            if (pPath == otherPath) then f prop
            else Just prop
        )


{-| Add unique numeric index to every property / control.
-}
withIndices : GenUI a -> GenUI ( Int, a )
withIndices gui =
    let
        foldProperties : Property a -> ( Int, List (Property (Int, a)) ) -> ( Int, List (Property (Int, a)) )
        foldProperties ( prop, a ) ( index, prev ) =
            let
                ( nextIndex, nextChildren ) =
                    case prop.def of
                        Nest nestDef ->
                            nestDef.children
                                |> List.foldl foldProperties ( index, [] )
                                |> Tuple.mapSecond List.reverse
                        _ -> ( index, [] )
            in
                ( nextIndex + 1
                ,
                    ( case prop.def of
                        Nest nestDef ->

                            { name = prop.name
                            , property = prop.property
                            , live = prop.live
                            , shape = prop.shape
                            , def =
                                Nest
                                    { children = nextChildren
                                    , panel = nestDef.panel
                                    , nestAt = nestDef.nestAt
                                    }
                            , triggerOn = prop.triggerOn
                            , statePath = prop.statePath
                            }
                        _ ->
                            { name = prop.name
                            , property = prop.property
                            , live = prop.live
                            , shape = prop.shape
                            , def = prop.def |> mapDef (Tuple.pair nextIndex)
                            , triggerOn = prop.triggerOn
                            , statePath = prop.statePath
                            }
                    , ( nextIndex, a ) )
                    :: prev
                )
    in
    { version = gui.version
    , root =
        gui.root
            |> List.foldl foldProperties ( 0, [] )
            |> Tuple.second
            |> List.reverse
    }


{-| -}
map : (a -> b) -> GenUI a -> GenUI b
map f genui =
    { version = genui.version
    , root = List.map (mapProperty f) genui.root
    }


{-| -}
mapProperty : (a -> b) -> Property a -> Property b
mapProperty f ( prop, a ) =
    (
        { def =
            mapDef f prop.def
        , name = prop.name
        , property = prop.property
        , live = prop.live
        , shape = prop.shape
        , triggerOn = prop.triggerOn
        , statePath = prop.statePath
        }
    , f a
    )


{-| -}
mapDef : (a -> b) -> Def a -> Def b
mapDef f def =
    case def of
        Ghost -> Ghost
        NumInt intDef -> NumInt intDef
        NumFloat floatDef -> NumFloat floatDef
        XY xyDef -> XY xyDef
        Toggle toggleDef -> Toggle toggleDef
        Color colorDef -> Color colorDef
        Textual textualDef -> Textual textualDef
        Action actionDef -> Action actionDef
        Select selectDef -> Select selectDef
        Nest nestDef ->
            let
                nextChildren = List.map (mapProperty f) nestDef.children
            in Nest <|
                { children = nextChildren
                , nestAt = nestDef.nestAt
                , panel = nestDef.panel
                }
        Gradient gradientDef -> Gradient gradientDef
        Progress progressDef -> Progress progressDef
        Zoom zoomDef -> Zoom zoomDef
