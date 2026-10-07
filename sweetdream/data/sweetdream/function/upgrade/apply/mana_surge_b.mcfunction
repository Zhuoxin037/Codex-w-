# ============================================================
# sweetdream:upgrade/apply/mana_surge_b —— 右键用掉这块「魔力沸涌·β」去敲副手的装备
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/mana_surge_b(consume_item), 以玩家身份
# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)
#         ②把 kind/id/cat~cat4 交给 station/api/apply 统一处理
#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因
# 【为什么 cat~cat4 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,
#   所以在这里从定义表读出来一起传进去(cat3/cat4 缺失时由 apply 补空串)。
# ============================================================

advancement revoke @s only sweetdream:upgrade/mana_surge_b

data modify storage zx:work st set value {kind:"upgrade",id:"mana_surge_b",cat:"",cat2:"",of:""}
data modify storage zx:work st.cat set from storage zx:config updef."mana_surge_b".cat
data modify storage zx:work st.cat2 set from storage zx:config updef."mana_surge_b".cat2
data modify storage zx:work st.cat3 set from storage zx:config updef."mana_surge_b".cat3
data modify storage zx:work st.cat4 set from storage zx:config updef."mana_surge_b".cat4
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/done with storage zx:work st
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/mana_surge_b
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/api/refuse with storage zx:work st
