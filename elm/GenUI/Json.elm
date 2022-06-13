module GenUI.Json exposing (..)

import GenUI as G

import Json.Decode as D
import Json.Encode as E


decode : D.Decoder G.GenUI
decode = D.succeed <| { version = "", root = [] }


encode : G.GenUI -> E.Value
encode _ = E.null