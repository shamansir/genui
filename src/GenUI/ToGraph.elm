module GenUI.ToGraph exposing (toGraph, nodeToString, edgeToString, Node, Edge)

{-| Converting to Graph.

@docs toGraph, nodeToString, edgeToString

-}

import Graph exposing (Graph)

import GenUI as G


{-| Node is just G.Property -}
type alias Node a = G.Property a

{-| Edge holds both the parent and its child -}
type alias Edge a = { parent : G.Property a, child : G.Property a }


{-| Convert GenUI structure to Graph where nodes represent controls and folders and edges connect inner controls to their folders.

IDs for nodes are given using `GenUI.withIndices` (incremental and not bound to the deepness level). The root node has the ID of -1.

The root node is created to hold properties that are on the top level. The first argument is the value for this root node.
-}
toGraph : a -> G.GenUI a -> Graph (Node a) (Edge a)
toGraph ra ui =
    let
        rootId : Graph.NodeId
        rootId = -1
        rootProp : G.Property (Graph.NodeId, a)
        rootProp = G.root ( rootId, ra )
        rootNode = Graph.Node rootId rootProp
        iui : G.GenUI (Graph.NodeId, a)
        iui = G.withIndices ui
        removeId : G.Property (Graph.NodeId, a) -> G.Property a
        removeId = G.mapProperty Tuple.second
        getId : G.Property (Graph.NodeId, a) -> Graph.NodeId
        getId = G.get >> Tuple.first
    in Graph.fromNodesAndEdges
        (G.fold
            (\prop list ->
                Graph.Node (getId prop) prop :: list
            )
            [ rootNode ]
            iui)
        (G.foldWithPath
            (\path maybeParent prop list ->
                if (List.length path > 1) then
                    case maybeParent of
                        Just parent ->
                            Graph.Edge (getId parent) (getId prop) { parent = parent, child = prop } :: list
                        Nothing ->
                            list
                            -- Graph.Edge -1 (pathToId path) (Just rootProp, prop) :: list
                else
                    Graph.Edge rootId (getId prop) { parent = rootProp, child = prop } :: list
            )
            [ ]
            iui)
        |> Graph.mapNodes removeId
        |> Graph.mapEdges (\{ parent, child } -> { parent = removeId parent, child = removeId child })


{-| The short representation of the property. -}
nodeToString : Node a -> Maybe String
nodeToString ( prop, _ ) =
    Just <| prop.name ++ " :: " ++ G.defToString prop.def



{-| The short representation of the edge. -}
edgeToString : Edge a -> Maybe String
edgeToString { parent, child } =
    Just <| (parent |> nodeToString |> Maybe.withDefault "-") ++ " -> " ++ (child |> nodeToString |> Maybe.withDefault "-")