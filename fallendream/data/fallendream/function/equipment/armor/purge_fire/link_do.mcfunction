# ============================================================
# fallendream:equipment/armor/purge_fire/link_do —— 涤火(超限)：额外附上「夜火」+ 受伤 +20%
# ------------------------------------------------------------
# 【执行者】那只在窗口内被重新点上「流火」的生物
# 【做什么】
#   ① 额外附加「夜火」（走公共 tag/mark，不是消耗）
#   ② 打上 zx.pf_vuln —— internal/damage/one 见到它就调 purge_fire/vuln（×1.20）
#   ③ 打上 zx.pf_tgt —— 让涤火持有者"每次对其造成伤害 +1 基础攻击力"能认到这只
# 【★ 为什么用标签而不是属性修饰符 ★】原版没有"受到伤害"属性; 本包所有受击侧乘区
#   都在 internal/damage/one 里按标记乘, 这里只是挂标记。
# 【★ 标记谁来撤 ★】tag/unmark_one: 「流火」「夜火」都走光时摘掉 zx.pf_vuln /
#   zx.pf_tgt（文案限定"在该「流火」或「夜火」的持续时间内"）。
# ============================================================

data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
function fallendream:tag/mark with storage zx:work ic

tag @s add zx.pf_vuln
tag @s add zx.pf_tgt
tag @s remove zx.pf_watch
scoreboard players set @s zx.pf_w_end 0

execute at @s run particle minecraft:soul_fire_flame ~ ~0.8 ~ 0.4 0.5 0.4 0.01 10 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.5 1.2
