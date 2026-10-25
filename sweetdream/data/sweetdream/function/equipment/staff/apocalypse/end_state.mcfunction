# ============================================================
# sweetdream:equipment/staff/apocalypse/end_state —— 灾示状态收尾
# ------------------------------------------------------------
# 【谁调用它】tick_go 第 ③ 步(ap_on 递减到 0; 执行者 = 玩家, at @s 已生效)
# 【清什么】两个计时器 + 当前页暂存(cur 只在状态内有效)。
# 【不清什么】ap_n / p1 / p2 / p3 —— 页是持久资产, 跨施法保留。
# ============================================================

function sweetdream:equipment/staff/apocalypse/visual/end

# ★ 超限（批 K8）：本次至少消耗了三页 ⇒ 技能释放完成后, 自身 6 格内的生物缓慢Ⅴ 4 秒
#   ★ 缓慢Ⅴ = amplifier 4（0-based）；带 no_damage 过滤，别把队友/玩家卷进来。
execute if score @s zx.ap_big matches 1 run effect give @e[type=!#sweetdream:no_damage,distance=..6] minecraft:slowness 4 4 true
execute if score @s zx.ap_big matches 1 run particle minecraft:dust{color:[0.85,0.7,0.3],scale:1.3} ~ ~1 ~ 2.5 0.5 2.5 0.02 24 normal

scoreboard players set @s zx.ap_t3 0
scoreboard players set @s zx.ap_t4 0
scoreboard players set @s zx.ap_cur 0
scoreboard players set @s zx.ap_big 0

# 表现收尾
particle minecraft:wax_off ~ ~1 ~ 1.0 0.8 1.0 0.02 25 normal
playsound minecraft:block.enchantment_table.use player @a ~ ~ ~ 0.7 0.8
