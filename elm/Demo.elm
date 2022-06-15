module Demo exposing (..)


import GenUI.Descriptive.Encode as Descriptive
import Json.Decode as Json
import GenUI.Json.Decode as GJson

import Browser
import GenUI as G

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (decodeString)


type alias Model = Maybe (Result String G.GenUI)


type Action
    = New
    | Parse String


init : Model
init = Nothing


view : Model -> Html Action
view model =
    case model of
        Nothing ->
            div
                [ style "display" "flex"
                , style "flex-direction" "row"
                ]
                [ textarea
                    [ style "max-width" "50%"
                    , cols 150, rows 150
                    , onInput Parse
                    ]
                    []
                , div [ style "width" "50%" ]
                    [ button [ onClick New ] [ text "New" ]
                    , text "Parsing result"
                    ]
                ]
        Just (Ok ui) ->
            div [ ]
                [ button [ onClick New ] [ text "New" ]
                , textarea []
                    [ text <| Descriptive.toString <| Descriptive.encode ui ]
                ]
        Just (Err err) ->
            div [ ]
                [ button [ onClick New ] [ text "New" ]
                , text <| "Error: " ++ err
                ]


update : Action -> Model -> Model
update action _ =
    case action of
        New -> Nothing
        Parse string ->
            Just
                <| Result.mapError Json.errorToString
                <| decodeString GJson.decode string


main : Platform.Program () Model Action
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }