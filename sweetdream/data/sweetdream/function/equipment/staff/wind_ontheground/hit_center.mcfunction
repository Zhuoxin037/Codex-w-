# ============================================================
# sweetdream:equipment/staff/wind_ontheground/hit_center —— 打某一个中心周围 5 格
# ------------------------------------------------------------
# 【执行者】施法者(位置已经被挪到"中心"身上, 所以距离是相对中心算的)
# 【怎么数命中数】execute if entity 的"返回值"就是匹配到的实体个数,
#   所以 `execute store result score ... run execute if entity @e[...]` 直接拿到数量。
# 【伤害数值】由 hit_pass 算好放在 manacore:out r.damage, 这里直接 read。
# ============================================================

# ① 这一圈有几个生物
execute store result score #hits zx.meta run execute if entity @e[type=!#sweetdream:no_damage,distance=..5]

# ② 打出去(api/damage 会把范围选择器逐个展开成单个实体)
# 不写 type: 交给 api/damage 的默认值(见 core/load 里的 zx:config damage_type)
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",read:"manacore"}
function sweetdream:api/damage

# ③ 每命中一个生物积攒 1 点「风声」
scoreboard players operation @s zx.wg_sound += #hits zx.meta

# ④ 表现: 以中心为圆心炸开一圈风
particle minecraft:gust ~ ~1 ~ 5.0 0.6 5.0 0.05 30 normal
particle minecraft:small_gust ~ ~1 ~ 4.0 1.5 4.0 0.05 20 normal
playsound minecraft:entity.breeze.wind_burst player @a ~ ~ ~ 0.7 1.2
