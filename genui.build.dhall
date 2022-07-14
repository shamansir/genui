let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map

let P = ./genui.dhall
let Property/encode = ./genui.encode.dhall
let VERSION = ./VERSION.dhall


let int
    = \(name : Text) -> \(def : P.IntDef) ->
    P.Property::{ name, def = P.Def.NumInt def }

let float
    = \(name : Text) -> \(def : P.FloatDef) ->
    P.Property::{ name, def = P.Def.NumFloat def }

let xy
    = \(name : Text) -> \(def : P.XYDef) ->
    P.Property::{ name, def = P.Def.XY def }

let x_y
    = \(name : Text) -> \(xdef : P.FloatDef) -> \(ydef : P.FloatDef) ->
    xy name { x = xdef, y = ydef }

let color
    = \(name : Text) -> \(color : P.Color) ->
    P.Property::{ name, def = P.Def.Color { current = color } }

let text
    = \(name : Text) -> \(current : Text) ->
    P.Property::{ name, def = P.Def.Textual { current } }

let toggle
    = \(name : Text) -> \(current : Bool) ->
    P.Property::{ name, def = P.Def.Toggle { current } }

let action
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Action { face = P.Face.Default } }

let progress
    = \(name : Text) -> \(api : P.URL) ->
    P.Property::{ name, def = P.Def.Progress { api } }

let gradient
    = \(name : Text) -> \(g : P.Gradient) ->
    P.Property::{ name, def = P.Def.Gradient { current = g } }

let select
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    P.Property::{ name, def = P.Def.Select
        { values =
            List/map Text P.SelectItem (\(t : Text) -> { value = t, face = P.Face.Default, name = None Text } : P.SelectItem) values
        , current
        , nestProperty = None Text
        , kind = P.SelectKind.Pages { expand = True, face = P.Face.Default, page = +1, shape = P.NestShape.default }
        }
    }

let nest
    = \(name : Text) -> \(children : List JSON.Type) -> \(expand : Bool) ->
    P.Property::{ name, def = P.Def.Nest
        { children
        , expand
        , nestProperty = None Text
        , shape = P.NestShape.default
        , face = P.Face.Default
        }
    }

let children
    = \(children : List P.Property.Type) ->
    List/map P.Property.Type JSON.Type Property/encode children

let root
    = \(items : List P.Property.Type) ->
    { version = VERSION
    , root = children items
    } : P.GenUI

{- modify property -}

let with_face
    = \(property : P.Property.Type) -> \(face : P.Face) ->
    property
        //
        { def =
            merge
                { Ghost = P.Def.Ghost
                , NumInt = \(idef : P.IntDef) -> P.Def.NumInt idef
                , NumFloat = \(fdef : P.FloatDef) -> P.Def.NumFloat fdef
                , XY = \(xydef : P.XYDef) -> P.Def.XY xydef
                , Toggle = \(tdef : P.ToggleDef) -> P.Def.Toggle tdef
                , Color = \(cdef : P.ColorDef) -> P.Def.Color cdef
                , Textual = \(tdef : P.TextualDef) -> P.Def.Textual tdef
                , Action = \(adef : P.ActionDef) -> P.Def.Action (adef // { face })
                , Gradient = \(gdef : P.GradientDef) -> P.Def.Gradient gdef
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { face })
                , Progress = \(pdef : P.ProgressDef) -> P.Def.Progress pdef
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            ( sdef
                                //
                                    { kind =
                                        merge
                                            { Knob = P.SelectKind.Knob
                                            , Switch = P.SelectKind.Switch
                                            , Pages = \(ps : P.Pages) -> P.SelectKind.Pages (ps // { face })
                                            }
                                            sdef.kind
                                    }
                            )
                }
                property.def
        }


let with_shape
    : P.Property.Type -> P.NestShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.NestShape.Type) ->
    property
        //
        { def =
            merge
                { Ghost = P.Def.Ghost
                , NumInt = \(idef : P.IntDef) -> P.Def.NumInt idef
                , NumFloat = \(fdef : P.FloatDef) -> P.Def.NumFloat fdef
                , XY = \(xydef : P.XYDef) -> P.Def.XY xydef
                , Toggle = \(tdef : P.ToggleDef) -> P.Def.Toggle tdef
                , Color = \(cdef : P.ColorDef) -> P.Def.Color cdef
                , Textual = \(tdef : P.TextualDef) -> P.Def.Textual tdef
                , Action = \(adef : P.ActionDef) -> P.Def.Action adef
                , Gradient = \(gdef : P.GradientDef) -> P.Def.Gradient gdef
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { shape })
                , Progress = \(pdef : P.ProgressDef) -> P.Def.Progress pdef
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            ( sdef
                                //
                                    { kind =
                                        merge
                                            { Knob = P.SelectKind.Knob
                                            , Switch = P.SelectKind.Switch
                                            , Pages = \(ps : P.Pages) -> P.SelectKind.Pages (ps // { shape })
                                            }
                                            sdef.kind
                                    }
                            )
                }
                property.def
        }

let with_cshape
    : P.Property.Type -> P.CellShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.CellShape.Type) ->
    property // { shape = Some shape }

let bind_to
    = \(propName : Text) ->
    { property = Some propName }

let nest_at
    = \(propName : Text) ->
    { nestProperty = Some propName }

let live
    = \(property : P.Property.Type) ->
    property // { live = True }

{- construct P.Color -}

let _rgba
    = \(r : Double) -> \(g : Double) -> \(b : Double) -> \(a : Double) ->
    P.Color.RGBA { red = r, green = g, blue = b, alpha = a }

let _rgb
    = \(r : Double) -> \(g : Double) -> \(b : Double) ->
    _rgba r g b 1.0

let _hsla
    = \(h : Double) -> \(s : Double) -> \(l : Double) -> \(a : Double) ->
    P.Color.HSLA { hue = h, saturation = s, lightness = l, alpha = a }

let _hsl
    = \(h : Double) -> \(s : Double) -> \(l : Double) ->
    _hsla h s l 1.0

let _hex
    = \(hex : Text) ->
    P.Color.HEX hex

{- construct P.Face -}

let _color_f
    : P.Color -> P.Face
    = \(color : P.Color) -> P.Face.Color color

let _icon_f
    : { dark : P.URL, light : P.URL } -> P.Face
    = \(i : { dark : P.URL, light : P.URL })
    -> P.Face.Icon [ { theme = P.Theme.Light, url = i.light }, { theme = P.Theme.Dark, url = i.dark } ]

let _l_icon_f
    : P.URL -> P.Face
    = \(url : P.URL) -> P.Face.Icon [ { theme = P.Theme.Light, url } ]

{- construct P.URL -}

let _local
    : Text -> P.URL
    = \(url : Text) -> P.URL.Local url

let _remote
    : Text -> P.URL
    = \(url : Text) -> P.URL.Remote url


{- constuct P.Stop, P.Stop2D and P.Gradient -}

let _s
    : Double -> P.Color -> P.Stop
    = \(pos : Double) -> \(color : P.Color) ->
    { color, position = pos }

let _s2
    : Double -> Double -> P.Color -> P.Stop2D
    = \(x : Double) -> \(y : Double) -> \(color : P.Color) ->
    { color, position = { x, y } }

let _linear
    : List P.Stop -> P.Gradient
    = \(stops : List P.Stop) ->
    P.Gradient.Linear stops

let _2d
    : List P.Stop2D -> P.Gradient
    = \(stops : List P.Stop2D) ->
    P.Gradient.TwoDimensional stops

in
    { int, float, xy, x_y, color, text, toggle, action, progress, gradient, select, nest
    , root, children
    , bind_to, nest_at, live, with_face, with_shape, with_cshape
    , _rgba, _rgb, _hsla, _hsl, _hex
    , _color_f, _icon_f, _l_icon_f
    , _local, _remote
    , _s, _s2, _linear, _2d
    }