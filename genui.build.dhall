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
    P.Property::{ name, def = P.Def.Action { face = P.Face.Title } }

let progress
    = \(name : Text) -> \(api : P.URL) ->
    P.Property::{ name, def = P.Def.Progress { api } }

let gradient
    = \(name : Text) -> \(g : P.Gradient) ->
    P.Property::{ name, def = P.Def.Gradient { current = g, presets = ([] : List P.Color) } }

let gradient_with_presets
    = \(name : Text) -> \(g : P.Gradient) -> \(presets : List P.Color) ->
    P.Property::{ name, def = P.Def.Gradient { current = g, presets } }

let zoom
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Zoom { current = 1.0, kind = P.ZoomKind.PlusMinus } }

let zoom_by
    = \(name : Text) -> \(current : Double) -> \(steps : List Double) ->
    P.Property::{ name, def = P.Def.Zoom { current, kind = P.ZoomKind.Steps steps } }


let NameValue = { name : Text, value : Text }

let ValueIcon = { value : Text, dark : P.URL, light : P.URL }

let NameValueIcon = { name : Text, value : Text, dark : P.URL, light : P.URL }

let _nv = \(name : Text) -> \(value : Text) -> { name, value }

let _vi = \(value : Text) -> \(dark : P.URL) -> \(light : P.URL) -> { value, dark, light }

let _nvi = \(name : Text) -> \(value : Text) -> \(dark : P.URL) -> \(light : P.URL) -> { name, value, dark, light }

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


let __select_choice_panel
    : P.Panel =
    { form = P.Form.Expanded
    , button = P.Face.PanelFocusedItem
    , allOf = None P.CellShape.Type
    , page = P.Page.ByCurrent
    , pages = P.Pages.Auto
    }


let select
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Title, name = None Text } : P.SelectItem)
        (P.SelectKind.Choice __select_choice_panel)
        name
        values
        current

let select_knob
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Title, name = None Text } : P.SelectItem)
        P.SelectKind.Knob
        name
        values
        current


let select_switch
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    __select
        Text
        (\(t : Text) -> { value = t, face = P.Face.Title, name = None Text } : P.SelectItem)
        P.SelectKind.Switch
        name
        values
        current


let select_icons
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


let select_nv
    = \(name : Text) -> \(values : List NameValue) -> \(current : Text) ->
    __select
        NameValue
        (\(t : NameValue) ->
            { value = t.value
            , face = P.Face.Title
            , name = Some t.name
            } : P.SelectItem
        )
        P.SelectKind.Switch
        name
        values
        current


let select_nvi
    = \(name : Text) -> \(values : List NameValueIcon) -> \(current : Text) ->
    __select
        NameValueIcon
        (\(t : NameValueIcon) ->
            { value = t.value
            , face = P.Face.Icon [ { theme = P.Theme.Light, url = t.light }, { theme = P.Theme.Dark, url = t.dark } ]
            , name = Some t.name
            } : P.SelectItem
        )
        P.SelectKind.Switch
        name
        values
        current


let __nest_panel
    : P.Panel =
    { form = P.Form.Expanded
    , button = P.Face.PanelExpandStatus
    , allOf = None P.CellShape.Type
    , page = P.Page.ByCurrent
    , pages = P.Pages.Auto
    }


let nest
    = \(name : Text) -> \(children : List JSON.Type) -> \(form : P.Form) ->
    P.Property::{ name, def = P.Def.Nest
        { children
        , nestProperty = None Text
        , panel = __nest_panel
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

let map_to
    = \(path : List Text) ->
    { statePath = Some path }

let trigger_on
    = \(path : List Text) ->
    { triggerOn = Some path }

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
    : (P.Panel -> P.Panel) -> P.SelectDef -> P.SelectDef
    =  \(fn : P.Panel -> P.Panel)
    -> \(sdef : P.SelectDef) ->
    sdef
        //
            { kind =
                merge
                    { Knob = P.SelectKind.Knob
                    , Switch = P.SelectKind.Switch
                    , Choice = \(ps : P.Panel) -> P.SelectKind.Choice (fn ps)
                    }
                    sdef.kind
            }

let ___update_nest
    : (P.Panel -> P.Panel) -> P.NestDef -> P.NestDef
    =  \(fn : P.Panel -> P.Panel)
    -> \(ndef : P.NestDef) ->
    ndef // { panel = fn ndef.panel }


let __update_panel
    = \(property : P.Property.Type) -> \(fn : P.Panel -> P.Panel) ->
    property
        //
        { def =
            merge
                (___def_update // {
                , Nest = \(ndef : P.NestDef) ->
                        P.Def.Nest (___update_nest fn ndef)
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select (___update_choice fn sdef)
                })
                property.def
        }

let _no_cshape
    : Optional P.CellShape.Type
    = None P.CellShape.Type


let with_panel
    = \(property : P.Property.Type) -> \(panel : P.Panel) ->
    __update_panel property (\(_ : P.Panel) -> panel)


let with_face
    = \(property : P.Property.Type) -> \(face : P.Face) ->
    property
        //
        { def =
            merge
                (___def_update // {
                , Action = \(adef : P.ActionDef) -> P.Def.Action (adef // { face })
                , Nest = \(ndef : P.NestDef) ->
                        P.Def.Nest
                            (___update_nest
                                (\(ps : P.Panel) -> ps // { button = face })
                                ndef
                            )
                , Select =
                    \(sdef : P.SelectDef) ->
                        P.Def.Select
                            (___update_choice
                                (\(ps : P.Panel) -> ps // { button = face })
                                sdef
                            )
                })
                property.def
        }


let no_face
    = \(property : P.Property.Type) ->
    with_face property P.Face.Empty


let expand
    = \(property : P.Property.Type) ->
    __update_panel property (\(p : P.Panel) -> p // { form = P.Form.Expanded })


let collapse
    = \(property : P.Property.Type) ->
    __update_panel property (\(p : P.Panel) -> p // { form = P.Form.Collapsed })


let with_paging
    = \(property : P.Property.Type) -> \(pages : P.Pages) -> \(page : P.Page) ->
    __update_panel property (\(p : P.Panel) -> p // { pages, page })


let with_pages
    = \(property : P.Property.Type) -> \(pages : P.Pages) ->
    with_paging property pages P.Page.ByCurrent


let with_cshape
    : P.Property.Type -> P.CellShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.CellShape.Type) ->
    property // { shape = Some shape }


let no_cshape
    : P.Property.Type -> P.Property.Type
    = \(property : P.Property.Type) ->
    property // { shape = _no_cshape }


let go_to_page
    : P.Property.Type -> Integer -> P.Property.Type
    = \(property : P.Property.Type) -> \(page : Integer) ->
    __update_panel property (\(p : P.Panel) -> p // { page = P.Page.Page page })


{- construct P.Form -}

let _expanded : P.Form = P.Form.Expanded
let _collapsed : P.Form = P.Form.Collapsed

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

let _empty_f : P.Face =
    P.Face.Empty

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

let _icons_f
    : List P.Icon -> P.Face
    = \(icons : List P.Icon) -> P.Face.Icon icons

let _title_f : P.Face =
    P.Face.Title

let _show_expand_f : P.Face =
    P.Face.PanelExpandStatus

let _show_focus_f : P.Face =
    P.Face.PanelFocusedItem

{- construct P.Theme -}

let _dark = P.Theme.Dark

let _light = P.Theme.Light

{- construct P.Page -}

let _first : P.Page = P.Page.First

let _last : P.Page = P.Page.Last

let _by_current : P.Page = P.Page.ByCurrent

let _page : Integer -> P.Page = \(n : Integer) -> P.Page.Page n

{- construct P.Pages -}

let _auto : P.Pages = P.Pages.Auto

let _single : P.Pages = P.Pages.Single

let _distribute : P.Fit -> P.Pages = \(fit : P.Fit) -> P.Pages.Distribute fit

let _pages : Integer -> P.Pages = \(n : Integer) -> P.Pages.Exact n

{- construct P.Unit -}

let _half : P.Unit = P.Unit.Half

let _one : P.Unit = P.Unit.One

let _one_and_half : P.Unit = P.Unit.OneAndAHalf

let _two : P.Unit = P.Unit.Two

let _three : P.Unit = P.Unit.Three

let _unit : Double -> P.Unit = \(d : Double) -> P.Unit.Custom d

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
    { ghost, int, float, xy, x_y, color, text, toggle, action, progress, gradient, gradient_with_presets, select, nest, zoom, zoom_by
    , select_knob, select_switch, select_icons, select_nv, select_nvi
    , root, children
    , bind_to, map_to, trigger_on, nest_at, live
    , with_face, no_face
    , with_cshape, no_cshape
    , with_paging, with_pages, go_to_page, with_panel
    , expand, collapse
    , _expanded, _collapsed
    , _rgba, _rgb, _hsla, _hsl, _hex
    , _empty_f, _color_f, _icon_f, _icons_f, _l_icon_f, _title_f, _show_expand_f, _show_focus_f
    , _first, _last, _by_current, _page
    , _auto, _single, _distribute, _pages
    , _half, _one, _one_and_half, _two, _three, _unit
    , _local, _remote
    , _dark, _light
    , _no_cshape
    , _s, _s2, _linear, _2d
    , _nv, _vi, _nvi
    }