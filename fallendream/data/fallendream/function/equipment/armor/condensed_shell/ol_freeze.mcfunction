# ============================================================
# fallendream:equipment/armor/condensed_shell/ol_freeze —— 超限·凝壳：每只生物整次领域最多 3 次冰冻
# ------------------------------------------------------------
# 【谁调它】field_tick ②（超限档，执行者 = 领域内每只生物，#cs_iid = 本领域实例号）
# 【文案(逐字)】"生物首次进入本次领域时冰冻 1 秒，之后每秒都会冰冻其 0.5 秒，
#   每名生物整次领域最多触发三次冰冻。"
# 【"每次领域"怎么数】zx.cs_fid = 上次冻它的领域实例号（基础版已有），
#   zx.cs_cn = 这只在本领域已经冻了几次。实例号一变（新领域）就把次数清零。
#   ★ 不能用 `if score cs_fid != #cs_iid`：分数不存在时比较不成立，首次永远进不来。
#     沿用基础版那条 `unless score … = #cs_iid`（"自己不等于自己"也放行）。
# 【★ 取较长语义 ★】lib/freeze 重入只会把结束时刻往后推，不会缩短 —— 所以第 2、3 次
#   的 0.5 秒能在第 1 次的 1 秒之上顺延，而不是把 1 秒截成 0.5 秒。
# ============================================================

# ① 换领域了 -> 次数清零 + 记新实例号
execute unless score @s zx.cs_fid = #cs_iid zx.meta run scoreboard players set @s zx.cs_cn 0
execute unless score @s zx.cs_fid = #cs_iid zx.meta run scoreboard players operation @s zx.cs_fid = #cs_iid zx.meta

# ② 满 3 次就不再冻；否则次数 +1
execute if score @s zx.cs_cn matches 3.. run return 0
scoreboard players add @s zx.cs_cn 1

# ③ 第 1 次 1 秒（20 刻），第 2、3 次 0.5 秒（10 刻）
data modify storage zx:work fz set value {target:"@s",ticks:10}
execute if score @s zx.cs_cn matches 1 run data modify storage zx:work fz.ticks set value 20
function fallendream:lib/freeze with storage zx:work fz
