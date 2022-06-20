module GenUI.Def.Int exposing (..)


import GenUI.Def.Def exposing (Def)

import Json.Encode as JsonE
import Json.Decode as JsonD
import Yaml.Decode as YamlD
import Yaml.Encode as YamlE


type alias IntDef =
    { min : Int, max : Int, step : Int, current : Int }



int : Def IntDef
int =
    { kind = "int"
    , toString = .current >> String.fromInt
    , toJson =
        \def ->
            JsonE.object
                [ ( "min", JsonE.int def.min )
                , ( "max", JsonE.int def.max )
                , ( "step", JsonE.int def.step )
                , ( "current", JsonE.int def.current )
                ]
    , fromJson =
        JsonD.map4
            IntDef
                (JsonD.field "min" JsonD.int)
                (JsonD.field "max" JsonD.int)
                (JsonD.field "step" JsonD.int)
                (JsonD.field "current" JsonD.int)
    , toYaml =
        \def ->
            YamlE.record
                [ ( "min", YamlE.int def.min )
                , ( "max", YamlE.int def.max )
                , ( "step", YamlE.int def.step )
                , ( "current", YamlE.int def.current )
                ]
    , fromYaml =
        YamlD.map4
            IntDef
                (YamlD.field "min" YamlD.int)
                (YamlD.field "max" YamlD.int)
                (YamlD.field "step" YamlD.int)
                (YamlD.field "current" YamlD.int)
    , toDhall = always []
    , toDescriptive = always []
    -- , construct : GenUI a
    }
