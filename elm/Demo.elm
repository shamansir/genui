module Demo exposing (..)


import GenUI.Descriptive.Encode as Descriptive

import Browser
import GenUI as G

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model = Maybe (Result String G.GenUI)


type Action =
    Parse String


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
                , div [ style "width" "50%" ] [ text "Parsing result" ]
                ]
        Just (Ok ui) ->
            div [] []
        Just (Err err) ->
            div [] []


update : Action -> Model -> Model
update action model =
    model


main : Platform.Program () Model Action
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }