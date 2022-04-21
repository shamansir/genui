
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall
let List/map = https://prelude.dhall-lang.org/List/map


let Spec : Type =
    < NumInt : { min : Natural, max : Natural, step : Natural, current : Natural }
    | NumFloat : { min : Natural, max : Natural, step : Natural, current : Natural }
    | Color : { current : Text }
    | Textual : { current : Text }
    | Action
    | Select : { current : Text, values : List Text }
    | Group : { name : Text, children : List JSON.Type, expand : Bool, nest : Optional Text }
    | Switch : { current : Bool }
    >


let Property =
    { Type =
        { spec : Spec
        , name : Text
        , icon : Optional Text
        , property : Optional Text
        }
    , default =
        { icon = None Text
        , property = None Text
        }
    }


let encodeChild
    : Property.Type -> JSON.Type
    = \(prop : Property.Type)
    -> JSON.object
        ( toMap
            ({ name = JSON.string prop.name
            } // { icon = JSON.null, test = JSON.string "Foo" })
        )


let innerProp
    : Property.Type
    = Property::
            { name = "test-2"
            , spec = Spec.Action
            }


let ui : List Property.Type =
    [
        Property::
            { name = "test"
            , spec = Spec.Action
            }
    ,
        Property::
            { name = "group"
            , spec =
                Spec.Group
                    { name = "foo"
                    , children = ([ encodeChild innerProp ] : List JSON.Type)
                    , expand = True
                    , nest = None Text
                    }
            }
    ]

in List/map Property.Type JSON.Type encodeChild ui