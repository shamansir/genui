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

let achitectures =
    [ "perceptron", "densenet", "resnet", "resnet_concat", "chain", "plexus"
    ]

let activations =
    [ "gelu", "hard_sigmoid", "linear", "sigmoid", "sinus", "experimental1", "tanh"
    ]

let f_modes =
    [ "disabled", "all"
    ]

in b.root
    [ b.select_ "product" products "JetBrains"
    , b.select_ "size" resolutions "1920x1080"
        // { property = Some "resolution" }
    , b.float "quality" { min = 0.1, max = 4.0, step = 0.05, current = 1.0 }
        // { property = Some "resolutionFactor" }
    , b.float "zoom" { min = 0.5, max = 3.0, step = 0.01, current = 1.0 }
        // { property = Some "scale" }
    , b.int "rotate" { min = -180, max = +180, step = +5, current = +0 }
        // { property = Some "rotation" }
    , b.int "horizontal" { min = -1000, max = +1000, step = +10, current = +0 }
        // { property = Some "offsetX" }
    , b.int "vertical" { min = -1000, max = +1000, step = +10, current = +0 }
        // { property = Some "offsetY" }
    , b.int "destiny" { min = +0, max = +10000, step = +1, current = +0 }
        // { property = Some "offsetY" }
    , b.toggle_ "flat colors" True
        // { property = Some "flatColors" }
    , b.int "flat color qty" { min = +5, max = +30, step = +1, current = +5 }
        // { property = Some "flatLinesNum" }
    , b.action "gradient"
        // { property = Some "callGradientTool" }
    , b.float "dither" { min = 0.0, max = 1.0, step = 0.05, current = 0.0 }
        // { property = Some "ditherStrength" }
    , b.toggle_ "logo shown" True
        // { property = Some "logo" }
    , b.nest_
        "neuro"
        (b.children
            [ b.int "seed" { min = +0, max = +50000, step = +1, current = +5 }
            , b.int "depth" { min = +1, max = +10, step = +1, current = +5 }
            , b.int "width" { min = +1, max = +10, step = +1, current = +5 }
            , b.int "variance" { min = +1, max = +10000, step = +1, current = +2000 }
            , b.select_ "mode" modes "fan_in"
            , b.select_ "distribution" distributions "truncated_normal"
            , b.select_ "achitectures" achitectures "resnet"
            , b.select_ "activation" activations "gelu"
            , b.select_ "outActivation" activations "gelu"
            , b.select_ "fMode" f_modes "disabled"
            ]
        )
        False
    , b.action "save"
    , b.nest_
        "evolve"
        (b.children
            [ b.float "α" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // { property = Some "alpha" }
            , b.float "β" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // { property = Some "beta" }
            , b.float "γ" { min = 0.0, max = 1.0, step = 0.01, current = 0.5 }
                // { property = Some "gamma" }
            ]
        )
        False
    , b.nest_
        "mutation"
        (b.children
            [ b.action "min" // { property = Some "randomMin" }
            , b.action "mid" // { property = Some "randomMid" }
            , b.action "max" // { property = Some "randomMax" }
            ]
        )
        False
    , b.action "undo"
    , b.action "export"
        -- // { boundTo = Some "actions", property = Some "scale" }
    ] : P.GenUI