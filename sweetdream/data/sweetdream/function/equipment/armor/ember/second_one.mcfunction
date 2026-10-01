# ============================================================
# sweetdream:equipment/armor/ember/second_one —— 单个玩家的余烬结算
# ------------------------------------------------------------
# 【执行者】玩家   【执行位置】玩家脚下
# 【每秒做三件事】
#   ① 认装备: 穿余烬 -> zx.em_on
#   ② 魔力上限 +240: 和 zx.em_mana 账本求差, 穿上加 240, 脱下减 240
#      （这就是文案里的“自身魔力值上限+240”）
#   ③ 燃烧边沿检测: 只有穿着余烬才做, 没穿就到此为止
# 【★ 必须 lib/uuid ★】写面板用的是 zx:data self.uuid, 而 zx:data self 是
#   全局节点; 不重新取一次, 可能带着上一个人的 uuid 去写面板。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 认装备
scoreboard players add @s zx.em_mana 0
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run tag @s add zx.em_on
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run tag @s remove zx.em_on

# ② 魔力上限 +240 差值账本
scoreboard players set #em_want zx.meta 0
execute if entity @s[tag=zx.em_on] run scoreboard players set #em_want zx.meta 240
scoreboard players operation #em_diff zx.meta = #em_want zx.meta
scoreboard players operation #em_diff zx.meta -= @s zx.em_mana
execute unless score #em_diff zx.meta matches 0 run function sweetdream:equipment/armor/ember/apply_mana

# ③ 没穿余烬 -> 不做燃烧边沿检测
execute unless entity @s[tag=zx.em_on] run return 0

# ④ 旧标记里, 已经不再燃烧的 -> 流火/夜火
#    ⚠️ 检测扫描用 hit_scan_exclude, 不用 no_damage: no_damage 把盔甲架/
#    训练人偶也排掉了, 结果就是“人偶明明在烧, 余烬看不到”。
scoreboard players set #em_conv zx.meta 0
execute as @e[type=!#sweetdream:hit_scan_exclude,tag=zx.em_burn,distance=..9] at @s run function sweetdream:equipment/armor/ember/burned_out
scoreboard players operation @s zx.em_conv += #em_conv zx.meta

# ⑤ 清掉本秒范围内的旧标记(远处不清, 见 second 顶部注释)
tag @e[type=!#sweetdream:hit_scan_exclude,tag=zx.em_burn,distance=..9] remove zx.em_burn

# ⑥ 当前还在燃烧的, 打上标记, 给下一秒做边沿检测
scoreboard players set #em_seen zx.meta 0
execute as @e[type=!#sweetdream:hit_scan_exclude,distance=..9] at @s run function sweetdream:equipment/armor/ember/watch
scoreboard players operation @s zx.em_seen += #em_seen zx.meta
