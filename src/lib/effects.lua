-- TODO: ripple を別ファイルに分割
-- TODO: require をなくす (1 つあたり 9 トークン減る)

-- 最初に require
-- すべてのエフェクトのベースクラス
require("lib/effects/effect_set")

require("lib/effects/bubbles")
require("lib/effects/ions")
require("lib/effects/particles")

--#ifn title
require("lib/effects/ripple")
--#endif

--#if endless
require("lib/sash")
--#endif

--#if rush
require("lib/sash")
--#endif

-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_title.p8 --count
-- tokens: 8134 99.29%
-- chars: 48567 74%
-- compressed: 12766 82%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_tutorial.p8 --count
-- tokens: 7850 95.83%
-- chars: 44990 69%
-- compressed: 11996 77%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_endless.p8 --count
-- tokens: 7955 97.11%
-- chars: 46566 71%
-- compressed: 12244 78%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_rush.p8 --count
-- tokens: 7657 93%
-- chars: 45160 69%
-- compressed: 11783 75%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_vs_qpu.p8 --count
-- tokens: 8124 99.17%
-- chars: 47907 73%
-- compressed: 12184 78%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_qpu_vs_qpu.p8 --count
-- tokens: 8079 98.62%
-- chars: 47651 73%
-- compressed: 12138 78%
-- python ~/Documents/GitHub/shrinko8/shrinko8.py build/v0.7.2_debug/quantattack_vs_human.p8 --count
-- tokens: 7287 89%
-- chars: 43084 66%
-- compressed: 11205 72%
