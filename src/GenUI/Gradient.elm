module GenUI.Gradient exposing (Gradient(..), Stop, Stop2D, toString, fromString, ParseError, errorToString)



{-| Gradient. The linear one and two-dimensional one.

@docs Gradient, Stop, Stop2D

# Conversion to/from string

@docs toString, fromString, ParseError, errorToString
-}


import GenUI.Color as Color exposing (Color)


{-| -}
type ParseError
    = WrongStop Int String
    | WrongStopX Int String
    | WrongStopY Int String
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


{-| -}
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


{-| -}
fromString : String -> Result ParseError Gradient
fromString str =
    let
        extractS1 n s1 =
            case String.split ";" s1 of
                mcolor::mpos::_ ->
                    Result.map2
                        (\p color -> { position = p, color = color })
                        (String.toFloat mpos |> Result.fromMaybe (WrongStop n mpos))
                        (Color.fromString mcolor
                        |> Result.mapError (WrongColor n))
                _ -> Err <| WrongStop n s1
        extractS2 n s2 =
            case String.split ";" s2 of
                mcolor::mpos::_ ->
                    case String.split "," mpos of
                        mx::my::_ ->
                            Result.map3
                                (\x y color -> { position = { x = x, y = y }, color = color })
                                (String.toFloat mx |> Result.fromMaybe (WrongStopX n mx))
                                (String.toFloat my |> Result.fromMaybe (WrongStopY n my))
                                (Color.fromString mcolor |> Result.mapError (WrongColor n))
                        _ -> Err <| WrongStop n mpos
                _ -> Err <| WrongStop n s2
    in if String.startsWith "lin" str then
            str
                |> String.slice 4 -1
                |> String.split "|"
                |> List.indexedMap extractS1
                |> List.map Result.toMaybe
                |> List.filterMap identity
                |> Linear
                |> Ok
        else if String.startsWith "2d" str then
            str
                |> String.slice 3 -1
                |> String.split "|"
                |> List.indexedMap extractS2
                |> List.map Result.toMaybe
                |> List.filterMap identity
                |> TwoDimensional
                |> Ok
        else Err <| WrongCompletely str


{-| -}
errorToString : ParseError -> String
errorToString  pe =
    case pe of
        WrongStop n val -> "Wrong stop value at " ++ String.fromInt n ++ ": " ++ val
        WrongStopX n val -> "Wrong stop X value at " ++ String.fromInt n ++ ": " ++ val
        WrongStopY n val -> "Wrong stop Y value at " ++ String.fromInt n ++ ": " ++ val
        WrongColor n cerr -> "Wrong color value at " ++ String.fromInt n ++ ": " ++ Color.errorToString cerr
        WrongLinear val -> "Wrong linear gradient: " ++ val
        Wrong2D val -> "Wrong 2D gradient: " ++ val
        WrongCompletely val -> "Failed to parse gradient: " ++ val
