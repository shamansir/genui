module GenUI.ToGraph exposing (toGraph, nodeToString, edgeToString)

{-| Converting to Graph.

@docs toGraph, nodeToString, edgeToString

-}

import Graph exposing (Graph)

import GenUI as G



{-| Convert GenUI structure to Graph where nodes represent the controls and folders and edges connect child controls to the folders.

The root node has the ID of `-1`,  the ID for other nodes is calculated based on their parent and the position inside.

-}
toGraph : G.GenUI -> Graph G.Property ()
toGraph ui =
    let
        pathToId path =
            path
            |> List.indexedMap
                (\idx pos -> pos * (100 ^ (List.length path - 1 - idx))) -- FIXME: not very reliable
            |> List.sum
        toParentId path =
            List.take (List.length path - 1) path
                |> pathToId
    in Graph.fromNodesAndEdges
        (G.foldWithPath
            (\path _ prop list ->
                Graph.Node (pathToId path) prop :: list
            )
            [ Graph.Node -1 G.root ]
            ui)
        (G.foldWithPath
            (\path _ _ list ->
                if (List.length path > 1) then
                    Graph.Edge (toParentId path) (pathToId path) () :: list
                else
                    Graph.Edge -1 (pathToId path) () :: list
            )
            []
            ui)
    {- Graph.fromNodesAndEdges
        (G.fold ) -}


{-| The short representation of the property. -}
nodeToString : G.Property -> Maybe String
nodeToString prop =
    Just <| prop.name ++ " :: " ++ G.defToString prop.def



{-| The short representation of the edge. -}
edgeToString : () -> Maybe String
edgeToString _ = Just "*"