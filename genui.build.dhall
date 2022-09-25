let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map

let P = ./genui.dhall
let Property/encode = ./genui.encode.dhall
let VERSION = ./VERSION.dhall


-- Component with no representation. Can be used as an empty element in the hierarchy.
let ghost
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Ghost }

-- Change integer value. Takes current value, minimum value, maximum value and step.
let int
    = \(name : Text) -> \(def : P.IntDef) ->
    P.Property::{ name, def = P.Def.NumInt def }

-- Change floating poing value. Takes current value, minimum value, maximum value and step.
let float
    = \(name : Text) -> \(def : P.FloatDef) ->
    P.Property::{ name, def = P.Def.NumFloat def }

-- Change XY coordinates. Takes current value, minimum value, maximum value and step for both axes.
let xy
    = \(name : Text) -> \(def : P.XYDef) ->
    P.Property::{ name, def = P.Def.XY def }

-- Change XY coordinates. Takes current value, minimum value, maximum value and step for both axes as separate parameters.
let x_y
    = \(name : Text) -> \(xdef : P.FloatDef) -> \(ydef : P.FloatDef) ->
    xy name { x = xdef, y = ydef }

-- Change color value. Takes the current one.
let color
    = \(name : Text) -> \(color : P.Color) ->
    P.Property::{ name, def = P.Def.Color { current = color } }

-- Change text value. Takes the current one.
let text
    = \(name : Text) -> \(current : Text) ->
    P.Property::{ name, def = P.Def.Textual { current } }

-- Toggle the value between on and off. Takes current state of the toggle.
let toggle
    = \(name : Text) -> \(current : Bool) ->
    P.Property::{ name, def = P.Def.Toggle { current } }

-- Button with the given name.
let action
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Action { face = P.Face.Title } }

-- Progress control for tasks that could take considerable amount of time and may have failure states.
let progress
    = \(name : Text) -> \(api : P.URL) ->
    P.Property::{ name, def = P.Def.Progress { api } }

-- Gradient control. Takes current value.
let gradient
    = \(name : Text) -> \(g : P.Gradient) ->
    P.Property::{ name, def = P.Def.Gradient { current = g, presets = ([] : List P.Color) } }

-- Gradient control with given presets. Takes current value.
let gradient_with_presets
    = \(name : Text) -> \(g : P.Gradient) -> \(presets : List P.Color) ->
    P.Property::{ name, def = P.Def.Gradient { current = g, presets } }

-- Zoom control
let zoom
    = \(name : Text) ->
    P.Property::{ name, def = P.Def.Zoom { current = 1.0, kind = P.ZoomKind.PlusMinus } }

-- Zoom control with given steps
let zoom_by
    = \(name : Text) -> \(current : Double) -> \(steps : List Double) ->
    P.Property::{ name, def = P.Def.Zoom { current, kind = P.ZoomKind.Steps steps } }

{- *** Helpers for select components *** -}

-- Item of the select box that has a name (friendly readable text) and a value (unique ID among other items).
let NameValue = { name : Text, value : Text }

-- Item of the select box that has a value (unique ID among other items) and an icon.
-- For Tron UI, light-stroke (`dark` theme) and dark-stroke (`light` theme) icons could be specified.
let ValueIcon = { value : Text, dark : P.URL, light : P.URL }

-- Item of the select box that hasa name (friendly readable text) and a value (unique ID among other items) and an icon.
-- For Tron UI, light-stroke and dark-stroke icons are specified.
let NameValueIcon = { name : Text, value : Text, dark : P.URL, light : P.URL }


-- Item in the list of options in the select list. Could be called "option" as well.
let SelectItem =
    < N : Text
    | NV : NameValue
    | VI : ValueIcon
    | NVI : NameValueIcon
    >


-- Convert `SelectItem` helper to the native `P.SelectItem` format.
let SelectItem/convert =
    \(si : SelectItem) ->
    merge
        { N = \(n : Text) -> { value = n, face = P.Face.Title, name = None Text }
        , NV = \(nv : NameValue) -> { value = nv.value, face = P.Face.Title, name = Some nv.name }
        , VI = \(vi : ValueIcon) -> { value = vi.value, face = P.Face.Icon [ { theme = P.Theme.Light, url = vi.light }, { theme = P.Theme.Dark, url = vi.dark } ], name = None Text }
        , NVI = \(nvi : NameValueIcon) -> { value = nvi.value, face = P.Face.Icon [ { theme = P.Theme.Light, url = nvi.light }, { theme = P.Theme.Dark, url = nvi.dark } ], name = Some nvi.name }
        }
        si


-- Create an item with a name (friendly readable text).
let _n = \(name : Text) -> SelectItem.N name
let name_item = _n

-- Create an item with a name (friendly readable text) and value (unique ID among other items).
let _nv = \(name : Text) -> \(value : Text) -> SelectItem.NV { name, value }
let name_value_item = _nv

-- Create an item with a value (unique ID among other items) and an icon.
-- For Tron UI, light-stroke (`dark` theme) and dark-stroke (`light` theme) icons are expected to be specified.
let _vii = \(value : Text) -> \(dark : P.URL) -> \(light : P.URL) -> SelectItem.VI { value, dark, light }
let value_themed_icon_item = _vii

-- Create an item with a value (unique ID among other items) and an icon.
let _vi = \(value : Text) -> \(icon : P.URL) -> _vii value icon icon
let value_icon_item = _vi

-- Create an item with a name (friendly readable text) and value (unique ID among other items) and an icon.
-- For Tron UI, light-stroke (`dark` theme) and dark-stroke (`light` theme) icons are expected to be specified.
let _nvii = \(name : Text) -> \(value : Text) -> \(dark : P.URL) -> \(light : P.URL) -> SelectItem.NVI { name, value, dark, light }
let name_value_themed_icon_item = _nvii

-- Create an item with a name (friendly readable text) and value (unique ID among other items) and an icon.
let _nvi = \(name : Text) -> \(value : Text) -> \(icon : P.URL) -> SelectItem.NVI { name, value, dark = icon, light = icon }
let name_value_icon_item = _nvi

let __select
    : P.SelectKind -> Text -> List SelectItem -> Text -> P.Property.Type
    = \(kind : P.SelectKind) -> \(name : Text) -> \(values : List SelectItem) -> \(current : Text) ->
    P.Property::{ name, def = P.Def.Select
        { values =
            List/map SelectItem P.SelectItem SelectItem/convert values
        , current
        , nestProperty = None Text
        , kind = kind
        }
    }


let __select_choice_panel
    : P.Panel =
    { form = P.Form.Expanded
    , button = P.Face.Focus
    , allOf = None P.CellShape.Type
    , page = P.Page.ByCurrent
    , pages = P.Pages.Auto
    }


-- Select component with a list of options to select from.
-- Use one of these helpers to construct options: `name_item`, `name_value_item`, `value_icon_item`, `value_themed_icon_item`, `name_value_themed_icon_item`, `name_value_themed_icon_item`.
-- Or their shortcuts: `_n`, `_nv`, `_vi`, `_vii`, `_nvi`, `_nvii`.
-- Takes current _value_ (not the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is a panel with choices, similar to the `nest`.
let select_
    = \(name : Text) -> \(values : List SelectItem) -> \(current : Text) ->
    __select
        (P.SelectKind.Choice __select_choice_panel)
        name
        values
        current

-- Select component with a list of textual options to select from.
-- Options are considered to be both unique and readable.
-- Takes current value (so the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is a panel with choices, similar to the `nest`.
let select
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    select_
        name
        (List/map Text SelectItem SelectItem.N values)
        current


-- The _select knob_ is the control where option is selected by turning the knob.
-- Use one of these helpers to construct options: `name_item`, `name_value_item`, `value_icon_item`, `value_themed_icon_item`, `name_value_themed_icon_item`, `name_value_themed_icon_item`.
-- Or their shortcuts: `_n`, `_nv`, `_vi`, `_vii`, `_nvi`, `_nvii`.
-- Takes current _value_ (not the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is the turning knob as described.
let select_knob_
    = \(name : Text) -> \(values : List SelectItem) -> \(current : Text) ->
    __select
        P.SelectKind.Knob
        name
        values
        current


-- The _select knob_ is the control where option is selected by turning the knob.
-- Options are considered to be both unique and readable.
-- Takes current _value_ (not the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is the turning knob as described.
let select_knob
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    select_knob_
        name
        (List/map Text SelectItem SelectItem.N values)
        current


-- The _select switch_ is the control where option is selected by clicking the same button specific number of times, so the options are cycled.
-- Use one of these helpers to construct options: `name_item`, `name_value_item`, `value_icon_item`, `value_themed_icon_item`, `name_value_themed_icon_item`, `name_value_themed_icon_item`.
-- Or their shortcuts: `_n`, `_nv`, `_vi`, `_vii`, `_nvi`, `_nvii`.
-- Takes current _value_ (not the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is the button for multiple clicks as described.
let select_switch_
    = \(name : Text) -> \(values : List SelectItem) -> \(current : Text) ->
    __select
        P.SelectKind.Switch
        name
        values
        current


-- The _select switch_ is the control where option is selected by clicking the same button specific number of times, so the options are cycled.
-- Options are considered to be both unique and readable.
-- Takes current _value_ (not the name).
-- For the case of `dat.gui`, could be an usual combo-box.
-- For the case of Tron, it is the button for multiple clicks as described.
let select_switch
    = \(name : Text) -> \(values : List Text) -> \(current : Text) ->
    select_switch_
        name
        (List/map Text SelectItem SelectItem.N values)
        current

{- *** Helpers for nesting components. *** -}

let __nest_panel
    : P.Panel =
    { form = P.Form.Expanded
    , button = P.Face.ExpandCollapse
    , allOf = None P.CellShape.Type
    , page = P.Page.ByCurrent
    , pages = P.Pages.Auto
    }

-- Nest listed children in the panel that is revealed by clicking a button with given name.
-- Children in the list should already be converted to JSON, use `children` helper to do that.
-- In `dat.gui` implementation, it is a folder.
let nest
    = \(name : Text) -> \(children : List JSON.Type) -> \(form : P.Form) ->
    P.Property::{ name, def = P.Def.Nest
        { children
        , nestProperty = None Text
        , panel = __nest_panel // { form }
        }
    }

-- Convert a list of controls to the JSON representation. Needed for the `nest` helper.
let children
    = \(children : List P.Property.Type) ->
    List/map P.Property.Type JSON.Type Property/encode children

-- The root. The first one in any UI definition.
let root
    = \(items : List P.Property.Type) ->
    { version = VERSION
    , root = children items
    } : P.GenUI

{- *** Helpers for changing the properties of the already defined controls *** -}

-- Bind the component to some property in the state.
-- This could be hepful when your code requires different name for this propety in the state.
-- For example, `int "The Beautiful Number" { current = 1, step = 1, minimum = 0, max = 100 } // bind_to "theBeautifulNumber"`
let bind_to
    = \(propName : Text) ->
    { property = Some propName }

-- Nest this property under some other property in the state.
-- This could be hepful when the back-end requires different structure of the state, differnet from the structure of folders in the UI.
let nest_at
    = \(propName : Text) ->
    { nestProperty = Some propName }

-- Move the property to some nested place in the state.
-- This could be hepful when the back-end requires different structure of the state, differnet from the structure of folders in the UI.
let map_to
    = \(path : List Text) ->
    { statePath = Some path }

-- Update the value of this component when some other value under the given path in the state has changed.
let trigger_on
    = \(path : List Text) ->
    { triggerOn = Some path }


-- `live` component is listening to all the changes in the state and reflects the value immediately
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

-- Remove cell shape setup from the nested panel.
let _no_cshape
    : Optional P.CellShape.Type
    = None P.CellShape.Type


-- Update all options of the nested panel with given ones.
-- Works both for the nested panels and select panels.
let with_panel
    = \(property : P.Property.Type) -> \(panel : P.Panel) ->
    __update_panel property (\(_ : P.Panel) -> panel)


-- Change the face of the component.
-- Works for buttons, nested panels and select panels. When used with panels, it updates the button that causes this panel to appear.
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


-- Remove face of the component.
-- Works for buttons, nested panels and select panels. When used with panels, it updates the button that causes this panel to appear.
let no_face
    = \(property : P.Property.Type) ->
    with_face property P.Face.Empty


-- Expand the nested panel.
-- Works both for the nested panels and select panels.
let expand
    = \(property : P.Property.Type) ->
    __update_panel property (\(p : P.Panel) -> p // { form = P.Form.Expanded })


-- Collapse the nested panel.
-- Works both for the nested panels and select panels.
let collapse
    = \(property : P.Property.Type) ->
    __update_panel property (\(p : P.Panel) -> p // { form = P.Form.Collapsed })


-- Change paging of the panel.
-- Works both for the nested panels and select panels.
let with_paging
    = \(property : P.Property.Type) -> \(pages : P.Pages) -> \(page : P.Page) ->
    __update_panel property (\(p : P.Panel) -> p // { pages, page })


-- Change paging of the panel.
-- Works both for the nested panels and select panels.
let with_pages
    = \(property : P.Property.Type) -> \(pages : P.Pages) ->
    with_paging property pages P.Page.ByCurrent


-- Set the cell shape for the panel.
-- It defines the size of the controls layed out within the panel. So it is given in units.
-- Works both for the nested panels and select panels.
let with_cshape
    : P.Property.Type -> P.CellShape.Type -> P.Property.Type
    = \(property : P.Property.Type) -> \(shape : P.CellShape.Type) ->
    property // { shape = Some shape }


-- Remove cell shape setup from the nested panel.
-- Works both for the nested panels and select panels.
let no_cshape
    : P.Property.Type -> P.Property.Type
    = \(property : P.Property.Type) ->
    property // { shape = _no_cshape }


-- Switch the panel with paging to the page with given number.
-- Works both for the nested panels and select panels.
let go_to_page
    : P.Property.Type -> Integer -> P.Property.Type
    = \(property : P.Property.Type) -> \(page : Integer) ->
    __update_panel property (\(p : P.Panel) -> p // { page = P.Page.Page page })


{- *** construct P.Form *** -}

let _expanded : P.Form = P.Form.Expanded
let _collapsed : P.Form = P.Form.Collapsed

{- *** construct `P.Color` *** -}

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

{- *** Construct `P.Face` *** -}

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
    P.Face.ExpandCollapse

let _show_focus_f : P.Face =
    P.Face.Focus

{- *** Construct P.Theme *** -}

let _dark = P.Theme.Dark

let _light = P.Theme.Light

{- *** Construct P.Page *** -}

-- First page is selected.
let _first : P.Page = P.Page.First

-- Last page is selected.
let _last : P.Page = P.Page.Last

-- The page with current value is selected.
let _by_current : P.Page = P.Page.ByCurrent

-- The page with current value is selected.
let _page : Integer -> P.Page = \(n : Integer) -> P.Page.Page n

{- *** Construct P.Pages *** -}

-- Distribute controls between pages automatically. (i.e. max 3x3).
let _auto : P.Pages = P.Pages.Auto

-- One and only page.
let _single : P.Pages = P.Pages.Single

-- Fit the items either using `maxInColumn` or `maxInRow` values.
let _distribute : P.Fit -> P.Pages = \(fit : P.Fit) -> P.Pages.Distribute fit

-- Distribute over exact number of pages.
let _pages : Integer -> P.Pages = \(n : Integer) -> P.Pages.Exact n

{- *** Construct P.Unit *** -}

let _half : P.Unit = P.Unit.Half

let _one : P.Unit = P.Unit.One

let _one_and_half : P.Unit = P.Unit.OneAndAHalf

let _two : P.Unit = P.Unit.Two

let _three : P.Unit = P.Unit.Three

let _unit : Double -> P.Unit = \(d : Double) -> P.Unit.Custom d

{- *** Construct P.URL *** -}

let _local
    : Text -> P.URL
    = \(url : Text) -> P.URL.Local url

let _remote
    : Text -> P.URL
    = \(url : Text) -> P.URL.Remote url

{- *** Construct P.Stop, P.Stop2D and P.Gradient *** -}

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
    { ghost, int, float, xy, x_y, color, text, toggle, action, progress, gradient, gradient_with_presets, nest, zoom, zoom_by
    , select, select_, select_knob, select_knob_, select_switch, select_switch_
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
    , _n, _nv, _vi, _vii, _nvi, _nvii
    , name_item, name_value_item, value_icon_item, value_themed_icon_item, name_value_icon_item, name_value_themed_icon_item
    , NameValue, NameValueIcon, ValueIcon, SelectItem, SelectItem/convert
    }