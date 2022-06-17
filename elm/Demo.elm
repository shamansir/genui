module Demo exposing (..)


import GenUI.Descriptive.Encode as Descriptive
import Json.Decode as Json
import Json.Encode as Json
import Yaml.Encode as Yaml
import GenUI.Json.Decode as GJson
import GenUI.Json.Encode as GJson
import GenUI.Yaml.Decode as GYaml
import GenUI.Yaml.Encode as GYaml
import GenUI.Dhall.Encode as GDhall
import GenUI.ToGraph as GGraph
import Graph as Graph

import Browser
import GenUI as G

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (decodeString)


type Output
    = Descriptive
    | Json
    | Yaml
    | Graph
    | Dhall


type alias Model = Maybe (Result String (Output, G.GenUI))


type Action
    = New
    | Parse String
    | SwitchTo Output


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
        Just (Ok (output, ui)) ->
            div [ ]
                [ button [ onClick New ] [ text "New" ]
                , textarea []
                    [ text <| case output of
                        Descriptive -> Descriptive.toString <| Descriptive.encode ui
                        Json -> Json.encode 4 <| GJson.encode ui
                        Yaml -> Yaml.toString 4 <| GYaml.encode ui
                        Dhall -> GDhall.toString <| GDhall.encode ui
                        Graph -> Graph.toString (always <| Just "*") (always <| Just "*") <| GGraph.toGraph ui
                    ]
                ]
        Just (Err err) ->
            div [ ]
                [ button [ onClick New ] [ text "New" ]
                , text <| "Error: " ++ err
                ]


update : Action -> Model -> Model
update action model =
    let
        loadOutput : Model -> Output
        loadOutput =
            Maybe.map
                (Result.map Tuple.first >> Result.withDefault Descriptive)
                >> Maybe.withDefault Descriptive
    in

    case action of
        New -> Nothing
        Parse string ->
            Just
                <| Result.map (Tuple.pair <| loadOutput model)
                <| Result.mapError Json.errorToString
                <| decodeString GJson.decode string
        SwitchTo output ->
            Maybe.map (Result.map <| Tuple.mapFirst <| always output) model
            {- case model of
                Just (Ok (_, gui)) ->
                    Just (Ok (output, gui))
                _ -> model -}


main : Platform.Program () Model Action
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }