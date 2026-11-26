# ============================================================
# fallendream:equipment/armor/condensed_shell/field_end —— 领域到点收摊(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】condensed_shell/field_tick ⑤(计时归零)
# 【做什么】① 删掉框架里那个真术阵(键 = marker 上的 data.zx.uu) ② 表现 ③ kill 自己
# 【★ 这里不碰 CD / 魔力】那些在 on_hurt 那一拍就已经结算完了; 本函数只收拾"领域"这一层。
#   (对照长夜 field_end: 那边要撤护甲/韧性的 modifier, 所以必须逐个摘标签; 凝壳的
#    冰冻是 lib/freeze 自己按 zx.fz_end 到点解的, 领域结束不需要额外撤销。)
# 【★ 本函数在"每维度各跑一次"的链上 ★】不出现裸 @e —— 删术阵用的是 marker 上的
#   UUID 文本, 与维度无关; @a 是玩家, 也无需锁维度。
# ============================================================

# ① 删掉框架里的真术阵(on_hurt ⑩ 建的那个) —— 键就是 marker 上的 data.zx.uu
data modify storage manacore:in arg set value {uuid:"",id:"fallendream:condensed_shell"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

# ①.5 超限收尾(必须在 kill @s 之前 —— 要从 marker 上读 UUID 和冰冻目标的位置)
#   ★ 先把宏参数从 marker 取到 zx:work csf ★ macro 在调用那一刻固化, 不能等进入
#     子函数再 from entity。ol 标记只决定"这一份要不要跑", 不进宏参数。
data modify storage zx:work csf.uu set from entity @s data.zx.uu
data modify storage zx:work csf.u0 set from entity @s data.zx.u[0]
data modify storage zx:work csf.u1 set from entity @s data.zx.u[1]
data modify storage zx:work csf.u2 set from entity @s data.zx.u[2]
data modify storage zx:work csf.u3 set from entity @s data.zx.u[3]
execute if data entity @s data.zx.ol run function fallendream:equipment/armor/condensed_shell/ol_end with storage zx:work csf

# ② 表现: 壳碎掉
particle minecraft:snowflake ~ ~0.2 ~ 1.6 0.1 1.6 0.01 20 normal
particle minecraft:poof ~ ~0.2 ~ 1.2 0.1 1.2 0.02 14 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.7 0.9

# ③ 收掉自己
kill @s
