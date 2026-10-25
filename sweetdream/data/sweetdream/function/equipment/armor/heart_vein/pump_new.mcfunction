# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_new —— 新附一份 5 秒「泵动」
# ------------------------------------------------------------
# 【执行者】刚被消耗掉「噬心」的那只生物   【宏参数】zx:work hv {by}
# 【文案】"…则使其附加持续 5 秒的「泵动」（最多 12 秒）。"
# 【★ 为什么"锚点"要在这里就记 ★】泵动的判据是"每移动一格": 逐刻拿当前坐标
#   与**上一次结算时的位置**比（不是与上一刻比）—— 与 lib/step 同一套口径,
#   不然"慢慢挪"永远凑不满一格、"被击退"却会连着跳好几格。
# 【★ 归属为什么记在生物身上 ★】泵动伤害可能发生在很多刻之后, 那时早已没有
#   "施法者"上下文了 ⇒ 必须在这一刻把玩家的 4 个 UUID int 抄到生物分数上。
#   ★ 抄的是 manacore.u0..u3 的整数, 不读任何 NBT（卡顿坑 1）。
# ============================================================

# ① 打标记 + 5 秒（100 刻）
tag @s add zx.hv_pump
scoreboard players set @s zx.hv_t 100

# ② 闸门归零（第一刻就能结算, 不用等 0.5 秒）
scoreboard players set @s zx.hv_gate 0

# ③ 锚点 = 当前坐标（×100, 1 格 = 100）
execute store result score @s zx.hv_px run data get entity @s Pos[0] 100
execute store result score @s zx.hv_py run data get entity @s Pos[1] 100
execute store result score @s zx.hv_pz run data get entity @s Pos[2] 100

# ④ 归属: 从 $(by) 身上搬 4 个整数到本只身上
$execute as $(by) store result score #hv_u0 zx.meta run scoreboard players get @s manacore.u0
$execute as $(by) store result score #hv_u1 zx.meta run scoreboard players get @s manacore.u1
$execute as $(by) store result score #hv_u2 zx.meta run scoreboard players get @s manacore.u2
$execute as $(by) store result score #hv_u3 zx.meta run scoreboard players get @s manacore.u3
scoreboard players operation @s zx.hv_u0 = #hv_u0 zx.meta
scoreboard players operation @s zx.hv_u1 = #hv_u1 zx.meta
scoreboard players operation @s zx.hv_u2 = #hv_u2 zx.meta
scoreboard players operation @s zx.hv_u3 = #hv_u3 zx.meta

# ⑤ 表现
execute at @s run particle minecraft:dust{color:[0.85,0.35,0.20],scale:1.3} ~ ~1 ~ 0.35 0.5 0.35 0.02 16 normal
execute at @s run playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.4 1.6
