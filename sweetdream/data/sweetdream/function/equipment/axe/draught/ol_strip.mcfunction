# ============================================================
# sweetdream:equipment/axe/draught/ol_strip —— 立刻撤掉第二形态叠上去的基础攻击力
# ------------------------------------------------------------
# 【谁调用它】draught/cast ⑤(重入时先撤旧的) / draught/ol_expire(10 秒到点)
# 【执行者】玩家
# 【做什么】按账本 zx.dg_buf2 的数从面板 base_attack 里减回去(scale 用 -1 取负值),
#   然后把第二形态的四个账全部归零(模式 / 次数 / 计时 / 账本)。
#   ★ 与第一形态的 strip 分开两份: 两套账各记各的, 混用会在"第一形态还没到期时
#     又开了第二形态"这种情况下把数减错(一份账本被减两次)。
# ============================================================

execute if score @s zx.dg_buf2 matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -1 run scoreboard players get @s zx.dg_buf2
function manacore:api/stats/add

scoreboard players set @s zx.dg_buf2 0
scoreboard players set @s zx.dg_on2 0
scoreboard players set @s zx.dg_mode 0
scoreboard players set @s zx.dg_n 0
