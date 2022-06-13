module GenUI.Yaml.Decode exposing (..)


import GenUI as G

import Yaml.Decode as D

decode : D.Decoder G.GenUI
decode = D.succeed <| { version = "", root = [] }