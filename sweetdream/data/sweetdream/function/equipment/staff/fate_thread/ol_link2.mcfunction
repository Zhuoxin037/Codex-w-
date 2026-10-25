# ============================================================
# sweetdream:equipment/staff/fate_thread/ol_link2 —— 命缕超限：第二段连接（12 格内最多 4 个噬心者）
# ------------------------------------------------------------
# 【谁调用】skill（超限分支，⑪ 之后、⑫ 之前）
# 【执行者】施法者   【位置】玩家所在
# 【文案】"之后再选取其 12 格内有「噬心」的最多 4 个生物并相连，本次连接可以连接上次
#   连接已经连接了的生物，持续 18 秒。"
#   "其" = 主目标 ⇒ 圆心是主目标，不是玩家。
# 【★ 允许和第一组重叠 ★】同一只同时被两条丝连着 ⇒ zx.ft_cn = 2 ⇒ 结算时按 ×0.8
#   （见 watch ⑧）。所以这里**故意不排除**已经在 zx.ft_lk 里的生物。
# ============================================================

tag @e[tag=zx.ft_lk2,distance=0..] remove zx.ft_lk2
execute at @e[tag=zx.ft_main,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..12,tag=zx.status.shixin,sort=nearest,limit=4] add zx.ft_lk2

# 第二组自己的实例号（和第一组同源 = 施法刻，方便一起收）
scoreboard players operation @e[tag=zx.ft_lk2,distance=0..] zx.ft2n = #ft_iid zx.meta

# ★ 连接条数（记在生物身上）：先全部归零，再每组各 +1 ★
#   ★ 必须先全清再累加：上一组残留的 2 会让这一组凭空变成 3。
scoreboard players set @e[tag=zx.ft_lk,distance=0..] zx.ft_cn 0
scoreboard players set @e[tag=zx.ft_lk2,distance=0..] zx.ft_cn 0
scoreboard players add @e[tag=zx.ft_lk,distance=0..] zx.ft_cn 1
scoreboard players add @e[tag=zx.ft_lk2,distance=0..] zx.ft_cn 1
