let P =
    env:LOCAL_DHALL
        ? ../genui.dhall
        ? https://cdn.jsdelivr.net/gh/shamansir/genui/genui.dhall
let b =
    env:LOCAL_DHALL
        ? ../genui.build.dhall
        ? https://cdn.jsdelivr.net/gh/shamansir/genui/genui.build.dhall


let q_icon =
    \(name : Text) ->
        b._icons_f (
            [ { theme = b._light, url = b._local ("assets/tiler/dark-stroke/" ++ name ++ ".svg") }
            , { theme = b._dark, url = b._local ("assets/tiler/light-stroke/" ++ name ++ ".svg") }
            ]
        )

let BG_color_items = [ "front", "middle", "rear" ]
let Base_color_items = [ "default", "black", "white" ]
let Click_action_items = [ "Rotate", "Modify tile", "Change opacity" ]
let Product_items = [ "JetBrains", "Space", "IntelliJ IDEA", "PhpStorm", "PyCharm", "RubyMine", "WebStorm", "CLion", "DataGrip", "AppCode", "GoLand", "ReSharper", "ReSharper C++", "dotCover", "dotMemory", "dotPeek", "dotTrace", "Rider", "TeamCity", "YouTrack", "Upsource", "Hub", "Kotlin", "MPS", "IntelliJ IDEA Edu", "PyCharm Edu", "Datalore" ]
 let Tileset_items = [ ] : List Text
in b.root
    [ b.nest
        "root"
        ( b.children
            [ b.nest
                "Color Scheme"
                ( b.children
                    [ b.select "Product" Product_items "JetBrains"
                    , b.select "Base color" Base_color_items "white"
                    , b.select "BG color" BG_color_items "front"
                    , b.float "Opacity"  { min = 0.0 , max = 255.0 , step = 1.0 , current = 0.0}
                    ]
                )
                b._expanded
            , b.nest
                "Sizes"
                ( b.children
                    [ b.float "Cell"  { min = 60.0 , max = 200.0 , step = 1.0 , current = 100.0}
                    , b.float "Shape"  { min = 0.1 , max = 5.0 , step = 0.1 , current = 1.0}
                    , b.toggle "Fullscreen" True
                    ]
                )
                b._collapsed
            , b.nest
                "Tile"
                ( b.children
                    [ b.select "Tileset" Tileset_items ""
                    , b.float "Stroke weight"  { min = 0.0 , max = 10.0 , step = 1.0 , current = 0.0}
                    , b.float "Fill α"  { min = 0.0 , max = 255.0 , step = 1.0 , current = 178.0}
                    , b.float "Stroke α"  { min = 0.0 , max = 255.0 , step = 1.0 , current = 255.0}
                    ]
                )
                b._collapsed
            , b.nest
                "Randomness"
                ( b.children
                    [ b.float "Diversity"  { min = 1.0 , max = 0.0 , step = 1.0 , current = 0.0}
                    , b.float "Tones"  { min = 3.0 , max = 17.0 , step = 2.0 , current = 3.0}
                    , b.with_face
                        (b.action "Recolor")
                        (q_icon "update")
                    , b.toggle "Gradient" False
                    ]
                )
                b._collapsed
            , b.nest
                "Title"
                ( b.children
                    [ b.toggle "Show" True
                    , b.float "X"  { min = 0.0 , max = 0.0 , step = 1.0 , current = 0.0}
                    , b.float "Y"  { min = 0.0 , max = 0.0 , step = 1.0 , current = 0.0}
                    , b.float "Scale"  { min = 0.1 , max = 5.0 , step = 0.1 , current = 0.0}
                    ]
                )
                b._collapsed
            , b.nest
                "Logo"
                ( b.children
                    [ b.toggle "Show" True
                    , b.float "X"  { min = 0.0 , max = -1.0 , step = 1.0 , current = -1.0}
                    , b.float "Y"  { min = 0.0 , max = -1.0 , step = 1.0 , current = -1.0}
                    ]
                )
                b._collapsed
            , b.nest
                "Animation"
                ( b.children
                    [ b.toggle "Animate" False
                    , b.float "Duration"  { min = 0.0 , max = 4.0 , step = 0.1 , current = 3.0}
                    , b.float "Delay"  { min = 0.0 , max = 4.0 , step = 0.1 , current = 3.0}
                    ]
                )
                b._collapsed
            , b.select "Click action" Click_action_items "Modify tile"
            , b.with_face
                (b.action "Shuffle tiles")
                (q_icon "shuffle")
            , b.with_face
                (b.action "Refresh")
                (q_icon "update")
            , b.with_face
                (b.action "Make URL")
                (q_icon "link")
            , b.with_face
                (b.action "Export")
                (q_icon "save")
            , b.with_face
                (b.action "Upload tiles")
                (q_icon "export")
            , b.float "TestValue"  { min = 0.0 , max = 4000.0 , step = 1.0 , current = 0.0}
            ]
        )
        b._expanded
    ]
: P.GenUI