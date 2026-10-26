# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_end —— 「泵动」到期收场
# ------------------------------------------------------------
# 【执行者】带「泵动」的那只生物（pump_tick ① / core/load 都会走到）
# 【★ 为什么 9 个计分项要一个一个 reset ★】这些分数全打在**生物**身上 ——
#   生物 NBT 会随 chunk 存盘, 残留 = 永久留在存档里（RULES「临时状态的铁律」）。
#   ⇒ 到期必须收尸, 且 core/load 另有三维度兜底清洗。
# 【为什么连 u0..u3 一起清】它们是"这一份泵动属于谁", 泵动没了就没有意义;
#   留着会让下一次别的装备误读出一个"归属"。
# ============================================================

tag @s remove zx.hv_pump
scoreboard players reset @s zx.hv_t
scoreboard players reset @s zx.hv_gate
scoreboard players reset @s zx.hv_px
scoreboard players reset @s zx.hv_py
scoreboard players reset @s zx.hv_pz
scoreboard players reset @s zx.hv_u0
scoreboard players reset @s zx.hv_u1
scoreboard players reset @s zx.hv_u2
scoreboard players reset @s zx.hv_u3

scoreboard players reset @s zx.hv_walk
scoreboard players reset @s zx.hv_path_v
