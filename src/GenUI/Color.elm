module GenUI.Color exposing (Color(..), ParseError, toString, fromString, errorToString)


{-| -}
type Color
    = Rgba { red : Float, green : Float, blue : Float, alpha : Float }
    | Hsla { hue : Float, saturation : Float, lightness : Float, alpha : Float }
    | Hex String


type ParseError
    = WrongRgba String
    | WrongHsla String
    | WrongHex String
    | WrongCompletely String


default : Color
default = Rgba { red = 0, green = 0, blue = 0, alpha = 1.0 }


toString : Color -> String
toString c =
    case c of
        Rgba { red, green, blue, alpha } ->
            "rgba(" ++ String.fromFloat red ++ ", " ++ String.fromFloat green ++ ", " ++ String.fromFloat blue ++ ", " ++ String.fromFloat alpha ++ ")"

        Hsla { hue, saturation, lightness, alpha } ->
            "hsla(" ++ String.fromFloat hue ++ ", " ++ String.fromFloat saturation ++ ", " ++ String.fromFloat lightness ++ ", " ++ String.fromFloat alpha ++ ")"

        Hex hex ->
            "hex(" ++ hex ++ ")"


fromString : String -> Result ParseError Color
fromString str =
    let
        valuesOf s =
            case String.split "," s of
                mv1::mv2::mv3::mv4::_ ->
                    Maybe.map4
                        (\v1 v2 v3 v4 -> { v1 = v1, v2 = v2, v3 = v3, v4 = v4 })
                        (String.toFloat mv1)
                        (String.toFloat mv2)
                        (String.toFloat mv3)
                        (String.toFloat mv4)
                _ -> Nothing
    in
        (if String.startsWith "rgba" str then
            str
                |> String.slice 5 -1
                |> valuesOf
                |> Maybe.map
                    (\{ v1, v2, v3, v4 } ->
                        Rgba { red = v1, green = v2, blue = v3, alpha = v4 }
                    )
                |> Result.fromMaybe (WrongRgba str)
            else if String.startsWith "hsla" str then
                str
                    |> String.slice 5 -1
                    |> valuesOf
                    |> Maybe.map
                        (\{ v1, v2, v3, v4 } ->
                            Hsla { hue = v1, saturation = v2, lightness = v3, alpha = v4 }
                        )
                    |> Result.fromMaybe (WrongHsla str)
            else if String.startsWith "hex" str then
                str
                    |> String.slice 5 -1
                    |> Hex
                    |> Ok
            else Err <| WrongCompletely str
        )


errorToString : ParseError -> String
errorToString pe =
    case pe of
        WrongRgba wrongRgba ->
            "Wrong RGBA: " ++ wrongRgba
        WrongHsla wrongHsla ->
            "Wrong HSLA: " ++ wrongHsla
        WrongHex wrongHex ->
            "Wrong HEX: " ++ wrongHex
        WrongCompletely wrongCompletely ->
            "Wrong completely: " ++ wrongCompletely