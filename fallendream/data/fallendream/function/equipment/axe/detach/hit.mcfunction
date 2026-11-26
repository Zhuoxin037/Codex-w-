# ============================================================
# fallendream:equipment/axe/detach/hit —— 脱离：把蓄好的那一次兑现，然后切同生体
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/detach_hit（player_hurt_entity，全包共用）
# 【顺序】撤销进度 → 记蓄力 → 有 dt_arm 吗 → 手持判定 → 结算
# 【★ 结算必须在切换之前 ★】twin/enter 会移动玩家并重建状态，
#   先把伤害打完再切，归属(u0..u3)与位置都还是准的。
# 【★ 不判满蓄力（2026-11-01 修）★】
#   文案是"下一次攻击额外造成…"，没有"蓄满力"这个前提。早先照别的平A被动
#   抄了 `unless zx.atk_ok matches 1 run return 0`，于是右键后立刻挥刀（间隔不足
#   一个完整冷却）就什么都不发生 —— 用户实测报"额外伤害未生效"，根因就是那一行。
#   `zx.dt_arm` 本身就是一次性闸门（打中就清 0），不需要再加蓄力判定。
#   这里仍保留 atk_charge 调用，只为把本刻记进 zx.atk_lt，别让全局蓄力记录漏掉这一击。
# 【底材】罕见 = 铁（iron_axe）。give 换了底材必须同步改这里。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/detach_hit

function fallendream:lib/atk_charge

# 【超限 · 2026-11-20】切换后的 8 秒内，同生体第一次命中「该生物」→ 回 15% 最大生命。
#   ★ 必须先于下面那道 dt_arm 闸门：这一击的 dt_arm 早在脱离那一下就用掉了（清 0），
#     若排在 return 之后就永远走不到。
#   ★ 门控只看两条计分板（窗口未过期 + 已是同生体），平时一次空转；
#     真正贵的那一下（lib/victim 找受伤者）只在窗口里跑。
execute if score @s zx.dt_win > #now manacore.meta if score @s zx.j_form matches 1 run function fallendream:equipment/axe/detach/ess_heal

scoreboard players add @s zx.dt_arm 0
execute unless score @s zx.dt_arm matches 1 run return 0

execute if items entity @s weapon.mainhand iron_axe[custom_data~{zx:["detach"]}] run return run function fallendream:equipment/axe/detach/hit_go
execute if items entity @s weapon.offhand iron_axe[custom_data~{zx:["detach"]}] run function fallendream:equipment/axe/detach/hit_go
