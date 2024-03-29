

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
        , NotDefined = JSON.null
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
        { Empty =
            JSON.object (toMap { face = JSON.string "empty" })
        , Color = \(color : P.Color) ->
            JSON.object (toMap { face = JSON.string "color", color = encodeColor color })
        , Icon = \(icons : List P.Icon) ->
            JSON.object (toMap { face = JSON.string "icon", icons = JSON.array (List/map P.Icon JSON.Type encodeIcon icons) })
        , Title =
            JSON.object (toMap { face = JSON.string "title" })
        , ExpandCollapse =
            JSON.object (toMap { face = JSON.string "expand" })
        , Focus =
            JSON.object (toMap { face = JSON.string "focus" })
        }
        face


let encodeUnit
    : P.Unit -> JSON.Type
    = \(unit : P.Unit)
    -> JSON.double
        (merge
            { Half = 0.5
            , One = 1.0
            , OneAndAHalf = 1.5
            , Two = 2.0
            , Three = 3.0
            , Custom = \(d : Double) -> d
            }
            unit)


let encodeCellShape
    : P.CellShape.Type -> JSON.Type
    = \(shape : P.CellShape.Type)
    -> JSON.object
        (toMap
            { horz = encodeUnit shape.horz
            , vert = encodeUnit shape.vert
            }
        )

let encodePage
    : P.Page -> JSON.Type
    = \(page : P.Page)
    -> JSON.object
        (toMap
            (merge
                { First = { page = JSON.string "first", n = JSON.integer -1 }
                , Last = { page = JSON.string "last", n = JSON.integer -1 }
                , ByCurrent = { page = JSON.string "current", n = JSON.integer -1 }
                , Page = \(n : Integer) -> { page = JSON.string "n", n = JSON.integer n }
                }
                page
            )
        )


let encodePages
    : P.Pages -> JSON.Type
    = \(pages : P.Pages)
    -> JSON.object
        (toMap
            (merge
                { Auto =
                    { distribute = JSON.string "auto", maxInRow = JSON.integer -1, maxInColumn = JSON.integer -1, exact = JSON.integer -1 }
                , Single =
                    { distribute = JSON.string "single", maxInRow = JSON.integer -1, maxInColumn = JSON.integer -1, exact = JSON.integer -1 }
                , Distribute =
                    \(fit : P.Fit) ->
                    { distribute = JSON.string "values", maxInRow = JSON.integer fit.maxInRow, maxInColumn = JSON.integer fit.maxInColumn, exact = JSON.integer -1 }
                , DistributeRows =
                    \(fit : P.FitRows) ->
                    { distribute = JSON.string "values", maxInRow = JSON.integer -1, maxInColumn = JSON.integer fit.maxInColumn, exact = JSON.integer -1 }
                , DistributeColumns =
                    \(fit : P.FitColumns) ->
                    { distribute = JSON.string "values", maxInRow = JSON.integer fit.maxInRow, maxInColumn = JSON.integer -1, exact = JSON.integer -1 }
                , Exact =
                    \(n : Integer) ->
                    { distribute = JSON.string "exact", maxInRow = JSON.integer -1, maxInColumn = JSON.integer -1, exact = JSON.integer n }
                }
                pages
            )
        )


let encodeForm
    : P.Form -> JSON.Type
    = \(form : P.Form)
    -> merge
        { Expanded = JSON.string "expanded"
        , Collapsed = JSON.string "collapsed"
        }
        form


let encodePanel
    : P.Panel -> JSON.Type
    = \(def : P.Panel)
    -> JSON.object
            (toMap
                { form = encodeForm def.form
                , button = encodeFace def.button
                , allOf =
                    merge
                        { Some = \(cs : P.CellShape.Type) -> encodeCellShape cs
                        , None = JSON.null
                        }
                    def.allOf
                , page = encodePage def.page
                , pages = encodePages def.pages
                })


let encodeSelectKind
    : P.SelectKind -> JSON.Type
    = \(kind : P.SelectKind)
    -> merge
        { Choice =
            \(panel : P.Panel) ->
            JSON.object (toMap { kind = JSON.string "choice", panel = encodePanel panel })
        , Knob = JSON.object (toMap { kind = JSON.string "knob", panel = JSON.null })
        , Switch = JSON.object (toMap { kind = JSON.string "switch", panel = JSON.null })
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
            , x = JSON.double stop.position.x
            , y = JSON.double stop.position.y
            }
        )

let encodePresets
    : List P.Color -> JSON.Type
    = \(presets : List P.Color) ->
    JSON.array
        (List/map
            P.Color
            JSON.Type
            encodeColor
            presets
        )


let encodeGradient
    : List P.Color -> P.Gradient -> JSON.Type
    = \(presets : List P.Color) -> \(gradient : P.Gradient)
    -> merge
        { Linear =
            \(stops : List P.Stop) ->
            JSON.object
                (toMap
                    { type = JSON.string "linear"
                    , current =
                        JSON.array
                            (List/map
                                P.Stop
                                JSON.Type
                                encodeStop
                                stops
                            )
                    , presets = encodePresets presets
                    })
        , TwoDimensional =
            \(stops : List P.Stop2D) ->
            JSON.object
                (toMap
                    { type = JSON.string "2d"
                    , current =
                        JSON.array
                            (List/map
                                P.Stop2D
                                JSON.Type
                                encodeStop2d
                                stops
                            )
                    , presets = encodePresets presets
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
                , triggerOn =
                    merge
                        { Some = \(path : List Text) -> JSON.array (List/map Text JSON.Type JSON.string path)
                        , None = JSON.null
                        }
                        prop.triggerOn
                , statePath =
                    merge
                        { Some = \(path : List Text) -> JSON.array (List/map Text JSON.Type JSON.string path)
                        , None = JSON.null
                        }
                        prop.statePath
                }
                // merge
                    { Ghost =
                                { kind = JSON.string "ghost"
                                , def = JSON.object (toMap { ghost = JSON.null})
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
                    , Zoom = \(def : P.ZoomDef) ->
                                { kind = JSON.string "zoom"
                                , def = JSON.object
                                    (toMap
                                        { current = JSON.double def.current
                                        , steps =
                                            JSON.array
                                            (merge
                                                { Steps = \(steps : List Double) ->
                                                    List/map Double JSON.Type JSON.double steps
                                                , PlusMinus = ([] : List JSON.Type)
                                                }
                                                def.kind)
                                        , kind =
                                            JSON.string
                                            (merge
                                                { Steps = \(s : List Double) -> "steps"
                                                , PlusMinus = "plusminus"
                                                }
                                                def.kind)
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
                    , Gradient = \(def : P.GradientDef) ->
                                { kind = JSON.string "gradient"
                                , def = encodeGradient def.presets def.current
                                }
                    , Nest = \(def : P.NestDef) ->
                                { kind = JSON.string "nest"
                                , def = JSON.object
                                    (toMap
                                        { children = JSON.array def.children
                                        , panel = encodePanel def.panel
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
                    }
                    prop.def
            )
        )

in encode