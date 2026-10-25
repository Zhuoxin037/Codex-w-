# ============================================================
# sweetdream:equipment/axe/red_lotus/tick_step —— 「每 0.5 秒推一段」的每刻驱动
# ------------------------------------------------------------
# 【谁调用它】core/tick: as @a[scores={zx.rl_t=1..}] at @s run function .../tick_step
# 【执行者】还有段没打完的施法者   【位置】他所在处(at @s)
# 【计时口径】zx.rl_t 起手 7, 每刻 -1; 从 1 减到 0 的那一次正好过了 10 刻 = 0.5 秒 -> 打。
#   ★ 筛选用 `zx.rl_t=1..` 是天然停摆: 打完若还有剩(rep>=1)就把 rl_t 重置回 7,
#     继续被选中; 打完了(rep<=0)就让它停在 0 -> 再也不被选中, 不用额外清理。
# 【★ 必须排在 lib/in_restore 之前 ★】本函数会调 recalc -> manacore:api/damage/calc,
#   它要用公共输入口 manacore:in arg(和回锋的 tick_step 同一个理由)。
# 【谁还会改它】cast(起手排段数) / core/load(计分项注册)
# ============================================================

# ① 倒计时
scoreboard players remove @s zx.rl_t 1
execute if score @s zx.rl_t matches 1.. run return 0

# ② 到点: 推一段(流火优先, 摘完才轮到夜火)
function sweetdream:equipment/axe/red_lotus/step

# ③ 还剩几段? 有 -> 重新上弦 10 刻; 没有 -> 停在 0(core/tick 不再选中)
scoreboard players remove @s zx.rl_rep 1
execute if score @s zx.rl_rep matches 1.. run scoreboard players set @s zx.rl_t 10

# ③' 连击打完 -> 清掉这次施法的"超限快照"(cast ①' 拍的那个)
#    ★ 不能在 cast 里清: 后面每一段的 recalc / hit_* 都还要读它。
execute if score @s zx.rl_rep matches ..0 run scoreboard players set @s zx.rl_ol 0

# 表现: 每段之间一声轻响, 让"还在连击"听得出来
execute at @s run playsound minecraft:block.fire.ambient player @a ~ ~ ~ 0.5 1.3
