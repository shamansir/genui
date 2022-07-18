module GenUI.Gradient exposing (Stop, Stop2D, Gradient(..), toString, fromString, ParseError)


import GenUI.Color as Color exposing (Color)
import Html exposing (s)


type ParseError
    = WrongStop Int String
    | WrongColor Int Color.ParseError
    | WrongLinear String
    | Wrong2D String
    | WrongCompletely String


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


fromString : String -> Result String Gradient
fromString str =
    let
        extractS1 s1 =
            case String.split ";" s1 of
                mcolor::mpos::_ ->
                    Result.map2
                        (\p color -> { position = p, color = color })
                        (String.toFloat mpos |> Result.fromMaybe ("Failed to parse" ++ mpos))
                        (Color.fromString mcolor
                        |> Result.mapError Color.errorToString)
                _ -> Err <| "failed to parse " ++ s1
        extractS2 s2 =
            case String.split ";" s2 of
                mcolor::mpos::_ ->
                    case String.split "," mpos of
                        mx::my::_ ->
                            Result.map3
                                (\x y color -> { position = { x = x, y = y }, color = color })
                                (String.toFloat mx |> Result.fromMaybe ("Failed to parse " ++ mx))
                                (String.toFloat my |> Result.fromMaybe ("Failed to parse " ++ my))
                                (Color.fromString mcolor |> Result.mapError Color.errorToString)
                        _ -> Err <| "failed to split " ++ mpos
                _ -> Err <| "failed to parse " ++ s2
    in if String.startsWith "lin" str then
            str
                |> String.slice 4 -1
                |> String.split "|"
                |> List.map extractS1
                |> List.map Result.toMaybe
                |> List.filterMap identity
                |> Linear
                |> Ok
        else if String.startsWith "2d" str then
            str
                |> String.slice 3 -1
                |> String.split "|"
                |> List.map extractS2
                |> List.map Result.toMaybe
                |> List.filterMap identity
                |> TwoDimensional
                |> Ok
        else Err <| "failed to parse: " ++ str