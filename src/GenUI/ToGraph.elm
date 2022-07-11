module GenUI.ToGraph exposing (toGraph, nodeToString, edgeToString)

{-| Converting to Graph.

@docs toGraph, nodeToString, edgeToString

-}

import Graph exposing (Graph)

import GenUI as G


pathToId : List Int -> Int
pathToId path =
    let
        pathLen = List.length path
    in path
        |> List.indexedMap
            (\idx pos -> pos * (100 ^ (pathLen - 1 - idx))) -- FIXME: not very reliable
        |> List.sum


toParentId : List Int -> Int
toParentId path =
    let
        pathLen = List.length path
    in
        List.take
            (pathLen - 1)
            path
            |> pathToId


{-| Convert GenUI structure to Graph where nodes represent the controls and folders and edges connect child controls to the folders.

The root node has the ID of `-1`,  the ID for other nodes is calculated based on their parent and the position inside.

-}
toGraph : G.GenUI -> Graph G.Property ()
toGraph ui =
    Graph.fromNodesAndEdges
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