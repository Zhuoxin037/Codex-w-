# ============================================================
# sweetdream:equipment/staff/sail/recall —— "再次使用技能": 把那个旋风召唤到自身处
# ------------------------------------------------------------
# 【谁调用它】sail/skill 第 ③ 步(旋风进行中再按技能); 【执行者】施法玩家
# 【技能原文(lore 逐字)】期间自身可以再次使用技能来将该旋风召唤至自身处，持续 15 秒。
#   若自身召唤了该旋风则技能缩短 3 秒。
# 【★ 传送的是"旋风", 不是"被记录的生物" ★】(2026-10-08 用户更正:
#   "风帆的传送是传送旋风而不是啥生物"。)
#   旋风本体 = 那个 marker(坐标就是位置真相) —— 把 marker 挪过来, 它的形状
#   (whirl_fx 每刻按 marker 坐标画) 与吸附(whirl_pulse 以 marker 为中心圈 5 格)
#   整套跟着走; 被记录的生物留在原地不动。
# 【口径】再次使用**不再花蓝、不再起新冷却**(它依附在已经放出去的旋风上);
#   "技能缩短 3 秒"按**冷却缩短 3 秒**实现(api/cooldown/reduce, 减的是本技能当前冷却)。
#   旋风已经不在 -> 不成立(给提示)。
# ============================================================

# ① 找"自己放的那个旋风"(按释放者 uuid 字符串反查; 见 find_whirl)
#   ★ 释放者 uuid 在 skill 第 ① 步 lib/uuid 时已存进 zx:data self.uuid, 这里直接用
#     (skill 第 ① 步就 `unless ... self{ok:1b} run return fail` 守过, 到这里必然有值)。
data modify storage zx:work slu set value {uuid:""}
data modify storage zx:work slu.uuid set from storage zx:data self.uuid
function sweetdream:equipment/staff/sail/find_whirl with storage zx:work slu
execute unless entity @e[tag=zx.sl_mine,distance=0..,limit=1] run tellraw @s [{"text":"旋风已经不在了","color":"red"}]
execute unless entity @e[tag=zx.sl_mine,distance=0..,limit=1] run return fail

# ② 把旋风召唤到自身处
#   ★ 抬到 ~ ~1 ~, 和 whirl_spawn 出生时同一个高度(旋风的几何是"从 marker 往下接地"
#     画的, 平放在脚底反而会画进地里)。
execute at @s run tp @e[tag=zx.sl_mine,distance=0..,limit=1] ~ ~1 ~
function sweetdream:equipment/staff/sail/visual/begin

# ③ 技能冷却 -3 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sail",seconds:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

# ④ 表现 + 清理临时标记
execute at @e[tag=zx.sl_mine,distance=0..,limit=1] run particle minecraft:cloud ~ ~1 ~ 0.8 0.8 0.8 0.05 20 normal
execute at @e[tag=zx.sl_mine,distance=0..,limit=1] run particle minecraft:small_gust ~ ~0.5 ~ 0.6 0.6 0.6 0.08 14 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.7 1.3
execute at @s run playsound minecraft:item.elytra.flying player @a ~ ~ ~ 0.6 1.4
tag @e[tag=zx.sl_mine,distance=0..] remove zx.sl_mine
