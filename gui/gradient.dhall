let P = ../genui.dhall
let b = ../genui.build.dhall

let JSON = https://prelude.dhall-lang.org/JSON/package.dhall


let resolutions = [ "1920x1080", "1080x1080", "1280x800", "800x800", "4K" ]

let products =
    [ "JetBrains", "Space", "IDEA", "PhpStorm", "PyCharm", "RubyMine", "CLion", "DataGrip"
    , "AppCode", "GoLand", "ReSharper", "ReSharper C++", "dotCover", "dotPeek", "dotMemory", "dotTrace"
    , "Rider", "TeamCity", "YouTrack", "Upsource", "Hub", "Kotlin", "Mono", "MPS", "IDEA Edu", "PyCharm Edu"
    , "DataSpell", "Qodana", "Datalore", "CodeWithMe", "WebStorm", "Edu Tools", "Fleet"
    ] -- TODO: sort

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
    , b.select "size" resolutions "1920x1080"
        // b.bind_to "resolution"
    , b.float "quality" { min = 0.1, max = 4.0, step = 0.05, current = 1.0 }
        // b.bind_to "resolutionFactor"
    , b.float "zoom" { min = 0.5, max = 3.0, step = 0.01, current = 1.0 }
        // b.bind_to "scale"
    , b.int "rotate" { min = -180, max = +180, step = +5, current = +0 }
        // b.bind_to "rotation"
    , b.int "horizontal" { min = -1000, max = +1000, step = +10, current = +0 }
        // b.bind_to "offsetX"
    , b.int "vertical" { min = -1000, max = +1000, step = +10, current = +0 }
        // b.bind_to "offsetY"
    , b.action "color map"
        // b.bind_to "callGradientTool"
    , b.nest
        "neuro"
        (b.children
            [ b.int "seed" { min = +0, max = +50000, step = +1, current = +5 }
            , b.int "depth" { min = +1, max = +10, step = +1, current = +5 }
            , b.int "width" { min = +1, max = +10, step = +1, current = +5 }
            , b.int "variance" { min = +1, max = +10000, step = +1, current = +2000 }
            , b.select "mode" modes "fan_in"
            , b.select "distribution" distributions "truncated_normal"
            , b.select "architecture" architectures "densenet"
            , b.select "activation" activations "sigmoid"
            , b.select "outActivation" activations "sigmoid"
            , b.select "fMode" f_modes "disabled"
            ]
        )
        b._collapsed
    , b.nest
        "evolve"
        (b.children
            [ b.float "α" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "alpha"
            , b.float "β" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "beta"
            , b.float "γ" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // b.bind_to "gamma"
            ]
        )
        b._collapsed
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
            , b.int "flat color qty" { min = +5, max = +30, step = +1, current = +5 }
                // b.bind_to "flatLinesNum"
            , b.float "dither" { min = 0.0, max = 1.0, step = 0.05, current = 0.0 }
                // b.bind_to "ditherStrength"
            ]
        )
        b._collapsed
    , b.toggle "logo" True
        // b.bind_to "logoShown"
    , b.action "undo"
    , b.action "create URL" // b.bind_to "save"
    , b.action "export" // b.bind_to "export_"
    , b.action "video" // b.bind_to "requestVideo"
    ] : P.GenUI