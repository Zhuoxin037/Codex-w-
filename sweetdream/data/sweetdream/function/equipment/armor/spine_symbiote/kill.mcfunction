# ============================================================
# sweetdream:equipment/armor/spine_symbiote/kill —— 击杀生物后回 60 点魔力
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/spine_symbiote_kill
#   trigger: player_killed_entity -> 玩家杀死实体时执行, @s = 玩家
# 【文案】每次击杀生物都会恢复自身 60 点魔力值。
# 【为什么不自己算上限】api/mana/add 内部会自动夹到 max_mana, 不会溢出;
#   而且它走的是"主动回复"通道, 不吃"禁止魔力恢复"的封锁。
# 【为什么先 revoke】进度不撤销的话只会触发一次(踩过)。
# 【★ 第一行必须是 revoke ★】奖励函数跑完之前玩家可能又杀一只,
#   撤销放在后面会漏掉同一次结算。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/spine_symbiote_kill
execute unless items entity @s armor.chest diamond_chestplate[custom_data~{zx:["spine_symbiote"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 表现: 一圈惨白的骨色 + 拾取经验球的音效(通用的"回魔"反馈)
execute at @s run particle minecraft:dust{color:[0.80,0.95,0.70],scale:1.0} ~ ~1 ~ 1.2 0.7 1.2 0 18 normal
execute at @s run playsound minecraft:entity.experience_orb.pickup player @s ~ ~ ~ 0.5 1.4
