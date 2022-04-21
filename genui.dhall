
{- let PropertyKind = -}

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let Spec : Type =
    < NumInt : { min : Natural, max : Natural, step : Natural, current : Natural }
    | NumFloat : { min : Natural, max : Natural, step : Natural, current : Natural }
    | Color : { current : Text }
    | Textual : { current : Text }
    | Action
    | Select : { current : Text, values : List Text }
    | Group : { name : Text, children : List JSON.Type, expand : Bool }
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


let ui : List Property.Type =
    [
        Property::
            { name = "test"
            , spec = Spec.Action
            }
    ]


in ui