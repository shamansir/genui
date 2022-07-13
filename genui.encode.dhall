

let P = ./genui.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


let encodeColor
    : P.Color -> JSON.Type
    = \(color : P.Color)
    -> merge
        { RGBA = \(c : P.RGBAColor) -> JSON.object (toMap { r = JSON.double c.red, g = JSON.double c.green, b = JSON.double c.blue, a = JSON.double c.alpha })
        , HSLA = \(c : P.HSLAColor) -> JSON.object (toMap { h = JSON.double c.hue, s = JSON.double c.saturation, l = JSON.double c.lightness, a = JSON.double c.alpha })
        , HEX = \(c : Text) -> JSON.object (toMap { hex = JSON.string c })
        }
        color


let encodeTheme
    : P.Theme -> JSON.Type
    = \(theme : P.Theme)
    -> merge
        { Dark = JSON.string "dark"
        , Light = JSON.string "light"
        }
        theme


let encodeUrl
    : P.URL -> JSON.Type
    = \(url : P.URL)
    -> merge
        { Local = \(s : Text) ->
            JSON.object (toMap { type = JSON.string "local", value = JSON.string s })
        , Remote = \(s : Text) ->
            JSON.object (toMap { type = JSON.string "remote", value = JSON.string s })
        }
        url


let encodeIcon
    : P.Icon -> JSON.Type
    = \(icon : P.Icon)
    -> JSON.object
        (toMap
            { theme = encodeTheme icon.theme
            , url = encodeUrl icon.url
            }
        )


let encodeFace
    : P.Face -> JSON.Type
    = \(face : P.Face)
    -> merge
        { Color = \(color : P.Color) ->
            JSON.object (toMap { face = JSON.string "color", color = encodeColor color })
        , Icon = \(icons : List P.Icon) ->
            JSON.object (toMap { face = JSON.string "icon", icons = JSON.array (List/map P.Icon JSON.Type encodeIcon icons) })
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
        { Pages =
            \(def : { expand : Bool, face: P.Face, page : Integer, shape : P.NestShape.Type }) ->
            JSON.object
                (toMap
                    { kind = JSON.string "choice"
                    , face = encodeFace def.face
                    , expand = JSON.bool def.expand
                    , shape = encodeNestShape def.shape
                    , page = JSON.integer def.page
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


let encodeStop
    : P.Stop -> JSON.Type
    = \(stop : P.Stop)
    -> JSON.object
        (toMap
            { color = encodeColor stop.color
            , position = JSON.double stop.position
            }
        )


let encodeStop2d
    : P.Stop2D -> JSON.Type
    = \(stop : P.Stop2D)
    -> JSON.object
        (toMap
            { color = encodeColor stop.color
            , position =
                JSON.object
                    (toMap
                        { x = JSON.double stop.position.x
                        , y = JSON.double stop.position.y
                        }
                    )
            }
        )


let encodeGradient
    : P.Gradient -> JSON.Type
    = \(gradient : P.Gradient)
    -> merge
        { Linear =
            \(stops : List P.Stop) ->
            JSON.object
                (toMap
                    { type = JSON.string "linear"
                    , stops =
                        JSON.array
                            (List/map
                                P.Stop
                                JSON.Type
                                encodeStop
                                stops
                            )
                    })
        , TwoDimensional =
            \(stops : List P.Stop2D) ->
            JSON.object
                (toMap
                    { type = JSON.string "2d"
                    , stops =
                        JSON.array
                            (List/map
                                P.Stop2D
                                JSON.Type
                                encodeStop2d
                                stops
                            )
                    })
        }
        gradient


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
                    { Ghost =
                                { kind = JSON.string "ghost"
                                , def = JSON.null
                                }
                    , NumInt = \(def : P.IntDef) ->
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
                                        { current = encodeColor def.current
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
                                        }
                                    )
                                }
                    , Gradient = \(def : P.GradientDef) ->
                                { kind = JSON.string "gradient"
                                , def = JSON.object
                                    (toMap
                                        { current = encodeGradient def.current
                                        }
                                    )
                                }
                    , Progress = \(def : P.ProgressDef) ->
                                { kind = JSON.string "progress"
                                , def = JSON.object
                                    (toMap
                                        { api = encodeUrl def.api }
                                    )
                                }
                    }
                    prop.def
            )
        )

in encode