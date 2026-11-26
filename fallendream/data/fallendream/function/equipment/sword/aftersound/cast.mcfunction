# ============================================================
# fallendream:equipment/sword/aftersound/cast —— 余响（剑·歌者）主动
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/sword/aftersound（右键 consume_item）
# 【文案（用户 2026-11-01 原稿）】
#   魔力 300 · 冷却 35 秒。
#   使用后召唤一个术阵。若 5 秒后自身术阵未满，则再次召唤一个术阵。
#   之后 12 秒内，自身 15 格内的全部"追随者"在触发一次被动效果后
#   立即向自身收回，且收回时恢复的魔力值提升至 80。
#   结束后，自身每收回一个"追随者"，自身下一次技能伤害 +5%。
# 【★ 术阵是纯占位 ★】这里只是往 manacore 登记一个带时长的术阵，
#   没有实体、没有位置。追随者由前置包的 formation_create 事件
#   （挂着 profession/singer/create）在施法者脚下生成。
# 【★ 三段的时间线都在 zx.as_* 上，由 second 推进 ★】
#   本文件只负责"第一次召唤 + 排好 5 秒/12 秒两个时刻"。
# ============================================================

advancement revoke @s only fallendream:equipment/sword/aftersound

execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:aftersound",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"余响冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 300）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:aftersound",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ① 立刻召唤一个术阵（持续 5 秒）
function fallendream:equipment/sword/aftersound/form5

# ② 排期：5 秒后判第二次召唤，之后进入 12 秒窗口
scoreboard players operation @s zx.as_t2 = #now manacore.meta
scoreboard players add @s zx.as_t2 100
scoreboard players set @s zx.as_on 1
scoreboard players set @s zx.as_win 0
scoreboard players set @s zx.as_end 0

execute at @s run particle minecraft:note ~ ~1 ~ 1.0 0.7 1.0 0.4 20 normal
execute at @s run playsound minecraft:block.note_block.chime player @a ~ ~ ~ 1.0 1.4
