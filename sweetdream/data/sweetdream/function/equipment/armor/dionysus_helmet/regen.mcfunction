# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/regen —— 桂冠触发后每次回 80 魔力
# ------------------------------------------------------------
# 【谁调用它】second 里用 @a[scores={zx.dio_regen=1..}] 筛出来的人, 每秒一次
# 【执行者】玩家
# 【为什么用计分项倒计时, 而不是 schedule 三次】
#   schedule 出来的函数没有 @s, 得再找个标签把玩家找回来;
#   而"剩余几秒"本来就该记在玩家身上, 每秒的入口顺手扣一下最省事。
# 【api/mana/add 会夹到上限】不会回超; 而且它属于主动回复,
#   不受"禁止魔力恢复"影响 —— 桂冠给的回魔照样生效, 这正是想要的。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

scoreboard players remove @s zx.dio_regen 1
