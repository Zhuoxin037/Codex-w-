# ============================================================
# sweetdream:equipment/sword/aurora_dream/cast —— 极光与幻梦: 群体时停
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/aurora_dream 的奖励函数
# 【文案】消耗 600 魔力 / 冷却 180 秒。
#   使用后时停自身 6 格内全部附有「白昼梦」效果的生物, 持续 12 秒。
# 【时停走公共件】lib/timestop(NoAI 完全定格 + 重入保护 + 时长只延长不缩短),
#   12 秒 = 240 tick。到点由 lib/unfreeze_sweep 每秒扫 zx.ts_end 解冻 —— 不用 schedule。
# 【为什么先确认有目标】没有白昼梦生物就整个不放(不扣蓝、不进冷却)。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/aurora_dream

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 600
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:aurora_dream",mana:600.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"极光与幻梦冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 600)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=..6,tag=zx.status.dream] run tellraw @s [{"text":"附近没有附带「白昼梦」的生物","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=..6,tag=zx.status.dream] run return fail

# ④ 扣魔力 600
data modify storage manacore:in arg set value {uuid:"",value:600.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 600)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 180 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:aurora_dream",cooldown_seconds:180.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 时停 6 格内全部带「白昼梦」的生物, 240 tick = 12 秒
#    ⚠️ 必须 at @s —— 只写 as 的话 distance 会相对服务器出生点算(风行/超载都栽过)。
execute at @s run data modify storage zx:work fz set value {target:"@e[type=!#sweetdream:no_damage,distance=..6,tag=zx.status.dream]",ticks:240}
execute at @s run function sweetdream:lib/timestop with storage zx:work fz

# ⑦ 表现: 极光铺开(分层, 更大更华丽)
execute at @s run particle minecraft:flash ~ ~1.2 ~ 0 0 0 0.0 1 normal
execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.2 0.8 1.2 0.10 60 normal
execute at @s run particle minecraft:end_rod ~ ~0.4 ~ 3.2 0.5 3.2 0.06 80 normal
execute at @s run particle minecraft:enchant ~ ~1.4 ~ 2.6 0.8 2.6 0.35 60 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1.2 ~ 2.4 0.6 2.4 0.05 50 normal
execute at @s run particle minecraft:firework ~ ~1.5 ~ 3.0 0.8 3.0 0.04 60 normal
execute at @s run particle minecraft:witch ~ ~1 ~ 2.8 0.8 2.8 0.02 40 normal
execute at @s run particle minecraft:electric_spark ~ ~1.2 ~ 2.2 0.6 2.2 0.03 30 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 1.0 1.5
execute at @s run playsound minecraft:entity.illusioner.cast_spell player @a ~ ~ ~ 0.9 1.0
# 起手这一声钟 = 时间轴上的"第 0 秒"(后面 4/8 秒由 aurora_dream/bell 补, 所以别在这儿
#   再想"要不要多响一声"). 音色与 bell_sfx **完全一致**(2026-10-09 按玩家参考命令定版:
#   block.bell.use / 通道 block / 音量 0.1 / 音调 0.3 / 最小音量 0.1 —— 单音色, 无泛音)。
execute at @s run playsound minecraft:block.bell.use block @a ~ ~ ~ 0.1 0.3 0.1

# ⑧ 时停期间**稳定每 4 秒**响一次飘渺钟声 + 持续铺极光粒子
#   起手那声已经由 ⑦ 播过了, 所以这里只需要把倒计时推到 12 —— aurora_dream/bell 会在
#   剩下的 4/8 秒各补一声(时间轴 4/8 秒), 三声间隔全是 4 秒。★ 别再补"第 0 声", 会双响。
#   倒计时挂 zx.ad_bell(秒), 由 lib/second 每秒推进。
scoreboard players set @s zx.ad_bell 12

# 极光与幻梦 · 月蚀流光施法模型
function sweetdream:equipment/sword/aurora_dream/anim/start
# 极光与幻梦 · 月蚀流光施法模型 / END
