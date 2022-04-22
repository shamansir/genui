

let P = ./genui.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let encode
    : P.Property.Type -> JSON.Type
    = \(prop : P.Property.Type)
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
                    { NumInt = \(spec : P.IntSpec) ->
                                { kind = JSON.string "int"
                                , min = JSON.integer spec.min
                                , max = JSON.integer spec.max
                                , step = JSON.integer spec.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , NumFloat = \(spec : P.FloatSpec) ->
                                { kind = JSON.string "float"
                                , min = JSON.natural spec.min
                                , max = JSON.natural spec.max
                                , step = JSON.natural spec.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Color = \(spec : P.ColorSpec) ->
                                { kind = JSON.string "color"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Textual = \(spec : P.TextualSpec) ->
                                { kind = JSON.string "text"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Action = \(spec : P.ActionSpec) ->
                                { kind = JSON.string "action"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Group = \(spec : P.GroupSpec) ->
                                { kind = JSON.string "group"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array spec.children
                                }
                    , Select = \(spec : P.SelectSpec) ->
                                { kind = JSON.string "select"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string spec.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Switch = \(spec : P.SwitchSpec) ->
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

in encode