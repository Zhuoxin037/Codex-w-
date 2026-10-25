# ============================================================
# sweetdream:equipment/axe/sacred_relic/cast —— 圣骸 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/sacred_relic(consume_item) -> rewards
# 【主动原文(必须和这里对上)】
#   魔力 400 / 冷却 40 秒。
#   "使用后召唤一个术阵。每秒使自身12格内的全部「遗骸」对其3格内的随机一个生物造成
#    一次相当于释放者最大魔力值 ×0.1 的伤害。若「遗骸」上有「流火」则伤害 +30% 且
#    锁定范围 +1 格；若有「夜火」则伤害 +80%；若有「噬心」则额外附加相当于死亡者最大
#    生命值 5% 的真实伤害；若有「白昼梦」则额外附加 0.3 秒的时停；若有「渊海」则锁定
#    目标 +2。共持续 12 秒。"
# 【四要素】① 触发 = 右键; ② 范围 = 自身 12 格内的「遗骸」→ 遗骸 3(±标签加成) 格内随机 1 只;
#   ③ 次数 = 每秒 1 次; ④ 时长 = 12 秒(状态 zx.sr_on = 12, lib/second 每秒结算并 -1)。
# 【伤害口径】释放者**最大魔力 ×0.1** -> max_mana_mul 通道;
#   遗骸标签的 +30%/+80% 走**独立乘区**(predicate 里的千分比 -> independent_multiplier)。
# 【放在哪结算】每秒的活干在 sacred_relic/second(经 lib/second 驱动, 执行者=施法者)。
# 【数值改哪】倍率 0.1 = sacred_relic/strike 的 max_mana_mul; 加成 30%/80% 与锁定 +1/+2 同在 strike;
#   主动 12 跳 = 本文件 ⑥ 的 zx.sr_on / zx.sr_next; 遗骸 240 刻 = relic_spawn 的 zx.sr_ft。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/sacred_relic

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 400
#   【skill 不能漏】api/skill/check 是"有 skill 才查冷却"; 漏了它 out.success 不会翻 1b。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sacred_relic",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"圣骸冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 400）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 400
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sacred_relic",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤术阵(12 秒 = 与状态同寿; 术阵槽位满了会建失败, 不影响技能本身, 所以不看返回值)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:sacred_relic",type:"sacred_relic",duration_seconds:12.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 起状态: 从本次施法起每隔准确 20 刻结算一次, 共 12 跳(240 刻)。
scoreboard players set @s zx.sr_on 12
scoreboard players operation @s zx.sr_next = #now manacore.meta
scoreboard players add @s zx.sr_next 20

# ⑦ 表现: 一圈骨质光环
execute at @s run particle minecraft:dust{color:[0.92,0.90,0.80],scale:1.4} ~ ~1 ~ 1.6 0.8 1.6 0 30 normal
execute at @s run particle minecraft:soul ~ ~1 ~ 1.2 0.6 1.2 0.02 20 normal
execute at @s run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.8 0.7
execute at @s run playsound minecraft:entity.illusioner.cast_spell player @a ~ ~ ~ 0.7 0.9

# 圣骸武器动效；原技能数值与计时不变。
function sweetdream:equipment/axe/sacred_relic/visual/begin
