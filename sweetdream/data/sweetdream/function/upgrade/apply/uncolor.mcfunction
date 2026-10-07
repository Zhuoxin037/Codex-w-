# ============================================================
# sweetdream:upgrade/apply/uncolor —— 右键用掉「无色石」, 消除副手装备的一个升级
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/uncolor(consume_item), 以玩家身份
# 【流程】①撤销进度(自撤销型, 不撤一辈子只触发一次; rearm 兜底)
#         ②kind="uncolor" 交给 station/api/apply 统一处理:
#           fit_uncolor 判"有无可消" + 抓要还的石头 -> uncolor_go 删最后一条
#           (最近敲入的) + 返还该等级升级石 -> lore_refresh 重建描述
#         ③成功 = 消耗成立 + 提示; 失败 = 无色石还回来 + 说明原因
# 【消除对象】up 列表**最后一条** = 最近敲入的(玩家 2026-10-07 口径)。
#   装了两个系列想消更早那个, 就再用一颗无色石。
# 【返还】★ 2026-10-07 二改: **整条链一起还**(消 Ω 还 α+β+Ω) —— 敲 β 的前提是
#   先敲过 α(替换制下 α 已被顶掉), 所以消掉 β 时玩家实际损失两颗。超限(ol)不受影响。
# ============================================================

advancement revoke @s only sweetdream:upgrade/uncolor

data modify storage zx:work st set value {kind:"uncolor",id:"uncolor",cat:"",cat2:"",cat3:"",cat4:"",of:""}
function sweetdream:station/api/apply

execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/uncolor_msg with storage zx:work uc
execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/uncolor
execute if data storage zx:out r{ok:0b} run tellraw @s {"text":"✘ 这件装备上还没有可以消除的升级","color":"red"}
execute if data storage zx:out r{ok:0b} run playsound minecraft:entity.villager.no player @s ~ ~ ~ 0.7 1.0
