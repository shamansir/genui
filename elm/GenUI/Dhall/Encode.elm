module GenUI.Dhall.Encode exposing (..)


import GenUI as G


type alias Dhall = List String


encode : G.GenUI -> Dhall
encode _ = [ "" ]


toString : Dhall -> String
toString = String.join "\n"