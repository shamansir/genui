module Demo exposing (..)


import Graph as Graph
import Graph.DOT as DOT
import Dict exposing (Dict)

import Json.Decode as JsonD
import Json.Encode as JsonE
import Yaml.Decode as YamlD
import Yaml.Encode as YamlE

import GenUI as G
import GenUI.Json.Decode as GenUIJson
import GenUI.Json.Encode as GenUIJson
import GenUI.Json.LoadValues as GenUIJson
import GenUI.Json.ToValues as GenUIJson
import GenUI.Yaml.Encode as GenUIYaml
import GenUI.Yaml.LoadValues as GenUIYaml
import GenUI.Yaml.ToValues as GenUIYaml
import GenUI.Dhall.Encode as GenUIDhall
import GenUI.Descriptive.Encode as Descriptive
import GenUI.ToGraph as GenUIGraph


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
    | ValuesJson
    | ValuesYaml


defaultOutput : Output
defaultOutput = Descriptive


type Model
    = Empty
    | ParseError String
    | Parsed Output (G.GenUI ()) (List (Output, String))  -- (Dict Output String)


type Action
    = New
    | Parse String
    | SwitchTo Output
    | LoadJsonValues String
    | LoadYamlValues String
    | NoOp
    -- FromUrl String


init : Model
init = Empty


view : Model -> Html Action
view model =
    let
        modeButton currentMode mode =
            button
                [ onClick <| SwitchTo mode
                , style "background-color" <|
                    if mode == currentMode then "darkgray"
                        else "gray"
                ]
                [ text <| case mode of
                    Descriptive -> "Descriptive"
                    Json -> "JSON"
                    Yaml -> "YAML"
                    Graph -> "Graph"
                    Dhall -> "DHALL"
                    ValuesJson -> "Values (JSON)"
                    ValuesYaml -> "Values (Yaml)"
                ]
    in case model of
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
                    , text "Insert JSON"
                    ]
                ]
        Parsed curOutput _ outputs ->
            div [ ]
                <| button [ onClick New ] [ text "New" ]
                :: (div []
                        <| List.map (modeButton curOutput) [ Descriptive, Json, Yaml, Graph, Dhall, ValuesJson, ValuesYaml ]
                   )
                :: List.map
                    ( \(output, parsed) ->
                        textarea
                            [ style "z-index"
                                <| if output == curOutput then "10000" else "0"
                            , style "position" "absolute"
                            , cols 150
                            , rows 150
                            , onInput
                                <| if output == ValuesJson then LoadJsonValues
                                else if output == ValuesYaml then LoadYamlValues
                                else always NoOp
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
                Parsed output _ _ -> output
                _ -> defaultOutput
        makeOutputs ui =
            [ ( Descriptive, Descriptive.toString <| Descriptive.encode ui )
            , ( Json, JsonE.encode 4 <| GenUIJson.encode ui )
            , ( Yaml, YamlE.toString 4 <| GenUIYaml.encode ui )
            , ( Dhall, GenUIDhall.toString <| GenUIDhall.encode ui )
            , ( Graph, DOT.output GenUIGraph.nodeToString GenUIGraph.edgeToString <| GenUIGraph.toGraph () ui )
            , ( ValuesJson, JsonE.encode 4 <| GenUIJson.toValues ui )
            , ( ValuesYaml, YamlE.toString 4 <| GenUIYaml.toValues ui )
            ]

    in

    case action of
        NoOp -> model
        New -> Empty
        Parse string ->
            case decodeString GenUIJson.decode string of
                Ok ui ->
                    Parsed curOutput ui <| makeOutputs ui
                Err error ->
                    ParseError <| JsonD.errorToString error
        SwitchTo output ->
            case model of
                Parsed _ ui outputs ->
                    Parsed output ui outputs
                _ -> model
        LoadJsonValues valuesJson ->
            case model of
                Parsed _ ui _ ->
                    JsonD.decodeString JsonD.value valuesJson
                        |> Result.map (\value -> GenUIJson.loadValues value ui)
                        |> Result.map (\nextUi -> Parsed curOutput nextUi <| makeOutputs nextUi)
                        |> Result.withDefault model
                _ -> model
        LoadYamlValues valuesYaml ->
            case model of
                Parsed _ ui _ ->
                    YamlD.fromString YamlD.value valuesYaml
                        |> Result.map (\value -> GenUIYaml.loadValues value ui)
                        |> Result.map (\nextUi -> Parsed curOutput nextUi <| makeOutputs nextUi)
                        |> Result.withDefault model
                _ -> model


main : Platform.Program () Model Action
main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }