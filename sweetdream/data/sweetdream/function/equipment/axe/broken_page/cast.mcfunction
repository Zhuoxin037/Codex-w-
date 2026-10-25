# ============================================================
# sweetdream:equipment/axe/broken_page/cast —— 断页 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/broken_page(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能   魔力 80 · 冷却 20 秒
#   "使用后对准星前方 5 格内的一个生物造成 12 点固定伤害。若其附有「白昼梦」，
#    则消耗「白昼梦」，且本次伤害改为 30 点固定真实伤害。"
# 【★ 四要素 ★】
#   ① 触发: 右键。
#   ② 范围: "准星前方 5 格内的**一个**生物" -> 递归射线(ray)取视线撞到的第一只,
#      不是"最近的一只"(墙后的怪不该被打到)。
#   ③ 次数: 对那一只结算一次。带白昼梦 -> 消耗 -> 本段改 30 点真伤(不是多加一段)。
#   ④ 时长: 无状态、无计时(纯瞬发)。
# 【★ 固定伤害不参与任何乘区 ★】
#   12 / 30 直接走 custom_damage, 不写 max_mana_mul / attack_mul / other_mul
#   ⇒ lib/skill_mul/def 里登记 wchan.broken_page = {mm:0b,atk:0b,oth:0b}。
# 【★ 消耗走 lib/mark_consume, 判 src:"skill" ★】
#   它是"技能消耗", 回潮扣/杂纹 那几件按 src 分流时要算进来(见 mark_consume ①.5)。
#   穿「永恒」时标签会被原地补回(mc.done = 1b) —— 那种情况**不算消耗**,
#   本次仍按 12 点固定伤害结算(同失血/彼岸的"真消耗才算"口径)。
# 【★ 顺序: 先射线找目标 -> 再扣费 -> 再结算 ★】
#   射线只读(找 + 打标记), 找不到目标就整段不发生, 不会白扣 80 蓝。
# 【前缀】zx.bp_* / #bp_* —— 定名前全树 grep 过(坑 167)。
# ============================================================

# ⓪ 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/axe/broken_page

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 80
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:broken_page",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"断页冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 80）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 准星射线找目标(5 格)
#   ★★ 步数必须每次归零 ★★ `#bp_st` 是递归计数器, 不归零的话第二次施法第一行
#   就 `matches 11..` 立刻收工, 表现是"只有第一次能放"(静默、零日志)。
#   ★★ 必须 anchored eyes 起头 ★★ 默认锚点在脚底, 从脚底往前射会立刻撞到脚下
#   那格方块就地收工 ⇒ 永远找不到目标。
scoreboard players set #bp_st zx.meta 0
tag @e[tag=zx.bp_tgt,distance=0..] remove zx.bp_tgt
execute anchored eyes run function sweetdream:equipment/axe/broken_page/ray

execute unless entity @e[tag=zx.bp_tgt,distance=0..,limit=1] run tellraw @s [{"text":"准星前方 5 格内没有目标","color":"red"}]
execute unless entity @e[tag=zx.bp_tgt,distance=0..,limit=1] run return fail

# ④ 扣魔力 80
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 80）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:broken_page",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 它带「白昼梦」吗? 带就消耗, 并把本段改成 30 点真伤
#   ★ 先拍"带不带"再消耗: 消耗之后标签就没了, 那时再判永远为假(静默只打 12)。
scoreboard players set #bp_true zx.meta 0
execute if entity @e[tag=zx.bp_tgt,distance=0..,tag=zx.status.dream,limit=1] run scoreboard players set #bp_true zx.meta 1
execute if score #bp_true zx.meta matches 1 run data modify storage zx:work a set value {fixed:1b,target:"@e[tag=zx.bp_tgt,distance=0..,limit=1]",mark:"dream",src:"skill"}
execute if score #bp_true zx.meta matches 1 run function sweetdream:lib/mark_consume
#   ★ 只有"真消耗"才转真伤: 穿「永恒」时标签被原地补回(mc.done = 1b), 不算消耗,
#     本次仍按 12 点固定伤害结算。
execute if score #bp_true zx.meta matches 1 if data storage zx:work mc{done:1b} run scoreboard players set #bp_true zx.meta 0

# ⑦ 算伤害: 12(普通) 或 30(真伤)
data modify storage manacore:in arg set value {uuid:"",custom_damage:12.0}
execute if score #bp_true zx.meta matches 1 run data modify storage manacore:in arg.custom_damage set value 30.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ⑧ 打过去(只打射线锁定的那一只; 真伤换类型)
data modify storage zx:in arg set value {fixed:1b,target:"@e[tag=zx.bp_tgt,distance=0..,limit=1]",damage:0.0,type:"minecraft:player_attack"}
execute if score #bp_true zx.meta matches 1 run data modify storage zx:in arg.type set value "sweetdream:true_damage"
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑨ 表现: 纸页翻飞 + 撕页声(真伤那一版用紫白, 一眼能看出打穿了)
execute at @e[tag=zx.bp_tgt,distance=0..,limit=1] run particle minecraft:dust{color:[0.92,0.90,0.82],scale:1.2} ~ ~1 ~ 0.5 0.6 0.5 0.02 18 normal
execute if score #bp_true zx.meta matches 1 at @e[tag=zx.bp_tgt,distance=0..,limit=1] run particle minecraft:dust{color:[0.72,0.55,1.0],scale:1.5} ~ ~1 ~ 0.4 0.5 0.4 0.02 14 normal
execute at @s run playsound minecraft:item.book.page_turn player @a ~ ~ ~ 0.8 0.9
execute if score #bp_true zx.meta matches 1 at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.6 1.2
tag @e[tag=zx.bp_tgt,distance=0..] remove zx.bp_tgt
