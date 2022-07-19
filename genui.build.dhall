let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map

let P = ./genui.dhall
let Property/encode = ./genui.encode.dhall
let VERSION = ./VERSION.dhall


let ghost
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Ghost }

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

let zoom
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Zoom { current = 1.0, kind = P.ZoomKind.PlusMinus } }

let zoom_by
    = \(name : Text) -> \(current : Double) -> \(steps : List Double) ->
    P.Property::{ name, def = P.Def.Zoom { current, kind = P.ZoomKind.Steps steps } }


let NameValue = { name : Text, value : Text }

let ValueIcon = { value : Text, dark : P.URL, light : P.URL }

let ValueNameIcon = { value : Text, name : Text, dark : P.URL, light : P.URL }

let __select
    : ∀(valueT : Type) -> (valueT -> P.SelectItem) -> P.SelectKind -> Text -> List valueT -> Text -> P.Property.Type
    = \(valueT : Type) -> \(convert : valueT -> P.SelectItem) -> \(kind : P.SelectKind) -> \(name : Text) -> \(values : List valueT) -> \(current : Text) ->
    P.Property::{ name, def = P.Def.Select
        { values =
            List/map valueT P.SelectItem convert values
        , current
        , nestProperty = None Text
        , kind = kind
        }
    }

let select
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Default, name = None Text } : P.SelectItem)
        (P.SelectKind.Choice { form = P.NestForm.Expanded, face = P.Face.Default, page = +1, shape = P.NestShape.default })
        name
        values
        current

let select_knob
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Default, name = None Text } : P.SelectItem)
        P.SelectKind.Knob
        name
        values
        current


let select_switch
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Default, name = None Text } : P.SelectItem)
        P.SelectKind.Switch
        name
        values
        current


let select_w_faces
    = \(name : Text) -> \(values : List ValueIcon) -> \(current : Text) ->
    __select
        ValueIcon
        (\(t : ValueIcon) ->
            { value = t.value
            , face = P.Face.Icon [ { theme = P.Theme.Light, url = t.light }, { theme = P.Theme.Dark, url = t.dark } ]
            , name = None Text
            } : P.SelectItem
        )
        P.SelectKind.Switch
        name
        values
        current


let nest
    = \(name : Text) -> \(children : List JSON.Type) -> \(form : P.NestForm) ->
    P.Property::{ name, def = P.Def.Nest
        { children
        , form
        , nestProperty = None Text
        , shape = P.NestShape.default
        , face = P.Face.Default
        , page = +0
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

let bind_to
    = \(propName : Text) ->
    { property = Some propName }

let nest_at
    = \(propName : Text) ->
    { nestProperty = Some propName }

let live
    = { live = True }
    -- = \(property : P.Property.Type) ->
    -- property // { live = True }

let ___def_update =
    { Ghost = P.Def.Ghost
    , NumInt = \(idef : P.IntDef) -> P.Def.NumInt idef
    , NumFloat = \(fdef : P.FloatDef) -> P.Def.NumFloat fdef
    , XY = \(xydef : P.XYDef) -> P.Def.XY xydef
    , Toggle = \(tdef : P.ToggleDef) -> P.Def.Toggle tdef
    , Color = \(cdef : P.ColorDef) -> P.Def.Color cdef
    , Textual = \(tdef : P.TextualDef) -> P.Def.Textual tdef
    , Action = \(adef : P.ActionDef) -> P.Def.Action adef
    , Gradient = \(gdef : P.GradientDef) -> P.Def.Gradient gdef
    , Nest = \(ndef : P.NestDef) -> P.Def.Nest ndef
    , Progress = \(pdef : P.ProgressDef) -> P.Def.Progress pdef
    , Select = \(sdef : P.SelectDef) -> P.Def.Select sdef
    , Zoom = \(zdef : P.ZoomDef) -> P.Def.Zoom zdef
    }

let ___update_choice
    : (P.Choice -> P.Choice) -> P.SelectDef -> P.SelectDef
    =  \(fn : P.Choice -> P.Choice)
    -> \(sdef : P.SelectDef) ->
    sdef
        //
            { kind =
                merge
                    { Knob = P.SelectKind.Knob
                    , Switch = P.SelectKind.Switch
                    , Choice = \(ps : P.Choice) -> P.SelectKind.Choice (fn ps)
                    }
                    sdef.kind
            }

let no_face
    = \(property : P.Property.Type) ->
    property
        //
        { def =
            merge
                (___def_update // {
                , Action = \(adef : P.ActionDef) -> P.Def.Action (adef // { face = P.Face.Default })
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { face = P.Face.Default })
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            (___update_choice
                                (\(ps : P.Choice) -> ps // { face = P.Face.Default })
                                sdef
                            )
                })
                property.def
        }


let with_face
    = \(property : P.Property.Type) -> \(face : P.Face) ->
    property
        //
        { def =
            merge
                (___def_update // {
                , Action = \(adef : P.ActionDef) -> P.Def.Action (adef // { face })
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { face })
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            (___update_choice
                                (\(ps : P.Choice) -> ps // { face })
                                sdef
                            )
                })
                property.def
        }

let with_shape
    : P.Property.Type -> P.NestShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.NestShape.Type) ->
    property
        //
        { def =
            merge
                (___def_update // {
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { shape })
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            (___update_choice
                                (\(ps : P.Choice) -> ps // { shape })
                                sdef
                            )
                })
                property.def
        }

let with_cshape
    : P.Property.Type -> P.CellShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.CellShape.Type) ->
    property // { shape = Some shape }

let go_to_page
    : P.Property.Type -> Integer -> P.Property.Type
    = \(property : P.Property.Type) -> \(page : Integer) ->
        property
        //
        { def =
            merge
                (___def_update // {
                , Nest = \(ndef : P.NestDef) -> P.Def.Nest (ndef // { page })
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            (___update_choice
                                (\(ps : P.Choice) -> ps // { page })
                                sdef
                            )
                })
                property.def
        }

let _expanded : P.NestForm = P.NestForm.Expanded
let _collapsed : P.NestForm = P.NestForm.Collapsed

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

let _dark = P.Theme.Dark

let _light = P.Theme.Light

let _icons_f
    : List P.Icon -> P.Face
    = \(icons : List P.Icon) -> P.Face.Icon icons

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
    { ghost, int, float, xy, x_y, color, text, toggle, action, progress, gradient, select, nest, zoom, zoom_by
    , select_knob, select_switch
    , root, children
    , bind_to, nest_at, live, with_face, no_face, with_shape, with_cshape, go_to_page, _expanded, _collapsed
    , _rgba, _rgb, _hsla, _hsl, _hex
    , _color_f, _icon_f, _icons_f, _l_icon_f
    , _local, _remote
    , _dark, _light
    , _s, _s2, _linear, _2d
    }