# ============================================================
# sweetdream:equipment/armor/ember/second_one —— 单个玩家的余烬结算
# ------------------------------------------------------------
# 【执行者】玩家   【执行位置】玩家脚下
# 【每秒做两件事】(2026-10-12 起)
#   ① 认装备: 穿余烬 -> zx.em_on
#   ② 魔力上限 +240: 和 zx.em_mana 账本求差, 穿上加 240, 脱下减 240
#      （这就是文案里的“自身魔力值上限+240”）
# 【★ 燃烧边沿检测已挪走 ★】它原来挂在每秒, 2026-10-12 用户反馈
#   "每次燃烧结束都不能及时上流火/夜火" 并拍板"更密集的周期" ⇒ 现在由
#   core/tick **每 5 刻**跑一次 scan_one(延迟 0~1 秒降到 0~0.25 秒)。
#   ①② 是账本不是手感, 留在每秒(高频跑纯属浪费)。
#   ⚠️ zx.em_on 现在是 scan_one 的门控, **不能删** —— 删了高频扫描对谁都不跑。
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

# ③ 到这儿就结束了 —— 燃烧边沿检测不在本函数里, 由 core/tick 每 5 刻
#    单独调 scan_one(见本文件顶部"燃烧边沿检测已挪走")。
#    （zx.em_on 标签由上面的 ① 维护, 就是那条高频扫描的门控。）
