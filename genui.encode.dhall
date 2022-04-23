

let P = ./genui.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


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
                                , def = JSON.object
                                    (toMap
                                        { min = JSON.integer def.min
                                        , max = JSON.integer def.max
                                        , step = JSON.integer def.step
                                        , current = JSON.integer def.current
                                        }
                                    )
                                }
                    , NumFloat = \(def : P.FloatDef) ->
                                { kind = JSON.string "float"
                                , def = JSON.object
                                    (toMap
                                        { min = JSON.natural def.min
                                        , max = JSON.natural def.max
                                        , step = JSON.natural def.step
                                        , current = JSON.natural def.current
                                        }
                                    )
                                }
                    , XY = \(def : P.XYDef) ->
                                { kind = JSON.string "xy"
                                , def = JSON.object
                                    (toMap
                                        { x =
                                            JSON.object
                                                (toMap
                                                    { min = JSON.natural def.x.min
                                                    , max = JSON.natural def.x.max
                                                    , step = JSON.natural def.x.step
                                                    , current = JSON.natural def.x.current
                                                    }
                                                )
                                        , y =
                                            JSON.object
                                                (toMap
                                                    { min = JSON.natural def.y.min
                                                    , max = JSON.natural def.y.max
                                                    , step = JSON.natural def.y.step
                                                    , current = JSON.natural def.y.current
                                                    }
                                                )
                                        }
                                    )
                                }
                    , Color = \(def : P.ColorDef) ->
                                { kind = JSON.string "color"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.string def.current
                                        }
                                    )
                                }
                    , Textual = \(def : P.TextualDef) ->
                                { kind = JSON.string "text"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.string def.current
                                        }
                                    )
                                }
                    , Action = \(def : P.ActionDef) ->
                                { kind = JSON.string "action"
                                , def = JSON.null
                                }
                    , Group = \(def : P.GroupDef) ->
                                { kind = JSON.string "group"
                                , def = JSON.object
                                    (toMap
                                        { expand = JSON.bool def.expand
                                        , children = JSON.array def.children
                                        }
                                    )
                                }
                    , Select = \(def : P.SelectDef) ->
                                { kind = JSON.string "select"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.string def.current
                                        , values = JSON.array (List/map Text JSON.Type JSON.string def.values)
                                        }
                                    )
                                }
                    , Switch = \(def : P.SwitchDef) ->
                                { kind = JSON.string "switch"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.bool def.current
                                        }
                                    )
                                }
                    }
                    prop.def
            )
        )

in encode