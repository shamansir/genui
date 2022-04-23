let P = ../genui.dhall
let Property/encode = ../genui.encode.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


let innerProp
    : P.Property.Type
    = P.Property::
            { name = "test-2"
            , def = P.Def.Action {=}
            }


let ui : List P.Property.Type =
    [
        P.Property::
            { name = "test"
            , def = P.Def.Action {=}
            , icon = Some "test-icon"
            }
    ,
        P.Property::
            { name = "group"
            , def =
                P.Def.Group
                    { children = ([ Property/encode innerProp ] : List JSON.Type)
                    , expand = True
                    , nest = None Text
                    }
            }
    ]

in List/map P.Property.Type JSON.Type Property/encode ui