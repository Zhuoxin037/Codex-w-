# ============================================================
# sweetdream:equipment/armor/spine_symbiote/kill —— 击杀生物后回魔(+ 超限的定时加成)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/spine_symbiote_kill
#   trigger: player_killed_entity -> 玩家杀死实体时执行, @s = 玩家
# 【文案(普通)】每次击杀生物都会恢复自身 60 点魔力值。
# 【★ 超限(2026-10-07) ★】
#   ① 回魔 60 -> 80
#   ② 每次击杀额外给 20 秒的"魔力上限 ×0.02"护甲值 + 最大生命值定时加成
#      (由 passive 每秒折进去, 到期自动收回)
#   ③ 若这一下"触发被动时"自身处于脑髓蛭「蛊虫」的**消耗模式**(zx.bl_gm = 1,
#      即"满 10 层后每次攻击 -1 层"的那段), 额外给 5 秒抗性提升Ⅴ
#      (玩家 2026-10-07 口径: 文案的"带着蛊虫状态"指消耗模式, 不是"身上有层数"。)
#      —— 注: 文案里"该被动效果强化为 ×0.05"按玩家 2026-10-07 的确认, 指的是
#         **魔力满时的那条基础加成**, 而超限版的基础本来就写成 ×0.05(见 passive),
#         所以那句话在数值上是个恒等式, 真正可观察的差异就是这里的抗性Ⅴ。
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

# ---- 超限: 定时护甲/生命 + 蛊虫联动(先判, 免得把普通版也带上) ----
execute if items entity @s armor.chest diamond_chestplate[custom_data~{ol:"spine_symbiote"}] run function sweetdream:equipment/armor/spine_symbiote/kill_overlimit

# ---- 回魔: 60(普通) / 80(超限) ----
data modify storage zx:work kv.val set value 60.0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{ol:"spine_symbiote"}] run data modify storage zx:work kv.val set value 80.0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work kv.val
function manacore:api/mana/add

# 表现: 一圈惨白的骨色 + 拾取经验球的音效(通用的"回魔"反馈)
execute at @s run particle minecraft:dust{color:[0.80,0.95,0.70],scale:1.0} ~ ~1 ~ 1.2 0.7 1.2 0 18 normal
execute at @s run playsound minecraft:entity.experience_orb.pickup player @s ~ ~ ~ 0.5 1.4
