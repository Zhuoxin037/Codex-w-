# ============================================================
# sweetdream:upgrade/apply/mana_gain_a —— 右键用掉这块「魔力增殖·α」去敲副手的装备
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/mana_gain_a(consume_item), 以玩家身份
# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)
#         ②把 kind/id/cat/cat2 交给 station/api/apply 统一处理
#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因
# 【为什么 cat/cat2 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,
#   所以在这里从定义表读出来一起传进去。
# ============================================================

advancement revoke @s only sweetdream:upgrade/mana_gain_a

data modify storage zx:work st set value {kind:"upgrade",id:"mana_gain_a",cat:"",cat2:"",of:""}
data modify storage zx:work st.cat set from storage zx:config updef."mana_gain_a".cat
data modify storage zx:work st.cat2 set from storage zx:config updef."mana_gain_a".cat2
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/done with storage zx:work st
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/mana_gain_a
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/api/refuse with storage zx:work st
