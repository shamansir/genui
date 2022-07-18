module Util.Indent exposing (..)


type alias Indent =
    Int


type alias Index =
    Int


{-| -}
type alias Indented =
    List ( Indent, String )


type alias IndentedWithIndices =
    List ( Index, ( Indent, String ) )


indent : Indented -> Indented
indent =
    indentBy 1


indentBy : Int -> Indented -> Indented
indentBy amount =
    List.map (Tuple.mapFirst ((+) amount))


indented : String -> Indented
indented s = [ ( 0, s ) ]


-- addIndices :  Indented -> IndentedWithIndices
-- addIndices = List.indexedMap Tuple.pair
-- prependIndices : IndentedWithIndices -> Indented
-- prependIndices = List.map (\(idx, (i, str)) -> (i, String.fromInt idx ++ ". " ++ str)



{- flatten : List Indented -> List ( Indent, String )
   flatten = List.concat
-}
