

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
                            prop.property
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
                                        { min = JSON.double def.min
                                        , max = JSON.double def.max
                                        , step = JSON.double def.step
                                        , current = JSON.double def.current
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
                                                    { min = JSON.double def.x.min
                                                    , max = JSON.double def.x.max
                                                    , step = JSON.double def.x.step
                                                    , current = JSON.double def.x.current
                                                    }
                                                )
                                        , y =
                                            JSON.object
                                                (toMap
                                                    { min = JSON.double def.y.min
                                                    , max = JSON.double def.y.max
                                                    , step = JSON.double def.y.step
                                                    , current = JSON.double def.y.current
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
                    , Toggle = \(def : P.ToggleDef) ->
                                { kind = JSON.string "toggle"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.bool def.current
                                        }
                                    )
                                }
                    , Action = \(def : P.ActionDef) ->
                                { kind = JSON.string "action"
                                , def = JSON.null
                                }
                    , Nest = \(def : P.NestDef) ->
                                { kind = JSON.string "nest"
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
                    }
                    prop.def
            )
        )

in encode