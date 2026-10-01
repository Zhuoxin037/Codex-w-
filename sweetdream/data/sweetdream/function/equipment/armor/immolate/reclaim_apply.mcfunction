# ============================================================
# sweetdream:equipment/armor/immolate/reclaim_apply —— 把烈空上限按差额减回去
# ------------------------------------------------------------
# 入参: @s = 玩家; zx.im_mk = 当前已经加进面板的烈空上限。
# 做法: #im_d = -zx.im_mk, 再复用 mana_apply 的“差额 + 记账 + 夹紧当前魔力”。
# ============================================================

scoreboard players set #im_d zx.meta 0
scoreboard players operation #im_d zx.meta -= @s zx.im_mk
function sweetdream:equipment/armor/immolate/mana_apply
