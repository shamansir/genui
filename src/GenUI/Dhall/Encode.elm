module GenUI.Dhall.Encode exposing (Dhall, encode, toString)


import GenUI as G


{-| -}
type alias Dhall = List String


{-| -}
encode : G.GenUI -> Dhall
encode _ = [ "" ]


{-| -}
toString : Dhall -> String
toString = String.join "\n"