let P = ../genui.dhall
let b = ../genui.build.dhall

let select_items = [ "A", "B", "C", "D", "E", "F", "G" ]

let select_knob_items = [ "NN", "OO", "PP", "QQ", "RR", "SS", "TT" ]

let select_switch_items = [ "UU", "VV", "WW", "XX", "YY", "ZZ" ]

in b.root
    [ b.int "int" { min = -180, max = +180, step = +5, current = +10 }
    , b.float "float" { min = 0.1, max = 4.0, step = 0.05, current = 1.0 }
        // b.bind_to "double"
    , b.xy "xy"
        { x = { min = 180.0, max = 180.0, step = 5.0, current = 20.0 }
        , y = { min = 100.0, max = 200.0, step = 3.0, current = 25.0 }
        }
    , b.toggle "toggle" True
    , b.color "rgb" (b._rgb 120.0 130.0 140.0)
    , b.color "rgba" (b._rgba 120.0 130.0 140.0 0.5)
    , b.color "hsl" (b._hsl 210.0 8.0 51.0)
    , b.color "hsla" (b._hsla 210.0 8.0 51.0 0.5)
    , b.color "hex" (b._hex "#78828c")
    , b.action "action"
    , b.with_face
        (b.action "action_color")
        (b._color_f (b._rgb 120.0 130.0 140.0))
    , b.with_face
        (b.action "action_icon")
        (b._icon_f
            { dark = b._local "/foo/bar.dark.svg"
            , light = b._local "/foo/bar.light.svg"
            }
        )
    , b.with_face
        (b.action "action_icon_2")
        (b._l_icon_f (b._remote "/foo/bar.svg"))
    , b.progress "progress" (b._remote "/task/api")
    , b.select "select" select_items "B"
        // b.bind_to "the_select"
    , b.gradient "gradient"
        (b._linear
            [ b._s 0.0 (b._rgb 50.0 100.0 50.0)
            , b._s 0.7 (b._rgb 100.0 50.0 50.0)
            , b._s 1.0 (b._rgb 50.0 50.0 100.0)
            ]
        )
    , b.gradient "gradient2d"
        (b._2d
            [ b._s2 0.0 0.0 (b._rgb 50.0 100.0 50.0)
            , b._s2 0.7 0.7 (b._rgb 100.0 50.0 50.0)
            , b._s2 1.0 1.0 (b._rgb 50.0 50.0 100.0)
            ]
        )
    , b.nest
        "nest"
        ( b.children
            [ b.action "child1" // b.bind_to "c1"
            , b.action "child2" // b.bind_to "c2"
            , b.action "child3" // b.map_to [ "c1", "c2" ]
            , b.toggle "toggle" True // b.live
            , b.color "hsl" (b._hsl 210.0 8.0 51.0)
            , b.text "text" "foo" // b.trigger_on [ "c1", "c2" ]
            , b.select_knob "sel_knob" select_knob_items "NN"
            , b.select_switch "sel_swi" select_switch_items "UU"
            , b.nest
                "subnest"
                (b.children
                    [ b.action "act"
                    , b.zoom "zoom"
                    , b.ghost "aa"
                    , b.zoom_by "zoom_by" 1.0 [ 0.1, 0.3, 0.5, 1.0, 2.0, 3.0 ]
                    ]
                )
                b._expanded
            , b.with_paging
                (b.with_face
                    (b.nest
                        "subnest2"
                        (b.children
                            [ b.action "foo"
                            , b.action "bar"
                            ]
                        )
                        b._collapsed
                    )
                    b._title_f
                )
                b._single
                b._first
            ]
        )
        b._collapsed
    ] : P.GenUI