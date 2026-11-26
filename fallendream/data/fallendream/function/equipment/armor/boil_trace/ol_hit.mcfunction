# ============================================================
# fallendream:equipment/armor/boil_trace/ol_hit —— 超限·沸痕：窗口内第一次技能伤害命中
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【调用点】internal/damage/one —— `type:"fallendream:skill"` 且非敌人自伤(排在 deal 之后)
# 【文案(逐字)】"…之后熄灭自身身上的火焰并获得 4 秒抗火，期间自身第一次以技能伤害
#   命中生物时，为其附加「流火」；若其原本已有「流火」而未附有「夜火」，则将「流火」
#   转化为「夜火」。"
# 【★ "第一次"靠关窗口保证 ★】on_hurt 开的 zx.bt_win_end（刻数）在这里**兑现后立刻清零**,
#   同一窗口里第二、第三个目标都不会再触发。
# 【★ 转化不是消耗 ★】摘「流火」走 tag/unmark（不触发余烬/回潮扣/烛跬那一串消费被动），
#   与焦衣 char_coat/on_skill_hit 同口径。
# 【★ 顺序: 先摘流火、再挂夜火 ★】反过来目标会短暂同时带两个, ttl 与图标多刷一次。
# ============================================================

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他穿着超限·沸痕 且 4 秒窗口还开着（@s 此刻是被打的那只, 窗口在玩家身上）
scoreboard players set #bt_live zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"],ol:"boil_trace"}] if score @s zx.bt_win_end > #now manacore.meta run scoreboard players set #bt_live zx.meta 1
execute unless score #bt_live zx.meta matches 1 run return 0

# ③ 关窗口（"第一次"只兑现一次）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.bt_win_end 0

# ④ 分两条路:
#   A. 目标原本带「流火」且没有「夜火」-> 转化（先摘后挂）
#   B. 目标没有「流火」            -> 附加「流火」
#   ★ 必须先用 #bt_conv 把分支定下来 ★ 摘掉流火之后 `unless entity @s[tag=…liuhuo]` 就成立了,
#     不锁分支的话 A 会在同一个函数里顺手再贴回一个「流火」（等于转化失败）。
scoreboard players set #bt_conv zx.meta 0
execute if entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run scoreboard players set #bt_conv zx.meta 1

# ---- A. 流火 -> 夜火 ----
execute if score #bt_conv zx.meta matches 1 run data modify storage zx:work bt set value {target:"@s",mark:"liuhuo"}
execute if score #bt_conv zx.meta matches 1 run function fallendream:tag/unmark with storage zx:work bt
execute if score #bt_conv zx.meta matches 1 run data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
execute if score #bt_conv zx.meta matches 1 run function fallendream:tag/mark with storage zx:work ic

# ---- B. 附加「流火」 ----
execute if score #bt_conv zx.meta matches 0 unless entity @s[tag=zx.status.liuhuo] run data modify storage zx:work ic set value {target:"@s",mark:"liuhuo"}
execute if score #bt_conv zx.meta matches 0 unless entity @s[tag=zx.status.liuhuo] run function fallendream:tag/mark with storage zx:work ic

# ⑤ 表现
execute at @s run particle minecraft:flame ~ ~0.8 ~ 0.3 0.4 0.3 0.02 10 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.5 1.3
