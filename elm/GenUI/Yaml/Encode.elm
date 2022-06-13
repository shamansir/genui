module GenUI.Yaml.Encode exposing (..)


import GenUI as G
import Yaml.Encode as E


encode : G.GenUI -> E.Encoder
encode _ = E.null