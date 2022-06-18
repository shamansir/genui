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
import Dict exposing (Dict)

import Browser

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


defaultOutput : Output
defaultOutput = Descriptive


type Model
    = Empty
    | ParseError String
    -- Parsed Output G.GenUI (List (Output, String))
    | Parsed Output (List (Output, String)) -- (Dict Output String)


type Action
    = New
    | Parse String
    | SwitchTo Output


init : Model
init = Empty


view : Model -> Html Action
view model =
    case model of
        Empty ->
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
        Parsed curOutput outputs ->
            div [ ]
                <| button [ onClick New ] [ text "New" ]
                :: div []
                        [ button [ onClick <| SwitchTo Descriptive ] [ text "Descriptive" ]
                        , button [ onClick <| SwitchTo Json ] [ text "Json" ]
                        , button [ onClick <| SwitchTo Yaml ] [ text "Yaml" ]
                        , button [ onClick <| SwitchTo Graph ] [ text "Graph" ]
                        , button [ onClick <| SwitchTo Dhall ] [ text "Dhall" ]
                        ]
                :: List.map
                    ( \(output, parsed) ->
                        textarea
                            [ style "z-index"
                                <| if output == curOutput then "10000" else "0"
                            , style "position" "absolute"
                            , cols 150
                            , rows 150
                            ]
                            [ text parsed ]
                    )
                    outputs
        ParseError err ->
            div [ ]
                [ button [ onClick New ] [ text "New" ]
                , text <| "Error: " ++ err
                ]


update : Action -> Model -> Model
update action model =
    let
        curOutput : Output
        curOutput =
            case model of
                Parsed output _ -> output
                _ -> defaultOutput
    in

    case action of
        New -> Empty
        Parse string ->
            case decodeString GJson.decode string of
                Ok ui ->
                    Parsed curOutput
                        [ ( Descriptive, Descriptive.toString <| Descriptive.encode ui )
                        , ( Json, Json.encode 4 <| GJson.encode ui )
                        , ( Yaml, Yaml.toString 4 <| GYaml.encode ui )
                        , ( Dhall, GDhall.toString <| GDhall.encode ui )
                        , ( Graph, Graph.toString (always <| Just "*") (always <| Just "*") <| GGraph.toGraph ui )
                        ]
                Err error ->
                    ParseError <| Json.errorToString error
        SwitchTo output ->
            case model of
                Parsed _ outputs ->
                    Parsed output outputs
                _ -> model


main : Platform.Program () Model Action
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }