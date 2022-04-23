

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
                    { NumInt = \(def : P.IntDef) ->
                                { kind = JSON.string "int"
                                , min = JSON.integer def.min
                                , max = JSON.integer def.max
                                , step = JSON.integer def.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , NumFloat = \(def : P.FloatDef) ->
                                { kind = JSON.string "float"
                                , min = JSON.natural def.min
                                , max = JSON.natural def.max
                                , step = JSON.natural def.step
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , XY = \(def : P.XYDef) ->
                                { kind = JSON.string "xy"
                                , x = JSON.object
                                    (toMap
                                        { min = JSON.natural def.x.min
                                        , max = JSON.natural def.x.max
                                        , step = JSON.natural def.x.step
                                        , current = JSON.natural def.x.current
                                        }
                                    )
                                , y = JSON.object
                                    (toMap
                                        { min = JSON.natural def.y.min
                                        , max = JSON.natural def.y.max
                                        , step = JSON.natural def.y.step
                                        , current = JSON.natural def.y.current
                                        }
                                    )
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                }
                    , Color = \(def : P.ColorDef) ->
                                { kind = JSON.string "color"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string def.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , Textual = \(def : P.TextualDef) ->
                                { kind = JSON.string "text"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string def.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , Action = \(def : P.ActionDef) ->
                                { kind = JSON.string "action"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , Group = \(def : P.GroupDef) ->
                                { kind = JSON.string "group"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array def.children
                                , x = JSON.null, y = JSON.null
                                }
                    , Select = \(def : P.SelectDef) ->
                                { kind = JSON.string "select"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.string def.current
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    , Switch = \(def : P.SwitchDef) ->
                                { kind = JSON.string "switch"
                                , min = JSON.null
                                , max = JSON.null
                                , step = JSON.null
                                , current = JSON.null
                                , expand = JSON.null
                                , children = JSON.array ([] : List JSON.Type)
                                , x = JSON.null, y = JSON.null
                                }
                    }
                    prop.def
            )
        )

in encode