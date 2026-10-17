# ============================================================
# sweetdream:equipment/armor/gyre/path_hit —— 「移动过程中碰到的生物」30 点固定伤害
# ------------------------------------------------------------
# 【谁调用它】try_move ③（执行者 = 玩家，位置 = 刚落地的点）
# 【范围】1.5 格内、**排除本次命中的目标**（那只走 target_deal 的 24 点）
# 【★ 去重 ★】三段弧会扫过重叠区域，同一只不能被打三次 —— 打过的挂 zx.gyr_done，
#   整段结束（hit ⑦）才统一清。判定在"取人"那一步：只取 tag=!zx.gyr_done。
# 【★ 固定伤害 ★】文案「30 点固定伤害」= 不过任何乘区 ⇒ 直接用 num_str 投递，
#   不经过 manacore:api/damage/calc（同失血/断页的口径）。
# ============================================================

# ① 取"本段碰到、还没被打过"的生物
tag @e[tag=zx.gyr_now,distance=..32] remove zx.gyr_now
execute as @e[type=!#sweetdream:no_damage,distance=..1.5,tag=!zx.gyr_done,tag=!zx.gyr_t] run tag @s add zx.gyr_now
execute unless entity @e[tag=zx.gyr_now,distance=..32] run return 0

# ② 30 点固定伤害（归属 = 这个玩家）
data modify storage zx:work a set value {target:"@e[tag=zx.gyr_now,distance=..32]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 30.0
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 标记"这批已经打过了"（跨三段去重）
tag @e[tag=zx.gyr_now,distance=..32] add zx.gyr_done

# ④ 表现
execute at @e[tag=zx.gyr_now,limit=1,distance=..32] run particle minecraft:splash ~ ~0.6 ~ 0.4 0.4 0.4 0 8 normal
