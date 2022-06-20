module Constructor exposing (..)


import GenUI as G
import Dict exposing (Dict)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (decodeString)


type alias Path = List String


type alias Model
    = G.GenUI


type Action
    = Add Path G.Property
    | Edit Path G.Property
    | Remove Path G.Property


init : Model
init =
    { version = G.version
    , root = []
    }
