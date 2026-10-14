# ============================================================
# sweetdream:equipment/tool/frostmirror/on_hurt —— 「冰鉴」受击反制
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/tool/frostmirror_hurt
#   触发器 entity_hurt_player —— "玩家受到了伤害"。
# 【执行者】玩家(被打的那个人)
# 【文案(lore 逐字)】
#   「持于副手时，自身受到伤害后使自身 3 格内最近的一个生物冰冻 1 秒，并使
#     当前主手装备的主动技能冷却时间 -1 秒。该效果每 4 秒至多触发一次。」
# 【★ 内置冷却为什么存"到期时刻"而不是倒计时 ★】和法杖普攻门控(gate)同一招:
#   #now 是持久化 tick 计数、跨 /reload 连续; 存"到 什么时候才能再触发"就不
#   需要每刻有人去扣它, 也没有"玩家下线期间倒计时不走"的问题。
#   ★ 必须先置零再取值(坑 141 同款): 计分项从未赋值时 `>` 比较恒假 => 门控
#     静默失效; 归零后"没打过时间戳"的玩家取到 0, `0 > #now` 恒假 => 放行。
# 【★ 冰冻走公共库 ★】sweetdream:lib/freeze(宏 {target,ticks}) —— 它自带
#   "只延长不缩短"的重入语义、每刻续 TicksFrozen、到点自动解冻, 别自己造。
#   1 秒 = 20 tick。
# 【★ 减冷却只对主手 ★】读主手的 custom_data.skill 再交给 api/cooldown/reduce
#   (先例 armor/fade/cd_reduce)。主手没有 skill(比如空手)时整段跳过 ——
#   不往公共输入口写半成品参数。
# ============================================================

advancement revoke @s only sweetdream:equipment/tool/frostmirror_hurt

# ① 没持冰鉴就没这事(副手判定用物品谓词, 坑 93: weapon.offhand 只有谓词认)
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["frostmirror"]}] run return 0

# ② 内置冷却 4 秒(80 tick): 还没到点就收工
scoreboard players set #fm_due zx.meta 0
execute store result score #fm_due zx.meta run scoreboard players get @s zx.fm_cd
execute if score #fm_due zx.meta > #now manacore.meta run return 0

# ③ 圈出 3 格内最近的 1 个生物(不含玩家/marker/display; 排掉尸体)
#   ★ 用判定箱还是 distance: 这里文案是"3 格内最近的一个", 语义上就是距离,
#     直接用 distance=..3 + sort=nearest(不需要像法球那样考虑高个子判定箱)。
tag @e[tag=zx.fm_t,distance=0..] remove zx.fm_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3,sort=nearest,limit=1] add zx.fm_t

# ④ 冻住它 1 秒(20 tick)
data modify storage zx:work fz set value {target:"@e[tag=zx.fm_t,distance=0..,limit=1]",ticks:20}
execute if entity @e[tag=zx.fm_t,distance=0..,limit=1] run function sweetdream:lib/freeze with storage zx:work fz
execute at @e[tag=zx.fm_t,distance=0..,limit=1] run particle minecraft:snowflake ~ ~1.0 ~ 0.5 0.6 0.5 0.03 14 normal
execute at @e[tag=zx.fm_t,distance=0..,limit=1] run playsound minecraft:block.glass.break player @a ~ ~ ~ 0.6 1.4

# ⑤ 当前主手装备的主动技能冷却 -1 秒
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} if data entity @s SelectedItem.components."minecraft:custom_data".skill run function sweetdream:equipment/tool/frostmirror/cd_reduce

# ⑥ 打上"下一次能触发的时刻"(现在 + 80 tick = 4 秒)
scoreboard players operation @s zx.fm_cd = #now manacore.meta
scoreboard players add @s zx.fm_cd 80

# ⑦ 收尾
tag @e[tag=zx.fm_t,distance=0..] remove zx.fm_t
