# ============================================================
# sweetdream:equipment/bow/sculk_echo/fire —— 命中结算(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【文案(基础版)】对被射击生物 **2 格**内的全部生物造成 基础攻击力 ×悲鸣 ×0.1 的伤害;
#   概率三倍 = 每 1 点悲鸣 **1%**。
# 【文案(超限·幽匿残响, 2026-10-10 实装)】范围 **2 格 -> 3 格**; 三倍概率
#   **1%/点 -> 0.5%/点**(满 100 点 = 50%, 与基础版满层 50% 持平)。
#   判据 = 这一发的快照 `se.snap.ol`(离弦时拍下的"手里是不是超限版"), 与「蚀骨」同款。
# 【范围怎么圈】以被打中的那只为中心, "判定箱相交"(边长 = 2×半径+1 = 5 / 7)。
#   ★ 半径是**写死在选择器里的数字**, 变量替代不了 ⇒ 只能按 ol 分两条写(别合并)。
# 【清除悲鸣】悲鸣存在**射手**身上(zx.se_cry), 这里用 u0..u3 反查射手清掉。
# 【★ 结算完清中转标签 ★】zx.se_aoe / se_v / se_pl / se_arr。
# ============================================================

# ① 伤害值
scoreboard players set #se_dmg zx.meta 0
execute store result score #se_dmg zx.meta run data get storage zx:work se.snap.hit_dmg 100
execute if score #se_dmg zx.meta matches ..0 run return 0

# ①.5 概率三倍 + 触发后清除悲鸣
#   ★ 超限版把"每点 1%"改成"每点 0.5%"(除数 100 -> 200, 见 roll_triple)。
scoreboard players set #se_cry zx.meta 0
execute store result score #se_cry zx.meta run data get storage zx:work se.snap.cry
#   这一发是不是超限版(读不到时保持 0 -> 走基础版, 安全)
scoreboard players set #se_ol zx.meta 0
execute store result score #se_ol zx.meta run data get storage zx:work se.snap.ol 1
execute if score #se_cry zx.meta matches 1.. run function sweetdream:equipment/bow/sculk_echo/roll_triple

# ② 圈范围: 2 格内全部生物(超限版 3 格 —— 半径写死在选择器里, 只能分两条)
tag @e[tag=zx.se_aoe] remove zx.se_aoe
$execute at $(target) if score #se_ol zx.meta matches 0 positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.se_aoe
$execute at $(target) if score #se_ol zx.meta matches 1 positioned ~-3.5 ~-3.5 ~-3.5 run tag @e[type=!#sweetdream:no_damage,dx=7.0,dy=7.0,dz=7.0] add zx.se_aoe

# ③ 打伤害(带射手归属)
data modify storage zx:work a set value {target:"@e[tag=zx.se_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #se_dmg zx.meta
data modify storage zx:work a.u0 set from storage zx:work se.snap.u0
data modify storage zx:work a.u1 set from storage zx:work se.snap.u1
data modify storage zx:work a.u2 set from storage zx:work se.snap.u2
data modify storage zx:work a.u3 set from storage zx:work se.snap.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现
$execute at $(target) run particle minecraft:sculk_soul ~ ~1 ~ 1.2 0.6 1.2 0.05 25 normal
$execute at $(target) run playsound minecraft:entity.warden.hurt player @a ~ ~ ~ 0.8 1.2

# ⑤ 收尾
tag @e[tag=zx.se_aoe] remove zx.se_aoe
tag @e[tag=zx.se_v] remove zx.se_v
tag @e[tag=zx.se_pl] remove zx.se_pl
tag @e[tag=zx.se_arr] remove zx.se_arr
