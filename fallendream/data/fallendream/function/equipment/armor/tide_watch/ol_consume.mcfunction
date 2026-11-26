# ============================================================
# fallendream:equipment/armor/tide_watch/ol_consume —— 超限·候潮：本件贴的「渊海」被自身消耗
# ------------------------------------------------------------
# 【执行者】消耗者(玩家)   【要求】调用方已取好 lib/uuid
# 【调用点】lib/on_consume ⑨ —— 门控已在那一层判过(穿超限候潮 + mark=yuanhai + 快照在)
# 【文案(逐字)】"由本件附加的「渊海」被自身消耗后，自身恢复 2% 最大魔力值并获得
#   4 秒抗性提升Ⅱ，之后使自身 3 格内的生物被击退一格。"
# 【★ "由本件附加"怎么认 ★】
#   on_skill_hit 附着时给那只打 zx.tw_mine 持久标记; lib/mark_take 在**摘标签之前**
#   把它快照成 zx.tw_src —— 原来那个选择器里带 tag=zx.status.yuanhai, 摘完就查不到了。
#   本文件只要看到 zx.tw_src 还在, 就说明这一只的渊海是候潮自己贴的。
# 【★ 顺序: 回蓝 -> 抗性 -> 击退 ★】文案写"…之后使…被击退"; 而且击退会把周围生物
#   推离圆心, 放到最后不影响前面两条。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["tide_watch"],ol:"tide_watch"}] run return 0
execute unless entity @e[tag=zx.tw_src,distance=0..] run return 0

# ---- ① 恢复 2% 最大魔力值 ----
#   ★ ×1000 定点: max_mana 走 api/stats/get 读出来, 再 ×2 ÷100。
#   ★ ×2 前夹 INT32 上界(R05): max_mana 的定点值本来就大, 极端加点下会回绕成负数。
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #tw_m zx.meta 0
execute store result score #tw_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #tw_m zx.meta matches 1.. run return 0

scoreboard players set #tw_2 zx.meta 2
scoreboard players set #tw_100 zx.meta 100
scoreboard players set #tw_cap zx.meta 2147483647
scoreboard players operation #tw_cap zx.meta /= #tw_2 zx.meta
scoreboard players operation #tw_add zx.meta = #tw_m zx.meta
execute if score #tw_add zx.meta > #tw_cap zx.meta run scoreboard players operation #tw_add zx.meta = #tw_cap zx.meta
scoreboard players operation #tw_add zx.meta *= #tw_2 zx.meta
scoreboard players operation #tw_add zx.meta /= #tw_100 zx.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #tw_add zx.meta
function manacore:api/mana/add

# ---- ② 抗性提升Ⅱ, 4 秒 ----
#   ★ amplifier 1 = Ⅱ; hideParticles=true 与原版药水区分(包内惯例)。
effect give @s minecraft:resistance 4 1 true

# ---- ③ 自身 3 格内的生物击退一格 ----
# 【位移手法】包内现役那套(复纱 ol_summon / 杂纹 b_yuanhai 同款): facing 到圆心(自己),
#   `^-1` 就是"从自己往外退 1 格"; `if block … replaceable` = 撞墙就不推。
#   ★ 圆心必须打临时标签: `as 生物` 之后 @s 已经不是玩家了。
#   ★ distance 从 0.01 起, 把站在圆心上的自己排除掉。
tag @a remove zx.tw_own
tag @s add zx.tw_own
execute as @e[type=!#fallendream:no_damage,distance=0.01..3] at @s facing entity @a[tag=zx.tw_own,limit=1] feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @a remove zx.tw_own
