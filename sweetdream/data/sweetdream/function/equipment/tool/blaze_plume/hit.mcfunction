# ============================================================
# sweetdream:equipment/tool/blaze_plume/hit —— 炽翎: 攻击时给目标续燃
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/tool/blaze_plume_hit
#   (player_hurt_entity + 伤害类型 is_player_attack)
# 【文案】"攻击燃烧中的目标 -> 燃烧时间 +1 秒; 攻击带「流火」的目标 -> 使其燃烧 1 秒。"
# 【为什么限定 is_player_attack】只认平A(规则 30): 技能 / 法球 / 荆棘反弹不该触发。
# 【★ 首行 revoke ★】一次性进度(规则 27); 已同步登记在 lib/rearm。
# 【★ 自己判副手 ★】"打中了"和"拿着炽翎"是两件事 —— 不判的话空手也生效(静默)。
# 【怎么定位"刚才打的那只"】同 styx_walk/hit: last_hurt_by_player + HurtTime 10/9,
#   再用 16 格兜底。产出标签 zx.bp_t(自己专用, 免和其它装备串)。
# 【★ 两条规则怎么并存 ★】
#   · 带「流火」 -> "使其燃烧 1 秒" = **不足 20 刻就提到 20 刻**(不是无脑再 +1 秒)
#   · 原本在燃烧 -> "+1 秒" = 在**原始值**上加 20 刻(所以要先留一份 #bp_raw)
#   两个都满足就叠加; 只有流火(原本没烧)也正好 1 秒, 不会被那条多算成 2 秒。
# 【Fire 是 short】store result entity ... Fire short 1(写 int/double 存不进去)。
# ============================================================

advancement revoke @s only sweetdream:equipment/tool/blaze_plume_hit

# ① 副手拿着炽翎吗
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["blaze_plume"]}] run return 0

# ② 钉死"刚才打的那只"(先精确反查, 再 16 格兜底)
tag @e[tag=zx.bp_t] remove zx.bp_t
execute store result storage zx:work bpv.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bpv.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bpv.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bpv.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/tool/blaze_plume/find_victim with storage zx:work bpv
execute unless entity @e[tag=zx.bp_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:10s},sort=nearest,limit=1] run tag @s add zx.bp_t
execute unless entity @e[tag=zx.bp_t,limit=1] as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:9s},sort=nearest,limit=1] run tag @s add zx.bp_t
execute unless entity @e[tag=zx.bp_t,limit=1] run return 0

# ③ 读目标当前燃烧剩余(#bp_raw = 原始值; 没在燃烧时 Fire 不存在 -> 保持 0)
scoreboard players set #bp_raw zx.meta 0
execute store result score #bp_raw zx.meta run data get entity @e[tag=zx.bp_t,limit=1] Fire
scoreboard players set #bp_f zx.meta 0
scoreboard players operation #bp_f zx.meta = #bp_raw zx.meta

# ④ 带「流火」-> 使其燃烧 1 秒(不足 20 刻提到 20)
execute if entity @e[tag=zx.bp_t,tag=zx.status.liuhuo,limit=1] if score #bp_f zx.meta matches ..19 run scoreboard players set #bp_f zx.meta 20

# ⑤ 原本在燃烧 -> +1 秒(在原始值上加 20)
execute if score #bp_raw zx.meta matches 1.. run scoreboard players add #bp_f zx.meta 20

# ⑥ 写回
execute if score #bp_f zx.meta matches 1.. run execute store result entity @e[tag=zx.bp_t,limit=1] Fire short 1 run scoreboard players get #bp_f zx.meta

# ⑦ 表现 + 收尾
execute at @e[tag=zx.bp_t,limit=1] run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.03 10 normal
execute at @e[tag=zx.bp_t,limit=1] run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.5 1.4
tag @e[tag=zx.bp_t] remove zx.bp_t
