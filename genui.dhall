
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


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


let encodeChild
    : Property.Type -> JSON.Type
    = \(prop : Property.Type)
    -> JSON.object
        ( toMap
            (
                { name = JSON.string prop.name
                , icon = merge
                            { Some = \(icon : Text) -> JSON.string icon
                            , None = JSON.null
                            }
                            prop.icon
                , property = merge
                            { Some = \(prop : Text) -> JSON.string prop
                            , None = JSON.null
                            }
                            prop.icon
                }
                // merge
                    { NumInt = \(spec : IntSpec) ->
                                { kind = JSON.string "int"
                                , min = JSON.integer spec.min
                                , max = JSON.integer spec.max
                                , step = JSON.integer spec.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , NumFloat = \(spec : FloatSpec) ->
                                { kind = JSON.string "float"
                                , min = JSON.natural spec.min
                                , max = JSON.natural spec.max
                                , step = JSON.natural spec.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Color = \(spec : ColorSpec) ->
                                { kind = JSON.string "color"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Textual = \(spec : TextualSpec) ->
                                { kind = JSON.string "text"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Action = \(spec : ActionSpec) ->
                                { kind = JSON.string "action"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Group = \(spec : GroupSpec) ->
                                { kind = JSON.string "group"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array spec.children
                                }
                    , Select = \(spec : SelectSpec) ->
                                { kind = JSON.string "select"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Switch = \(spec : SwitchSpec) ->
                                { kind = JSON.string "switch"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    }
                    prop.spec
            )
        )


let innerProp
    : Property.Type
    = Property::
            { name = "test-2"
            , spec = Spec.Action {=}
            }


let ui : List Property.Type =
    [
        Property::
            { name = "test"
            , spec = Spec.Action {=}
            , icon = Some "test-icon"
            }
    ,
        Property::
            { name = "group"
            , spec =
                Spec.Group
                    { children = ([ encodeChild innerProp ] : List JSON.Type)
                    , expand = True
                    , nest = None Text
                    }
            }
    ]

in List/map Property.Type JSON.Type encodeChild ui