# ============================================================
# sweetdream:equipment/bow/sculk_echo/fire —— 命中结算(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【两件事】
#   ① 对被射击生物 2 格内额外造成 基础攻击力 ×悲鸣 ×0.1 的伤害(= snap 里的 hit_dmg)
#   ② 概率三倍: 每 1 点悲鸣 1% 概率本次三倍; 触发则清除射手全部悲鸣
# 【范围怎么圈】以被打中的那只为中心, "判定箱相交"(边长 5 = 2×2+1)。
# 【三倍判定】#rnd %= 100 得 0..99, 若 < 悲鸣值则触发(悲鸣上限 50 -> 最高 50%)。
# 【清除悲鸣】悲鸣存在**射手**身上(zx.se_cry), 这里用 u0..u3 反查射手清掉。
# 【★ 结算完清中转标签 ★】zx.se_aoe / se_v / se_pl / se_arr。
# ============================================================

# ① 伤害值
scoreboard players set #se_dmg zx.meta 0
execute store result score #se_dmg zx.meta run data get storage zx:work se.snap.hit_dmg 100
execute if score #se_dmg zx.meta matches ..0 run return 0

# ①.5 概率三倍 + 触发后清除悲鸣
scoreboard players set #se_cry zx.meta 0
execute store result score #se_cry zx.meta run data get storage zx:work se.snap.cry
execute if score #se_cry zx.meta matches 1.. run function sweetdream:equipment/bow/sculk_echo/roll_triple

# ② 圈范围: 2 格内全部生物
tag @e[tag=zx.se_aoe] remove zx.se_aoe
$execute at $(target) positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.se_aoe

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
