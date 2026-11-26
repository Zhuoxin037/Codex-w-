# ============================================================
# fallendream:equipment/armor/cross_dream/on_hurt —— 渡梦: 被"做梦的"近战打 -> 消耗 + 后撤
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/cross_dream_hurt（同轻枕: 近战 damage 标签）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字 · 基础)】自身魔力值上限 +120。受到附有「白昼梦」的生物造成的近战
#   伤害后，若其仍存活且在自身 3 格内，则消耗其「白昼梦」，使自身沿视线反方向水平后撤
#   最多 1.5 格，并获得 2 秒迅捷Ⅰ。遇到障碍即停，该效果 10 秒内不可再次触发。
# 【文案(lore 逐字 · 超限)】自身魔力值上限 +160。受到附有「白昼梦」的生物造成的近战
#   伤害后，若其仍存活且在自身 3 格内，则消耗其「白昼梦」，使自身沿视线反方向水平后撤
#   最多 1.5 格，并获得 5秒迅捷Ⅲ，遇到障碍即停。之后自身获得相当于最大生命值20%的
#   临时生命值，持续15秒。后撤终点3格内若附有「白昼梦」的生物则使其时停1秒，每影响
#   一个生物，则自身恢复12魔力。该效果 6秒内不可再次触发。
# 【"打我的是谁"的近似】同 light_pillow 的头注 —— 只能按文案约束近似成
#   "3 格内最近的、带「白昼梦」的生物"（原文的"3 格内 + 仍存活 + 带白昼梦"正好就是它）。
# 【★ 超限多出来的三段, 全部排在"后撤之后" ★】临时生命/时停/回魔都写的是"之后",
#   而且时停的判定用的是"**后撤终点** 3 格内" —— 必须在 tp 之后再取位置。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/cross_dream_hurt

# ① 没穿渡梦就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["cross_dream"]}] run return 0

# ①.5 档位快照
scoreboard players set #cd_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["cross_dream"],ol:"cross_dream"}] run scoreboard players set #cd_ol zx.meta 1

# ② 节流: 基础 10 秒(200) / 超限 6 秒(120)
scoreboard players set #cd_gap zx.meta 200
execute if score #cd_ol zx.meta matches 1 run scoreboard players set #cd_gap zx.meta 120
scoreboard players set #cd_due zx.meta 0
execute store result score #cd_due zx.meta run scoreboard players get @s zx.cdream_cd
execute if score #cd_due zx.meta > #now manacore.meta run return 0

# ③ 找那只"做梦的"（3 格内最近、带「白昼梦」；它仍存活才选得到）
tag @e[tag=zx.cd_s,distance=0..] remove zx.cd_s
execute at @s run tag @e[type=!#fallendream:no_damage,distance=..3,tag=zx.status.dream,sort=nearest,limit=1] add zx.cd_s
execute unless entity @e[tag=zx.cd_s,distance=0..,limit=1] run return 0

# ④ 消耗它的「白昼梦」（装备被动消耗 -> src:"equip"，别当成"技能消耗"）
data modify storage zx:work a set value {target:"@e[tag=zx.cd_s,limit=1]",mark:"dream",by:"@s",src:"equip"}
function fallendream:lib/mark_consume

# ⑤ 沿视线反方向**水平**后撤最多 1.5 格（撞墙即停）
#   ★ `rotated ~ 0` 把俯仰角清零 = 文案里的"水平"（不然抬头/低头时会往天上退）；
#     `^ ^ ^-1.5` 沿朝向后退。两级高度都判可替换 —— 照退弦 backstring/fire 的写法。
execute at @s rotated ~ 0 positioned ^ ^ ^-1.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~

# ⑥ 迅捷: 基础 2 秒Ⅰ / 超限 5 秒Ⅲ（amplifier 2 = Ⅲ）
execute if score #cd_ol zx.meta matches 0 run effect give @s minecraft:speed 2 0 true
execute if score #cd_ol zx.meta matches 1 run effect give @s minecraft:speed 5 2 true

# ⑦ ★ 超限: 临时生命 = 最大生命 20%，持续 15 秒 ★
#   走 lib/thp/add（它会自己夹到"最大生命 ×2"的硬上限）；
#   到期刻用 zx.thp_end —— 只在"比现有更晚"时才推，免得把别人给的长时临时生命截短。
execute if score #cd_ol zx.meta matches 1 run function fallendream:equipment/armor/cross_dream/ol_thp
execute if score #cd_ol zx.meta matches 1 run scoreboard players operation #cd_te zx.meta = #now manacore.meta
execute if score #cd_ol zx.meta matches 1 run scoreboard players add #cd_te zx.meta 300
execute if score #cd_ol zx.meta matches 1 if score @s zx.thp_end < #cd_te zx.meta run scoreboard players operation @s zx.thp_end = #cd_te zx.meta

# ⑧ ★ 超限: 后撤终点 3 格内带「白昼梦」的生物 -> 时停 1 秒; 每只回 12 魔力 ★
execute if score #cd_ol zx.meta matches 1 run function fallendream:equipment/armor/cross_dream/ol_stop

# ⑨ 表现 + 记账 + 收尾
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.phantom.flap player @a ~ ~ ~ 0.5 1.3
scoreboard players operation @s zx.cdream_cd = #now manacore.meta
scoreboard players operation @s zx.cdream_cd += #cd_gap zx.meta
tag @e[tag=zx.cd_s,distance=0..] remove zx.cd_s
