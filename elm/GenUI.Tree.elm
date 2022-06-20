module GenUI.Tree exposing (..)

import Json.Decode as Json
--import Json.Encode as Json
import Yaml.Decode as Yaml
import Yaml.Encode as Yaml
import GenUI.Dhall.Encode exposing (Dhall)
import GenUI.Descriptive.Encode exposing (Descriptive)


type alias CellShape =
    { cols : Int
    , rows : Int
    }


type alias Def a =
    { kind : String
    , toString : a -> String
    , toJson : a -> Json.Value
    , fromJson : Json.Decoder a
    , toYaml : a -> Yaml.Encoder
    , fromYaml : Yaml.Decoder a
    , toDhall : a -> Dhall
    , toDescriptive : a -> Descriptive
    , construct : GenUI a
    }


type alias Axis a = List (Cell a)


type Cell a =
    Cell
        { def : a
        , name : String
        , property : Maybe String
        , live : Bool
        , shape : Maybe CellShape
        , items : Axis a
        }


type alias GenUI a =
    { version : String
    , root : Axis a
    }


mapAxis : (a -> b) -> Axis a -> Axis b
mapAxis f = List.map <| mapCell f


mapCell : (a -> b) -> Cell a -> Cell b
mapCell f (Cell cell) =
    Cell
        { def = f cell.def
        , name = cell.name
        , property = cell.property
        , live = cell.live
        , shape = cell.shape
        , items = mapAxis f cell.items
        }


map : (a -> b) -> GenUI a -> GenUI b
map f gui =
    { version = gui.version
    , root = mapAxis f gui.root
    }



bimapDef : (a -> b) -> (b -> a) -> Def a -> Def b
bimapDef f g def =
    { kind = def.kind
    , toString = def.toString << g
    , toJson = def.toJson << g
    , fromJson = Json.map f def.fromJson
    , toYaml = def.toYaml << g
    , fromYaml = Yaml.map f def.fromYaml
    , toDhall = def.toDhall << g
    , toDescriptive = def.toDescriptive << g
    , construct = map f def.construct
    }