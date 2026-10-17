# ============================================================
# sweetdream:equipment/armor/condensed_shell/field_end —— 领域到点收摊(执行者 = 领域 marker)
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
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:condensed_shell"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

# ② 表现: 壳碎掉
particle minecraft:snowflake ~ ~0.2 ~ 1.6 0.1 1.6 0.01 20 normal
particle minecraft:poof ~ ~0.2 ~ 1.2 0.1 1.2 0.02 14 normal
playsound minecraft:block.glass.break player @a ~ ~ ~ 0.7 0.9

# ③ 收掉自己
kill @s
