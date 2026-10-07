# ============================================================
# sweetdream:equipment/sword/hush/back_finish —— 归位收尾
# ------------------------------------------------------------
# 【宏参数】zx:work hs {uuid:"<施法者 uuid 文本>"}
# 【谁调用它】back_move ①(到点) 或 back_step ③(倒计时耗尽强制收尾)
# 【做什么】吸附回原点 + 杀 marker + 清状态 + 回程表现 + 回程伤害(×0.2)
# 【顺序】①吸附收尾 -> ②清状态(先清, 免得重入) -> ③表现 -> ④伤害 -> ⑤清路径标签
# ============================================================

# ① 吸附 + 杀 marker(复用 back: `at <marker> run tp @s ~ ~ ~`, 朝向不变)
#   二次调用(倒计时兜底时 marker 已没了)选 0 个实体 -> 整条不执行, 不报错。
function sweetdream:equipment/sword/hush/back with storage zx:work hs

# ② 清状态(先清, 后面再跑别的也不怕重入)
scoreboard players reset @s zx.hush_bk
tag @s remove zx.hs_back

# ③ 回程表现: 落地的"啪"
execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.0 0.4 1.0 0.05 24 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.7 1.2

# ④ 回程伤害: 路径上的全部生物, ×0.2
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,tag=zx.hs_path,distance=..12]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute store result score #dbg_sel zx.meta run execute if entity @e[type=!#sweetdream:no_damage,tag=zx.hs_path,distance=..12]
execute at @s run function sweetdream:api/damage

# ⑤ 清路径标签(不留残余); 顺手把"本局已碰到"标记也清掉, 下一局才能再打
#   两者都沿突击走廊(离原点最多 ~9 格) -> distance=..12 一定覆盖得到。
execute as @e[type=!#sweetdream:no_damage,tag=zx.hs_path,distance=..12] run tag @s remove zx.hs_path
execute as @e[type=!#sweetdream:no_damage,tag=zx.hs_hit,distance=..12] run tag @s remove zx.hs_hit
