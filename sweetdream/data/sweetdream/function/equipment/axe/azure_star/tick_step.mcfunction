# ============================================================
# sweetdream:equipment/axe/azure_star/tick_step —— 「第 2 段 0.35 秒后落地」的每刻驱动
# ------------------------------------------------------------
# 【谁调用它】core/tick: as @a[scores={zx.as_d=1..}] at @s run function .../tick_step
# 【执行者】还有第 2 段没落的施法者   【位置】他所在处(at @s)
# 【计时口径】zx.as_d 起手 7, 每刻 -1; 从 1 减到 0 的那一次正好过了 7 刻 = 0.35 秒 -> 打。
#   ★ 筛选用 `zx.as_d=1..` 是天然停摆: 打完(或锚点没了)就停在 0, 不再被选中。
# 【★ 为什么打完无条件清 0 ★】dmg2 可能走"锚点没了"的提前分支, 那种情况也得停摆 ——
#   所以不依赖 dmg2 内部, 这里统一清(zx.as_d 是纯计数, 没别的用途)。
# 【谁还会改它】cast -> dmg(排第 2 段) / core/load(计分项注册)
# ============================================================

# ① 倒计时
scoreboard players remove @s zx.as_d 1
execute if score @s zx.as_d matches 1.. run return 0

# ② 到点: 打第 2 段(以其 2 格内全部生物 ×0.1)
function sweetdream:equipment/axe/azure_star/dmg2

# ③ 停摆
scoreboard players set @s zx.as_d 0
