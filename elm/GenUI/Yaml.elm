module GenUI.Yaml exposing (..)

import GenUI as G

import Yaml.Decode as D
import Yaml.Encode as E


decode : D.Decoder G.GenUI
decode = D.succeed <| { version = "", root = [] }


encode : G.GenUI -> E.Encoder
encode _ = E.null