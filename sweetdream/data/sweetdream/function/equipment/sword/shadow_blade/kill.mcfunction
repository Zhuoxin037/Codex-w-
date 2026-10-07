# ============================================================
# sweetdream:equipment/sword/shadow_blade/kill —— 影刃: 5 秒内击杀 -> 刷新冷却 + 返蓝
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/shadow_blade_kill(player_killed_entity)
# 【执行者】动手的玩家
# 【★ 首行必须 revoke 自己 ★】否则这个进度一辈子只触发一次(见 lib/rearm 的说明)。
# 【怎么判"这次击杀算不算数"】施法时写过 zx.sb_end = 施法时刻 + 100 tick;
#   只要 `zx.sb_end > #now` 就说明还在 5 秒窗口内(窗口过期后 now 走过去了, 自动失效)。
# 【武器判定】进度本身只保证"玩家击杀了生物", 所以要自己确认手上是影刃。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/shadow_blade_kill

# ① 不在窗口内 -> 什么都不做
execute unless score @s zx.sb_end > #now manacore.meta run return 0

# ② 主手/副手都不是影刃 -> 不算(避免用别的武器蹭这个窗口)
execute unless items entity @s weapon.mainhand diamond_sword[custom_data~{zx:["shadow_blade"]}] unless items entity @s weapon.offhand diamond_sword[custom_data~{zx:["shadow_blade"]}] run return 0

# ③ 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ④ 刷新冷却(直接归零, 不是"减几秒")
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:shadow_blade"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reset

# ⑤ 返还 60 魔力
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ⑥ 关掉窗口 + 提示
scoreboard players reset @s zx.sb_end
tellraw @s [{"text":"影刃·击杀: 冷却已刷新, 返还 ","color":"aqua"},{"text":"60","color":"white"},{"text":" 魔力","color":"aqua"}]
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4
