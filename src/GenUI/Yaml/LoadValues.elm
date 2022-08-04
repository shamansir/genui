module GenUI.Yaml.LoadValues exposing (loadValues)


{-| @docs loadValues
-}

import Yaml.Decode as D

import GenUI as G
import GenUI.Color as Color exposing (Color)
import GenUI.Gradient as Gradient exposing (Gradient)


{-| Load values from the `Yaml.Decode.Value` and apply them to the given UI.

Example of the YAML values definition:

```yaml
product: RubyMine
resolution: 1920x1080
resolutionFactor: 1
scale: 2
rotation: 20
offsetX: 13
offsetY: 14
callGradientTool: [[action]]
neuro:
    seed: 5
    depth: 5
    width: 5
    variance: 2000
    mode: fan_in
    distribution: truncated_normal
    architecture: densenet
    activation: sigmoid
    outActivation: sigmoid
    fMode: disabled
evolve:
    alpha: 0.5
    beta: 0.5
    gamma: 1.0
mutation:
    randomMid: [[action]]
    randomMax: [[action]]
lab:
    flatColors: true
    flatLinesNum: 5
    ditherStrength: 0
logoShown: true
undo: [[action]]
save: [[action]]
export_: [[action]]
video:
    animFunc: Random spline animation
    videoFps: 60
    videoLength: 30
    maskFilename:
    videoInvertMask: false
    videoCodec: h264_8bit
    videoIntensity: 3
    requestVideo: [[action]]
```

Loads values using `Yaml.Decode.at` knowing the paths from given UI and skipping the values if they are failed to parse.

 -}

loadValues : D.Value -> G.GenUI a -> G.GenUI a
loadValues root =
    let
        updateDef pPath def =
            case def of
                G.NumInt nd ->
                    helper pPath D.int <| \ci -> G.NumInt { nd | current = ci }

                G.NumFloat fd ->
                    helper pPath D.float <| \cf -> G.NumFloat { fd | current = cf }

                G.XY xyd ->
                    helper pPath
                        (D.map2
                            (\x y -> { x = x, y = y })
                            (D.field "x" D.float)
                            (D.field "y" D.float)
                        )
                    <|
                        \cxy ->
                            let
                                ( xd, yd ) =
                                    ( xyd.x, xyd.y )
                            in
                            G.XY
                                { x = { xd | current = cxy.x }
                                , y = { yd | current = cxy.y }
                                }

                G.Toggle bd ->
                    helper pPath D.bool <| \cb -> G.Toggle { bd | current = cb }

                G.Color cd ->
                    helper pPath
                        (D.string
                            |> D.map Color.fromString
                            |> D.andThen
                                (\resColor ->
                                    case resColor of
                                        Ok color ->
                                            D.succeed color

                                        Err failure ->
                                            D.fail <| Color.errorToString failure
                                )
                        )
                    <|
                        \cc -> G.Color { cd | current = cc }

                G.Gradient gd ->
                    helper pPath
                        (D.string
                            |> D.map Gradient.fromString
                            |> D.andThen
                                (\resColor ->
                                    case resColor of
                                        Ok color ->
                                            D.succeed color

                                        Err failure ->
                                            D.fail <| Gradient.errorToString failure
                                )
                        )
                    <|
                        \cg -> G.Gradient { gd | current = cg }

                G.Textual td ->
                    helper pPath D.string <| \ct -> G.Textual { td | current = ct }

                G.Select sd ->
                    helper pPath D.string <| \cs -> G.Select { sd | current = cs }

                G.Zoom zd ->
                    helper pPath D.float <| \cz -> G.Zoom { zd | current = cz }

                _ ->
                    Result.Ok def

        helper : G.Path -> D.Decoder x -> (x -> G.Def a) -> Result D.Error (G.Def a)
        helper pPath decoder modifyDef =
            root
                |> D.fromValue (D.at pPath decoder)
                |> Result.map modifyDef
    in
    G.update
        (\( _, pPath ) ( prop, a ) ->
            Just
                (
                    { prop
                    | def = updateDef pPath prop.def
                        |> Result.withDefault prop.def
                    }
                , a
                )
        )