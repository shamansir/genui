module GenUI.ToGraph exposing (..)

import Graph exposing (Graph)

import GenUI as G


toGraph : G.GenUI -> Graph G.Property ()
toGraph ui =
    let
        pathToId =
            List.indexedMap
                (\idx pos -> pos * (100 ^ idx)) -- FIXME: not very reliable
            >> List.sum
        toParentId path =
            List.take (List.length path - 1) path
                |> pathToId
    in Graph.fromNodesAndEdges
        (G.foldWithPath
            (\path _ prop list ->
                Graph.Node (pathToId path) prop :: list
            )
            []
            ui
        )
        (G.foldWithPath
            (\path _ _ list ->
                Graph.Edge (toParentId path) (pathToId path) () :: list
            )
            []
            ui)
    {- Graph.fromNodesAndEdges
        (G.fold ) -}


nodeToString : G.Property -> Maybe String
nodeToString prop =
    Just <| prop.name ++ " :: " ++ G.defToString prop.def



edgeToString : () -> Maybe String
edgeToString _ = Just "*"