# ============================================================
# sweetdream:equipment/sword/liuguang/overlimit —— 超限·流光(释放)
# ------------------------------------------------------------
# 【谁调用它】liuguang/cast —— 敲过超限的流光, 右键走这里(原版技能被它顶掉)
# 【文案】消耗魔力 120 / 冷却 8 秒; 随机锁定自身 10 格内 4 个生物, 其中一个
#   必定是最近的那个; 锁定期间被锁定的生物获得缓慢 3; 3 秒后对它们造成
#   相当于自身基础攻击力 ×4 的伤害(保底 15); 带「流火」或「夜火」的目标翻倍。
# 【和原版流光的差别】(原版: 1 个目标 / 8 格 / ×2 / 保底 6 / 20 蓝 / 20 秒冷却)
#   这里是 4 个目标 / 10 格 / ×4 / 保底 15 / 120 蓝 / 8 秒冷却, 还多了缓慢和翻倍。
# 【流程】①uuid ②只读检查(冷却+魔力) ③有没有目标 ④扣蓝 ⑤记冷却
#         ⑥算伤害(×4, 保底 15) ⑦锁定 4 只 + 缓慢 3 + 记账(交给宏层)
#         ⑧挂上"待结算", 3 秒后由 ol_hit_self 那条线结算(见 lib/second)
# 【为什么用同一个 skill id】观测镜是按"主手物品的 custom_data.skill"显示冷却的,
#   沿用 sweetdream:liuguang 才能让面板上的 8 秒正确显示; 反正敲了超限之后
#   原版技能不再使用, 共用一条冷却不会打架。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 120
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"超限·流光冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 120)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放(不扣蓝、不进冷却)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run return fail

# ④ 扣魔力
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却(8 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",cooldown_seconds:8.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 算伤害: 基础攻击力 ×4, 保底 15
data modify storage manacore:in arg set value {uuid:"",skill_multiplier:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

scoreboard players set #dmg zx.meta 0
execute store result score #dmg zx.meta run data get storage manacore:out r.damage 1
execute if score #dmg zx.meta matches ..14 run data modify storage manacore:out r.damage set value 15.0

# ⑦ 锁定 + 缓慢 + 记账(宏层: 标签名里要带自己的 UUID)
data modify storage zx:work a.uuid set from storage zx:data self.uuid
data modify storage zx:work a.damage set from storage manacore:out r.damage
function sweetdream:equipment/sword/liuguang/ol_lock with storage zx:work a

execute unless data storage zx:work a{locked:1b} run return fail

# ⑧ 打上"我有一笔结算待处理", 3 秒后由每秒循环结算
tag @s add zx.lgo_casting
