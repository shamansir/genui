module GenUI.Json.Encode exposing (..)


import GenUI as G
import Json.Encode as E


encode : G.GenUI -> E.Value
encode _ = E.null