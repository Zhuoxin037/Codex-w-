# ============================================================
# sweetdream:equipment/axe/charge/autocast —— 超限·超•负•荷: "自动使用"一次
# ------------------------------------------------------------
# 【原文】"该状态结束后若该技能完成冷却，则自动使用…"
# 【谁调用它】end_ol(状态结束、冷却已归零 -> 自动再开那一拍) —— **唯一入口**
#   (2026-10-10 用户定稿删掉了 mode_tick 那条"冷却自然走完就自动开"的路)
# 【执行者】玩家
# 【和 cast 的差别】不消耗魔力 —— 文案只说"自动使用", 没说扣蓝;
#   真正的手动 cast 仍然扣 300 魔力(超限不改变消耗)。
#   ★★ 2026-10-10 修: **自动使用也必须重新起 100 秒冷却 ★★**
#     之前漏了这一句, 后果很严重: mode_tick 每秒查"冷却好了没", 而自动使用
#     不重置冷却 ⇒ 冷却恒为"已好" ⇒ 每秒自动放一次 ⇒ zx.chg_on 被无限刷新
#     = **永久超载、状态结束不了**。
#     (用户原话: "超载开始的时候冷却没有重回 100s, 这就导致会一直超载"。)
#   口径: "自动使用" = 使用一次该技能 ⇒ 与手动 cast ④ 完全同口径地起冷却
#     (同样吃玩家的冷却缩减 reduce:1b)。
#   ★ 循环节奏(用户 2026-10-10 定稿): 自动使用**只在状态结束那一拍**(end -> end_ol),
#     且要求"状态期间冷却已被 -4 秒被动压到 0" ⇒ [15 秒状态(冷却冻结) -> 压到 0 -> 自动放 -> …];
#     压不到 0 -> 超载结束、冷却恢复自然流动、**不再自动开**(见 second ③)。
#     所以这里的"重起 100 秒"是每轮循环的**起始满值**。
# 【术阵】id 固定 sweetdream:charge, 再建会刷新, 不会越堆越多。
# ============================================================

# ① 拿 uuid(起冷却要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 进入超载状态
scoreboard players set @s zx.chg_on 15

# ③ 起 100 秒冷却 —— 缺了它就会一直超载(见文件头 ★★)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ④ 重召术阵(15 秒)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:charge",type:"charge",duration_seconds:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑤ 超限专属(第二形态的自动使用) -> 直接给迅捷 III
effect give @s minecraft:speed 3 2 true
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.8 0.8 0.8 0.05 30 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.9 1.1
tellraw @s [{"text":"超限·超•负•荷 · 冷却完成, 自动超载","color":"light_purple"}]
