# ============================================================
# sweetdream:equipment/axe/thunderclap/field_end —— 术阵到点收场(执行者 = 术阵 marker)
# ------------------------------------------------------------
# 【谁调用它】thunderclap/field_tick(计时归零)
# 【做什么】① 反查施法者, 清他的 zx.tc_on("术阵结束前不能再开" -> 结算后可再开)
#   ①' 把框架里那个真术阵一起删掉(用 marker 上存的施法者 uuid 文本当键)
#   ② 表现  ③ kill 自己
# 【★ 本函数在"每维度各跑一次"的链上 ★】不出现裸 @e; 只用 @a(玩家, 无需锁维度)。
# ============================================================

# ①' 删掉框架里的真术阵(open ⑤ 建的那个) —— 键就是 marker 上的 data.zx.uu
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:thunderclap"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb
scoreboard players set @a[tag=zx.mc_by] zx.tc_on 0
tag @a remove zx.mc_by

particle minecraft:electric_spark ~ ~1 ~ 2.5 1.0 2.5 0.12 40 normal
playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.8 1.0

kill @s
