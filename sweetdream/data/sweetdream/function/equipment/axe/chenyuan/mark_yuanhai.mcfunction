# ============================================================
# sweetdream:equipment/axe/chenyuan/mark_yuanhai —— 为刚打中的生物附加「渊海」
# ------------------------------------------------------------
# 【执行者】玩家   【目标】zx.victim
# 【走通用标签接口】这样头顶会有渊海的图标, 也能被别的效果(深海回响 / 击杀进度)认出来。
# ============================================================

data modify storage zx:work ic set value {target:"@e[tag=zx.victim]",mark:"yuanhai"}
function sweetdream:tag/mark with storage zx:work ic
execute at @e[tag=zx.victim] run particle minecraft:bubble ~ ~1 ~ 0.4 0.4 0.4 0.03 14 normal
execute at @s run playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.5 1.4
