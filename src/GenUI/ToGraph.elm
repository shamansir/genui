module GenUI.ToGraph exposing (toGraph, nodeToString, nodeToString_, edgeToString, edgeToString_)

{-| Converting to Graph.

@docs toGraph, nodeToString, edgeToString

-}

import Graph exposing (Graph)

import GenUI as G


type alias Node a = G.Property a

type alias Edge a = (Maybe (G.Property a), G.Property a)


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

The first argument is the value for this root node.
-}
toGraph : a -> G.GenUI a -> Graph (Node a) (Edge a)
toGraph ra ui =
    let
        rootId = -1
        rootProp = G.root ra
        rootNode = Graph.Node rootId rootProp
    in Graph.fromNodesAndEdges
        (G.foldWithPath
            (\path _ prop list ->
                Graph.Node (pathToId path) prop :: list
            )
            [ rootNode ]
            ui)
        (G.foldWithPath
            (\path maybeParent prop list ->
                if (List.length path > 1) then
                    case maybeParent of
                        Just _ ->
                            Graph.Edge (toParentId path) (pathToId path) (maybeParent, prop) :: list
                        Nothing ->
                            list
                            -- Graph.Edge -1 (pathToId path) (Just rootProp, prop) :: list
                else
                    Graph.Edge rootId (pathToId path) (Just rootProp, prop) :: list
            )
            [ ]
            ui)
    {- Graph.fromNodesAndEdges
        (G.fold ) -}


{-| The short representation of the property. -}
nodeToString : G.Property a -> Maybe String
nodeToString ( prop, _ ) =
    Just <| prop.name ++ " :: " ++ G.defToString prop.def



{-| The short representation of the property. -}
nodeToString_ : (a -> String) -> G.Property a -> Maybe String
nodeToString_ toStr ( prop, a ) =
    Just <| toStr a ++ " :: " ++ prop.name ++ " :: " ++ G.defToString prop.def



{-| The short representation of the edge. -}
edgeToString : a -> Maybe String
edgeToString _ = Just "*"


{-| The short representation of the edge. -}
edgeToString_ : (a -> String) -> a -> Maybe String
edgeToString_ toString a = Just <| toString a