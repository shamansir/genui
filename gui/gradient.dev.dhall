let P = https://cdn.jsdelivr.net/gh/shamansir/genui/genui.dhall
let b = https://cdn.jsdelivr.net/gh/shamansir/genui/genui.build.dhall

let pset = https://resources.jetbrains.com/cai/brand-data/products.set.dhall
let pgen = https://resources.jetbrains.com/cai/brand-data/products.gen.dhall

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let resolutions = [ "custom", "1920x1080", "1080x1080", "1280x800", "800x800", "4K" ]

let products =
    pgen.toNameSet pset.internal

{- let periodic_fn =
    [ "None", "Sin", "Tan(square)", "Squares#2", "Squares and stripes", "Tiles with bubbles"
    , "Experimental", "Experimental2", "Experimental3"
    ] -}

let modes =
    [ "fan_in", "fan_out", "fan_avg"
    ]

let distributions =
    [ "truncated_normal", "normal", "untruncated_normal", "uniform"
    ]

let architectures =
    [ "perceptron", "densenet", "resnet", "resnet_concat", "chain", "plexus"
    ]

let activations =
    [ "gelu", "hard_sigmoid", "linear", "sigmoid", "sinus", "experimental1", "tanh"
    ]

let f_modes =
    [ "disabled", "all"
    ]

let animations =
    [ "Default animation", "Bernoulli animation", "Random spline animation", "Video mask animation", "detalization", "flow", "color"
    ]

let codecs =
    [ "h264_8bit", "h264_10bit", "h265_8bit", "h265_10bit", "webm_vp8", "webm_vp9", "mov_prores"
    ]

in b.root
    [ b.select "product" products "JetBrains"
    , b.toggle "masterpiece" True
    , b.select "size" resolutions "1920x1080"
        // b.bind_to "resolution" -- // b.live
    , b.text "width" "-"
        // b.bind_to "customWidth"
        // b.map_to [ "input", "x_resolution" ]
    , b.text "height" "-"
        // b.bind_to "customHeight"
        // b.map_to [ "input", "y_resolution" ]
    , b.float "quality" { min = 0.1, max = 4.0, step = 0.05, current = 1.0 }
        // b.bind_to "resolutionFactor"
        // b.map_to [ "input", "resolution_factor" ]
    , b.float "zoom" { min = 0.5, max = 3.0, step = 0.01, current = 1.0 }
        // b.bind_to "scale"
        // b.map_to [ "input", "scale" ]
        -- // b.live
    , b.action "zoom in" // b.bind_to "zoomIn"
    , b.action "zoom out" // b.bind_to "zoomOut"
    , b.int "rotate" { min = -180, max = +180, step = +5, current = +0 }
        // b.bind_to "rotation"
        // b.map_to [ "input", "rotation" ]
    , b.int "horizontal" { min = -1000, max = +1000, step = +10, current = +0 }
        // b.bind_to "offsetX"
        // b.map_to [ "input", "offset_x" ]
    , b.int "vertical" { min = -1000, max = +1000, step = +10, current = +0 }
        // b.bind_to "offsetY"
        // b.map_to [ "input", "offset_y" ]
    , b.action "color map"
        // b.bind_to "callGradientTool"
    , b.nest
        "neuro"
        (b.children
            [ b.int "seed" { min = +0, max = +50000, step = +1, current = +5 }
                // b.map_to [ "model", "seed" ]
            , b.int "depth" { min = +1, max = +10, step = +1, current = +5 }
                // b.map_to [ "model", "depth" ]
            , b.int "width" { min = +1, max = +10, step = +1, current = +5 }
                // b.map_to [ "model", "width" ]
            , b.int "variance" { min = +1, max = +10000, step = +1, current = +2000 }
                // b.map_to [ "model", "variance" ]
            , b.select "mode" modes "fan_in"
                // b.map_to [ "model", "mode" ]
            , b.select "distribution" distributions "truncated_normal"
                // b.map_to [ "model", "distribution" ]
            , b.select "architecture" architectures "densenet"
                // b.map_to [ "model", "architecture" ]
            , b.select "activation" activations "sigmoid"
                // b.map_to [ "model", "activation" ]
            , b.select "outActivation" activations "sigmoid"
                // b.map_to [ "model", "out_activation" ]
            , b.select "fMode" f_modes "disabled"
                // b.map_to [ "model", "f_mode" ]
            ]
        )
        b._collapsed -- // b.nest_at "model"
    , b.nest
        "evolve"
        (b.children
            [ b.float "α" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "alpha"
                // b.map_to [ "input", "alpha" ]
            , b.float "β" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "beta"
                // b.map_to [ "input", "beta" ]
            , b.float "γ" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "gamma"
                // b.map_to [ "input", "z" ]
            ]
        )
        b._collapsed -- // b.nest_at "input"
    , b.nest
        "mutation"
        (b.children
            [ b.action "mild" // b.bind_to "randomMid"
            , b.action "hard" // b.bind_to "randomMax"
            ]
        )
        b._collapsed
    , b.nest
        "lab"
        (b.children
            [ b.toggle "flat colors" False
                // b.bind_to "flatColors"
                // b.map_to [ "post_fx", "color_mode" ]
            , b.int "flat color qty" { min = +5, max = +30, step = +1, current = +5 }
                // b.bind_to "flatLinesNum"
                // b.map_to [ "post_fx", "num_flat_lines" ]
            , b.float "dither" { min = 0.0, max = 1.0, step = 0.05, current = 0.0 }
                // b.bind_to "ditherStrength"
                // b.map_to [ "post_fx", "dither_strength" ]
            ]
        )
        b._collapsed
    , b.toggle "logo" True
        // b.bind_to "logoShown"
    , b.toggle "anchors" False
        // b.bind_to "anchorsManager"
    , b.action "undo"
    , b.action "create URL" // b.bind_to "save"
    , b.action "export" // b.bind_to "export_"
    , b.nest
        "video"
        (b.children
            [ b.select "function" animations "Random spline animation"
                // b.bind_to "animFunc"
                // b.map_to [ "animation", "func" ]
            , b.text "fps" "60"
                // b.bind_to "videoFps"
                // b.map_to [ "animation", "fps" ]
            , b.text "length" "30"
                // b.bind_to "videoLength"
                // b.map_to [ "animation", "length" ]
            , b.text "mask" ""
                // b.bind_to "maskFilename"
                // b.map_to [ "animation", "video_mask_filename" ]
            , b.toggle "invertMask" False
                // b.bind_to "videoInvertMask"
                // b.map_to [ "animation", "invert_mask" ]
            , b.select "codec" codecs "h264_8bit"
                // b.bind_to "videoCodec"
                // b.map_to [ "animation", "preset" ]
            , b.float "intensity" { min = 0.1, max = 10.0, step = 0.05, current = 3.0 }
                // b.bind_to "videoIntensity"
                // b.map_to [ "animation", "intensity" ]
            , b.action "request"
                // b.bind_to "requestVideo"
            , b.action "shader"
                // b.bind_to "requestShader"
            ]
        )
        b._collapsed -- // b.nest_at "animation"
    ] : P.GenUI