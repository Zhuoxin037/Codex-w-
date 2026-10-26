# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_step —— 「泵动」移动满一格的结算
# ------------------------------------------------------------
# 【执行者】带「泵动」的那只生物（由 pump_tick ⑥ 送进来）
# 【文案】"…使其受到一次相当于其最大生命值 ×0.05 的伤害，之后使其获得
#   1 秒缓慢Ⅳ效果。…自身会恢复上述相当于对其造成的伤害的生命值。"
# 【★ 吸血封顶 6 点（设计稿建议）★】原文"恢复相当于对其造成的伤害的生命值"
#   在高血量 Boss 身上会变成"一跳回满血"（1000 血 ×0.05 = 50 点/跳）。
#   ⇒ 每次结算最多回 6 点。
# 【★ 吸血要反查玩家 ★】lib/heal 只支持玩家, 用 lib/u_by 走计分项比较（零 NBT）。
# 【顺序】① 锚点归位 → ② 闸门复位 → ③ 伤害 → ④ 缓慢Ⅳ → ⑤ 吸血
#   ★ ① 必须在 ③ 之前: 锚点要停在**这次结算的位置**, 不能等伤害打完再挪
#     （击退会把它带偏, 于是下一格立刻又满一次）。
# ============================================================

# ① 锚点归位（这次结算的位置）

# ② 闸门 0.5 秒（10 刻）

# ③ ×0.05 的伤害（归属 = 挂泵动时抄下的那位玩家）
function sweetdream:equipment/armor/heart_vein/owner
data modify storage zx:work hv.mul set value 50
function sweetdream:equipment/armor/heart_vein/pump_dmg with storage zx:work hv

# ④ 1 秒缓慢Ⅳ（amplifier 3）
effect give @s minecraft:slowness 1 3 true

# ⑤ 吸血: 伤害整点值, 封顶 6
execute at @s run particle minecraft:dust{color:[0.80,0.20,0.30],scale:1.0} ~ ~0.6 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run particle minecraft:damage_indicator ~ ~1.2 ~ 0.25 0.4 0.25 0.01 4 normal
