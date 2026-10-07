# ============================================================
# sweetdream:equipment/armor/dusk_dawn/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   #src = 哪个来源要的
#   1 = 靴子本身(+180)   2 = 套装(+200)   3 = 击杀后的临时上限
# 【为什么要分三个账本】每个来源自己记"已经加了多少", 换装/到点时才知道该减多少,
#   互相不冲掉。(静脉泵/体外那套也是这个思路)
# 【最后为什么读一次再 set 回去】上限变小时当前魔力可能超上限, 写回一次就等于夹紧。
#
# 【★★ 必须自己取一次 uuid ★★】本函数用 zx:data self.uuid 拼玩家路径, 而它
#   是**全局 storage** —— 值是"上一次谁调过 lib/uuid"的残留。调用方有 6 处:
#     passive(second ①, 自己取过) / temp_tick→temp_off(second ③) /
#     kill(进度奖励) / kill_mark_go(进度 + 伤害接口)
#   除了 passive, 其余都没取过 —— 于是加的/减的魔力上限会落到**别人**头上:
#   本人面板不生效、12 秒后的回收负值还去扣别人, 账本(zx.dd_app)永久对不上。
#   单人服碰巧正确(只剩一个人), 多人服必然错(2026-10-07 审查发现)。
#   所以在**本函数内部**取最稳 —— 六个调用方的 @s 都是玩家本人, 符合 lib/uuid
#   的前提("别人 @s 的函数禁用 lib/uuid"指的是 @s 不是本人那种, 这里不是)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

execute if score #src zx.meta matches 1 run scoreboard players operation @s zx.dd_mana += #diff zx.meta
execute if score #src zx.meta matches 2 run scoreboard players operation @s zx.dd_set += #diff zx.meta
execute if score #src zx.meta matches 3 run scoreboard players operation @s zx.dd_app += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
