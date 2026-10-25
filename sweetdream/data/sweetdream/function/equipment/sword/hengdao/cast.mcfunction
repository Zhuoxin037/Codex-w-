advancement revoke @s only sweetdream:equipment/sword/hengdao

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 ★ 超限快照必须存到玩家身上 ★ 伤害是 12 tick 之后(dash_end)才结算的,
#      那时手里那把已经不准了(可能已经换手/收回), 所以拍成计分项 zx.hd_ol。
#      【超限·横刀 加在这把上的机制(逐字照抄 oldef."hengdao".lore)】
#        基础版"最大魔力 ×0.08 打 2 格一次" -> 超限版"对附近 5 格内的全部生物
#        造成**两次**最大魔力 ×0.1 的伤害", 且**击杀生物则重置冷却时间**。
function sweetdream:equipment/sword/hengdao/is_ol
scoreboard players set @s zx.hd_ol 0
execute if score #hd_ol zx.meta matches 1 run scoreboard players set @s zx.hd_ol 1

# ② 只读检查: 冷却好没好 + 魔力够不够
#   【skill 绝对不能漏】api/skill/check 内部是"先看 skill 在不在, 在才去查冷却",
#   漏了它这个接口什么都不做, out.success 也不会变成 1b —— 整把刀就哑了。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:hengdao",mana:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"横刀冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 15)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 起突进: 把"还剩几步"写到自己身上, 剩下的交给每刻的 dash_tick 推着走
#   0.25 格/步 x 12 步 = 3 格。要改距离, 就改这里的 12 和 dash_tick 里的 0.25。
#   【为什么不再"同一 tick 里连 tp 三步"】一是看着像瞬移, 不丝滑; 二是
#   "在玩家自己那一 tick 里连续 tp"很容易被客户端的位置同步顶掉 ——
#   表现就是"调一次能走、再调就不动"。放到每刻的循环里一步步推就没这问题。
scoreboard players set @s zx.dash 12

# ④ 起手音效: 刀出鞘那一下的"唰"
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 1.0 1.2

# ⑤ 扣魔力 -15
data modify storage manacore:in arg set value {uuid:"",value:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑥ 记冷却
#   【skill 同样不能漏】api/cooldown/start 也是"有 skill 才动", 漏了就不进冷却。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:hengdao",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑦ 落点伤害不在这里结算
#   突进要分 12 刻才走完, 此刻人还在起点 —— 在这儿打伤害等于打"起点周围 2 格"。
#   所以伤害、粒子、命中音效全都放到"走完那一刻"调用的
#   sweetdream:equipment/sword/hengdao/dash_end 里, 那里才是真正的落点。
#   那条链是: 每刻 core/tick -> dash_tick 推一步 -> 步数归 0 时调 dash_end。
