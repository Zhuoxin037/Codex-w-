# ============================================================
# sweetdream:equipment/armor/late_dusk/settle —— 结算「记录伤害」
# ------------------------------------------------------------
# 【执行者】@s = 记录窗口到点的生物（由 rec_tick 调用）
# 【★ 文案(逐字) ★】
#   "结束后对其造成记录伤害的 30% 的伤害，若其有「白昼梦」则消耗白昼梦并使其
#    时停 1 秒，之后使本次伤害提升为 50%。"
#   ⇒ **30% 是常态, 50% 是有白昼梦时**; 白昼梦是在"结算这一刻"判的, 不是消耗时判的。
# 【★ 先时停再消耗 ★】`tag/unmark` 一执行, 白昼梦标签就没了 —— 之后再写
#   `if entity @s[tag=zx.status.dream]` 恒假 ⇒ 时停永远不触发（静默）。
#   所以先用临时标签 zx.ld_hd 把"此刻有没有"记下来。
# 【★ 投递走标准链 ★】lib/num/plain → internal/damage/with_from（唯一出口在 deal）。
#   归属 u0..u3 从生物身上抄回来 ⇒ 这笔伤害算**当初动手那个人**的。
# 【R05 上界】rec 是 ×1000 定点, ×50 可能溢出 ⇒ 先夹到 INT32_MAX/50 再乘。
# ============================================================

# ① 判"结算这一刻有没有白昼梦"，并把结论钉成临时标签
scoreboard players set #ld_p zx.meta 30
execute if entity @s[tag=zx.status.dream] run scoreboard players set #ld_p zx.meta 50
execute if entity @s[tag=zx.status.dream] run tag @s add zx.ld_hd

# ② 有 ⇒ 时停 1 秒（20 刻）+ 消耗掉那个「白昼梦」
data modify storage zx:work fz set value {target:"@s", ticks:20}
execute if entity @s[tag=zx.ld_hd] run function sweetdream:lib/timestop with storage zx:work fz
execute store result storage zx:work ub.u0 int 1 run scoreboard players get @s zx.ld_u0
execute store result storage zx:work ub.u1 int 1 run scoreboard players get @s zx.ld_u1
execute store result storage zx:work ub.u2 int 1 run scoreboard players get @s zx.ld_u2
execute store result storage zx:work ub.u3 int 1 run scoreboard players get @s zx.ld_u3
function sweetdream:lib/u_by
# Shared consumption hooks, with the correct player as consumer.
data modify storage zx:work a set value {target:"@s",mark:"dream",by:"@a[tag=zx.ub,limit=1]",src:"equip"}
execute if entity @s[tag=zx.ld_hd] run function sweetdream:lib/mark_consume
tag @s remove zx.ld_hd

# ③ 算这一笔：rec(×1000) × p ÷ 100，仍是 ×1000 定点
scoreboard players set #ld_d zx.meta 0
execute store result score #ld_d zx.meta run scoreboard players get @s zx.ld_rec
scoreboard players set #ld_cap zx.meta 2147483647
scoreboard players operation #ld_cap zx.meta /= #50 zx.meta
execute if score #ld_d zx.meta > #ld_cap zx.meta run scoreboard players operation #ld_d zx.meta = #ld_cap zx.meta
scoreboard players operation #ld_d zx.meta *= #ld_p zx.meta
scoreboard players operation #ld_d zx.meta /= #100 zx.meta

# ④ 一点都没记到 ⇒ 不用打（也避免 0 伤害刷一次受击事件）
execute if score #ld_d zx.meta matches ..0 run return 0

# ⑤ 投递
execute store result storage zx:work ld.num double 0.001 run scoreboard players get #ld_d zx.meta
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"sweetdream:skill"}
data modify storage zx:work a.damage set from storage zx:work ld.num
data modify storage zx:work a.num set from storage zx:work ld.num
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s zx.ld_u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s zx.ld_u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s zx.ld_u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s zx.ld_u3
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑥ 表现
particle minecraft:dust{color:[0.4,0.3,0.55],scale:2.2} ~ ~1.0 ~ 0.6 0.8 0.6 0.04 30
playsound minecraft:entity.wither.hurt player @s ~ ~ ~ 0.5 1.8
