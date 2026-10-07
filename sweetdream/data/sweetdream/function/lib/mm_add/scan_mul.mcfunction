# ============================================================
# sweetdream:lib/mm_add/scan_mul —— 面板: 「最大魔力值技能倍率」通用加成现形
# ------------------------------------------------------------
# @panel: smul_mm
# 【执行者】玩家本人(@s)
# 【出参】仅当 zx.mm_add > 0 时, 往**加算池** zx:work add 的 mm 通道写它;
#   由 lib/skill_mul/padd_apply 统一折进 pl.smul_mm(面板上"最大魔力值技能倍率 ×"
#   那一行)。套路和共振 resonance/scan_mul、漫步 styx_walk/scan_mul 完全一样。
# 【★ 结算不在这里 ★】真正的结算是 lib/mm_add/hook_calc(挂在 damage_calc 事件)。
#   这里只负责让面板现形 —— 面板第一原则是"显示的必须是真实生效的"。
# 【★ 不再自己乘 smul_mm ★】"先合并再乘一次"才是加算(和共振/超限叠起来要先加)。
# 【为什么不再需要宏】加成存在玩家自己的计分项上(不是按 uuid 拼路径的 storage),
#   所以这个文件一条 `$` 都没有 —— 原来那份 lib/skill_mul/wind 就是为了拼
#   wg_bonus."<uuid>" 才不得不写成宏的, 现在整份删掉了。
# ============================================================

# ① 不是玩家 -> 不参与(scan 的调用方已经是玩家, 这里只是自保)
execute unless entity @s[type=minecraft:player] run return 0

# ② 没有加成(0 / 还没建过这个分数) -> 不参与
execute unless score @s zx.mm_add matches 1.. run return 0

# ③ 往加算池的 mm 通道贡献 +N%
execute store result storage zx:work put.pct int 1 run scoreboard players get @s zx.mm_add
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
