module GenUI.Gradient exposing (Stop, Stop2D, Gradient(..), toString, fromString)


import GenUI.Color as Color exposing (Color)
import Html exposing (s)


{-| -}
type alias Stop = { color : Color, position : Float }


{-| -}
type alias Stop2D = { color : Color, position : { x : Float, y : Float } }


{-| -}
type Gradient
    = Linear (List Stop)
    | TwoDimensional (List Stop2D)


toString : Gradient -> String
toString c =
    let
        s1 { color, position } = String.fromFloat position ++ ";" ++ Color.toString color
        s2 { color, position } = String.fromFloat position.x ++ "," ++ String.fromFloat position.y ++ ";" ++ Color.toString color
    in case c of
        Linear lstops ->
            "lin(" ++ (String.join "|" <| List.map s1 lstops) ++ ")"

        TwoDimensional tdstops ->
            "2d(" ++ (String.join "|" <| List.map s2 tdstops) ++ ")"


fromString : String -> Maybe Gradient
fromString str =
    let
        extractS1 s1 =
            case String.split ";" s1 of
                mcolor::mpos::_ ->
                    Maybe.map2
                        (\p color -> { position = p, color = color })
                        (String.toFloat mpos)
                        (Color.fromString mcolor)
                _ -> Nothing
        extractS2 s2 =
            case String.split ";" s2 of
                mcolor::mpos::_ ->
                    case String.split "," mpos of
                        mx::my::_ ->
                            Maybe.map3
                                (\x y color -> { position = { x = x, y = y }, color = color })
                                (String.toFloat mx)
                                (String.toFloat my)
                                (Color.fromString mcolor)
                        _ -> Nothing
                _ -> Nothing
    in if String.startsWith "lin" str then
            str
                |> String.slice 4 -1
                |> String.split "|"
                |> List.map extractS1
                |> List.filterMap identity
                |> Linear
                |> Just
        else if String.startsWith "2d" str then
            str
                |> String.slice 3 -1
                |> String.split "|"
                |> List.map extractS2
                |> List.filterMap identity
                |> TwoDimensional
                |> Just
        else Nothing