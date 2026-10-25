# ============================================================
# sweetdream:equipment/staff/final_revelation/skill —— 终末天启: 主动技能
# ------------------------------------------------------------
# 【文案】消耗 500 魔力 / 冷却 30 秒。仅能在没有释放该技能的时候使用。
#   使用后朝自身前方射出一道持续 6 秒、范围为 4×16 的光柱。
# 【★ "仅能在没有释放该技能的时候使用" ★】判 zx.fr_t:还有光柱在放 -> 直接不放。
#   ★ 计分项"没有分数"时 `if score ... matches 1..` 是**直接判失败** ——
#     正好等于"没在放", 所以新玩家第一次就能用, 不用额外兜底。
# 【★ 光柱跟随玩家(用户 2026-10-06 定)★】不是固定在世界里 ——
#   第二秒开始按玩家**当前**位置与朝向重新扫, 可以边跑边扫。
#   所以这里只记"还剩 6 秒", 不存位置/朝向(见 tick + scan)。
# 【为什么不在开始时清「圣光」】文案只说"圣光触发"那条会清除;
#   手动释放不动它 —— 免得攒了 9 层手动放一下白扔掉。
#   (要改的话: 在这里补一句 scoreboard players set @s zx.fr_light 0 即可。)
# ============================================================

# ⓪ 已有光柱 -> 不允许再放
execute if score @s zx.fr_t matches 1.. run tellraw @s [{"text":"终末天启的光柱还在释放中","color":"red"}]
execute if score @s zx.fr_t matches 1.. run return fail

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:final_revelation",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"终末天启冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 500)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:final_revelation",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 点火: 6 秒光柱 + 标记"这次是主动释放"(结束时有 ×0.2 收尾伤害)
scoreboard players set @s zx.fr_auto 0
scoreboard players set @s zx.fr_t 6

# ⑥ 表现
execute at @s anchored eyes run particle minecraft:end_rod ^ ^ ^1 0.25 0.25 0.25 0.0 24 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.9 1.0
execute at @s run playsound minecraft:block.respawn_anchor.set_spawn player @a ~ ~ ~ 0.8 1.1
