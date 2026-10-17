# ============================================================
# sweetdream:equipment/armor/cross_dream/on_hurt —— 渡梦: 被"做梦的"近战打 -> 消耗 + 后撤
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/cross_dream_hurt（同轻枕: 近战 damage 标签）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +120。受到附有「白昼梦」的生物造成的近战伤害后，
#   若其仍存活且在自身 3 格内，则消耗其「白昼梦」，使自身沿视线反方向水平后撤最多
#   1.5 格，并获得 2 秒迅捷Ⅰ。遇到障碍即停，该效果 10 秒内不可再次触发。
# 【"打我的是谁"的近似】同 light_pillow 的头注 —— 只能按文案约束近似成
#   "3 格内最近的、带「白昼梦」的生物"（原文的"3 格内 + 仍存活 + 带白昼梦"正好就是它）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/cross_dream_hurt

# ① 没穿渡梦就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["cross_dream"]}] run return 0

# ② 10 秒节流
scoreboard players set #cd_due zx.meta 0
execute store result score #cd_due zx.meta run scoreboard players get @s zx.cdream_cd
execute if score #cd_due zx.meta > #now manacore.meta run return 0

# ③ 找那只"做梦的"（3 格内最近、带「白昼梦」；它仍存活才选得到）
tag @e[tag=zx.cd_s,distance=0..] remove zx.cd_s
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3,tag=zx.status.dream,sort=nearest,limit=1] add zx.cd_s
execute unless entity @e[tag=zx.cd_s,distance=0..,limit=1] run return 0

# ④ 消耗它的「白昼梦」（装备被动消耗 -> src:"equip"，别当成"技能消耗"）
data modify storage zx:work a set value {target:"@e[tag=zx.cd_s,limit=1]",mark:"dream",by:"@s",src:"equip"}
function sweetdream:lib/mark_consume

# ⑤ 沿视线反方向**水平**后撤最多 1.5 格（撞墙即停）
#   ★ `rotated ~ 0` 把俯仰角清零 = 文案里的"水平"（不然抬头/低头时会往天上退）；
#     `^ ^ ^-1.5` 沿朝向后退。两级高度都判可替换 —— 照退弦 backstring/fire 的写法。
execute at @s rotated ~ 0 positioned ^ ^ ^-1.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~

# ⑥ 获得 2 秒迅捷Ⅰ
effect give @s minecraft:speed 2 0 true

# ⑦ 表现 + 记账 + 收尾
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.phantom.flap player @a ~ ~ ~ 0.5 1.3
scoreboard players operation @s zx.cdream_cd = #now manacore.meta
scoreboard players operation @s zx.cdream_cd += #200 zx.meta
tag @e[tag=zx.cd_s,distance=0..] remove zx.cd_s
