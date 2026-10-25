# ============================================================
# sweetdream:equipment/armor/tide_fold/cross_player —— 一名**玩家**穿过了水墙
# ------------------------------------------------------------
# 【执行者】那名玩家(@s)  【位置】at @s  【宏参数】zx:work tf {u0..u3, id}
# 【★ 文案(逐字)】"自身穿过水墙时获得 3 秒迅捷Ⅱ，且每 2 秒穿过时可以恢复自身
#   相当于自身最大魔力值 1% 的魔力值。"
# 【两种身份】
#   · 是墙的主人  ⇒ 迅捷Ⅱ 3 秒 + 回蓝(1% 最大魔力, 2 秒闸门)
#   · 不是主人    ⇒ 那就只是"一只穿过的生物" ⇒ 走 cross_enemy 那条(渊海 + 缓慢Ⅱ)
#     ★ 但 tag/mark 只认非玩家活体(见 tag/mark 第一行), 所以别人的玩家只吃缓慢Ⅱ。
# ============================================================

# ① 同一面墙 5 秒内的重复 ⇒ 收工
$execute if score @s zx.tf_cw matches $(id) if score @s zx.tf_ct > #now manacore.meta run return 0

# ② 反查墙的主人(zx:work ub 必须由**本文件自己**灌: 中间任何嵌套都可能改写它)
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by

# ③ 不是主人 ⇒ 按"生物"处理(缓慢Ⅱ; 玩家的渊海由 tag/mark 自己跳过)
execute unless entity @s[tag=zx.ub] run effect give @s minecraft:slowness 3 1 true
$execute unless entity @s[tag=zx.ub] run scoreboard players set @s zx.tf_cw $(id)
execute unless entity @s[tag=zx.ub] run scoreboard players operation @s zx.tf_ct = #now manacore.meta
execute unless entity @s[tag=zx.ub] run scoreboard players operation @s zx.tf_ct += #100 zx.meta
execute unless entity @s[tag=zx.ub] run return 0

# ④ 是主人 —— 打节流戳
$scoreboard players set @s zx.tf_cw $(id)
scoreboard players operation @s zx.tf_ct = #now manacore.meta
scoreboard players operation @s zx.tf_ct += #100 zx.meta

# ⑤ 3 秒迅捷Ⅱ
effect give @s minecraft:speed 3 1 true

# ⑥ 回蓝: 最大魔力 ×1%（2 秒闸门）
#    ★ 文案写"每 2 秒穿过时可以恢复" ⇒ 闸门是**每次穿墙之间**隔 2 秒, 用绝对 tick。
execute if score @s zx.tf_mg > #now manacore.meta run return 0
scoreboard players operation @s zx.tf_mg = #now manacore.meta
scoreboard players operation @s zx.tf_mg += #40 zx.meta
function sweetdream:equipment/armor/tide_fold/regen
