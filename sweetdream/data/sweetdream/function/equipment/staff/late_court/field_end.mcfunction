# ============================================================
# sweetdream:equipment/staff/late_court/field_end —— 领域到点收摊(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】late_court/field_tick ⑧(计时归零)
# 【做什么】① 删掉框架里那个真术阵(键 = marker 上的 data.zx.uu) ② 表现 ③ kill 自己
# 【★ 这里不用撤任何状态 ★】本领域的"已触发过结束效果"记在生物自己的 zx.ltc_end 上,
#   而那是**按领域实例号**匹配的 —— 领域一消失, 那个值就再也匹配不上任何东西,
#   会自动变成陈旧值躺在那里(和"进入过哪些领域"同一套自清逻辑)。
#   zx.ltc_slow 标签同理: 下次比对实例号不等, 不产生任何行为。
# 【★ 本函数在"每维度各跑一次"的链上 ★】不出现裸 @e —— 删术阵用的是 marker 上的
#   UUID 文本, 与维度无关; @a 是玩家, 也无需锁维度。
# ============================================================

# ① 删掉框架里的真术阵(skill ⑦ 建的那个) —— 键就是 marker 上的 data.zx.uu
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:late_court"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
function manacore:api/formation/remove

# ② 表现: 庭光收束
particle minecraft:dust{color:[0.85,0.62,0.30],scale:1.2} ~ ~0.3 ~ 1.6 0.2 1.6 0.01 16 normal
particle minecraft:end_rod ~ ~0.4 ~ 1.2 0.3 1.2 0.02 10 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.6 0.9

# ③ 收掉自己
kill @s
