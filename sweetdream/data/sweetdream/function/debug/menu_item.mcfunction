# ============================================================
# sweetdream:debug/menu_item —— 菜单里的一项(把 tg 表的信息并进来)
# ------------------------------------------------------------
# 【宏参数】注册表 menu 的一项 {k,n}   【执行者】玩家本人
#   k = 指向 tg 表里的键名(如 stats)   n = 悬停说明
# 【为什么要拆两层】menu 里只记了"键名", 而画按钮需要的是**计分项名字**
#   (zx.dbg_stats)和显示名。这两样在 tg 表里, 得先用 macro 把 k 拼进路径
#   取出来 —— 取出来之后就不能再 macro 了, 所以画的那一层单独放
#   debug/menu_draw(它拿的是已经取好的值, 可以直接当宏参数)。
# 【配错了会怎样】k 打错 -> tg 里没有这一项 -> 这一项静默不显示(不会报错)。
# ============================================================
$execute if data storage zx:reg tg.$(k) run data modify storage zx:work mi.name set from storage zx:reg tg.$(k).name
$execute if data storage zx:reg tg.$(k) run data modify storage zx:work mi.obj set from storage zx:reg tg.$(k).obj
$execute if data storage zx:reg tg.$(k) run data modify storage zx:work mi.hint set value "$(n)"
$execute if data storage zx:reg tg.$(k) run function sweetdream:debug/menu_draw with storage zx:work mi
