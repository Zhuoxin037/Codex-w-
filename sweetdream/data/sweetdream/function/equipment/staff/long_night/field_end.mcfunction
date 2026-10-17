# ============================================================
# sweetdream:equipment/staff/long_night/field_end —— 夜原到点收场(执行者 = 夜原 marker)
# ------------------------------------------------------------
# 【谁调用它】field_tick ⑤(计时 zx.ln_ft 归零)
# 【做什么】
#   ① 撤掉本次夜原给过的"护甲值/韧性 -60%" —— 只撤 zx.ln_debuff 认领过的
#      ★ 用户 2026-10-16 拍板: 减甲持续 = **整个夜原期间**, 领域一消失就撤。
#      ★ 顺序不能反: 必须先撤修饰符再摘标签(摘了标签就再也认不出是谁)。
#      ★ 生物中途离开半径 6 也一样照撤 —— 文案的时长是整个夜原, 与它在不在圈内无关。
#   ② 把框架里那个真术阵一起删掉(键 = marker 上存的施法者 uuid 文本, 同威霆)
#   ③ 表现 + 收掉自己
# 【★ 本函数在"每维度各跑一次"的链上 ★】不出现裸 @e 之外的跨维度选择器;
#   zx.ln_debuff 用 distance=0.. 锁在当前维度(生物只可能在夜原这一维度里被减甲)。
# ============================================================

# ① 撤减甲(先修饰符, 后标签)
execute as @e[tag=zx.ln_debuff,distance=0..] run attribute @s minecraft:armor modifier remove sweetdream:nightyard_armor
execute as @e[tag=zx.ln_debuff,distance=0..] run attribute @s minecraft:armor_toughness modifier remove sweetdream:nightyard_tough
tag @e[tag=zx.ln_debuff,distance=0..] remove zx.ln_debuff

# ② 删掉框架里的真术阵
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:long_night"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

# ③ 表现 + 收掉自己
particle minecraft:reverse_portal ~ ~0.6 ~ 4.0 0.6 4.0 0.05 60 normal
particle minecraft:smoke ~ ~0.4 ~ 3.0 0.3 3.0 0.02 30 normal
playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.7 0.7
kill @s
