

let P = ./genui.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


let encodeFace
    : P.Face -> JSON.Type
    = \(face : P.Face)
    -> merge
        { Color = \(color : Text) -> JSON.object (toMap { face = JSON.string "color", color = JSON.string color })
        , Icon = \(icon : Text) -> JSON.object (toMap { face = JSON.string "icon", icon = JSON.string icon })
        , Default = JSON.null
        }
        face


let encodeCellShape
    : P.CellShape.Type -> JSON.Type
    = \(shape : P.CellShape.Type)
    -> JSON.object
        (toMap
            { cols = JSON.integer shape.cols
            , rows = JSON.integer shape.rows
            }
        )


let encodeNestShape
    : P.NestShape.Type -> JSON.Type
    = \(shape : P.NestShape.Type)
    -> JSON.object
        (toMap
            { cols = JSON.integer shape.cols
            , rows = JSON.integer shape.rows
            , pages = JSON.integer shape.pages
            }
        )


let encodeSelectKind
    : P.SelectKind -> JSON.Type
    = \(kind : P.SelectKind)
    -> merge
        { Choice =
            \(def : { expand : Bool, face: P.Face }) ->
            JSON.object
                (toMap
                    { kind = JSON.string "choice"
                    , face = encodeFace def.face
                    , expand = JSON.bool def.expand
                    })
        , Knob = JSON.object (toMap { kind = JSON.string "knob" })
        , Switch = JSON.object (toMap { kind = JSON.string "switch" })
        }
        kind


let encodeSelectItem
    : P.SelectItem -> JSON.Type
    = \(item : P.SelectItem)
    -> JSON.object
        (toMap
            { face = encodeFace item.face
            , value = JSON.string item.value
            , name =
                merge
                    { Some = \(n : Text) -> JSON.string n
                    , None = JSON.null
                    }
                    item.name
            }
        )


let encode
    : P.Property.Type -> JSON.Type
    = \(prop : P.Property.Type)
    -> JSON.object
        ( toMap
            (
                { name = JSON.string prop.name
                , shape = merge
                            { Some = \(shape : P.CellShape.Type) -> encodeCellShape shape
                            , None = JSON.null
                            }
                            prop.shape
                , property = merge
                            { Some = \(prop : Text) -> JSON.string prop
                            , None = JSON.null
                            }
                            prop.property
                , live = JSON.bool prop.live
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
                                , def = JSON.object
                                    (toMap
                                        { face = encodeFace def.face
                                        }
                                    )
                                }
                    , Nest = \(def : P.NestDef) ->
                                { kind = JSON.string "nest"
                                , def = JSON.object
                                    (toMap
                                        { expand = JSON.bool def.expand
                                        , children = JSON.array def.children
                                        , shape = encodeNestShape def.shape
                                        , face = encodeFace def.face
                                        , nestAt =
                                            merge
                                                { Some = \(prop : Text) -> JSON.string prop
                                                , None = JSON.null
                                                }
                                                def.nestProperty
                                        }
                                    )
                                }
                    , Select = \(def : P.SelectDef) ->
                                { kind = JSON.string "select"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.string def.current
                                        {- , expand = JSON.bool def.expand -}
                                        , values = JSON.array (List/map P.SelectItem JSON.Type encodeSelectItem def.values)
                                        , kind = encodeSelectKind def.kind
                                        , nestAt =
                                            merge
                                                { Some = \(prop : Text) -> JSON.string prop
                                                , None = JSON.null
                                                }
                                                def.nestProperty
                                        , shape = encodeNestShape def.shape
                                        }
                                    )
                                }
                    }
                    prop.def
            )
        )

in encode