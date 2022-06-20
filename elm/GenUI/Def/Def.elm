module GenUI.Def.Def exposing (..)


import Json.Decode as Json
--import Json.Encode as Json
import Yaml.Decode as Yaml
import Yaml.Encode as Yaml
import GenUI.Dhall.Encode exposing (Dhall)
import GenUI.Descriptive.Encode exposing (Descriptive)


type alias Def a =
    { kind : String
    , toString : a -> String
    , toJson : a -> Json.Value
    , fromJson : Json.Decoder a
    , toYaml : a -> Yaml.Encoder
    , fromYaml : Yaml.Decoder a
    , toDhall : a -> Dhall
    , toDescriptive : a -> Descriptive
    -- , construct : GenUI a
    }
