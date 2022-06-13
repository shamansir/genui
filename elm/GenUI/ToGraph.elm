module GenUI.Graph exposing (..)

import Graph exposing (Graph)

import GenUI as G


toGraph : G.GenUI -> Graph G.Property ()
toGraph _ = Graph.empty