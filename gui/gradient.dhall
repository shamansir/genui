let P = ../genui.dhall
let Property/encode = ../genui.encode.dhall
let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


let innerProp
    : P.Property.Type
    = P.Property::
            { name = "test-2"
            , spec = P.Spec.Action {=}
            }


let ui : List P.Property.Type =
    [
        P.Property::
            { name = "test"
            , spec = P.Spec.Action {=}
            , icon = Some "test-icon"
            }
    ,
        P.Property::
            { name = "group"
            , spec =
                P.Spec.Group
                    { children = ([ Property/encode innerProp ] : List JSON.Type)
                    , expand = True
                    , nest = None Text
                    }
            }
    ]

in List/map P.Property.Type JSON.Type Property/encode ui