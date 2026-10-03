# ============================================================
# sweetdream:equipment/sword/liuguang/ol_hit_calc —— 真的打出这一下(宏 {uuid,damage,u0..u3})
# 【执行者】被打中的那只生物
# ------------------------------------------------------------
# 【★ 翻倍只翻一次 ★】文案是"附有「流火」**或**「夜火」则伤害翻倍" ——
#   两个都带也只算一次, 所以第二句要 unless 掉第一句(不是各乘一次)。
# 【为什么先 ×10 再算】计分板是整数运算, 伤害可能是小数(比如 37.5);
#   先放大 10 倍保住一位小数, 翻倍后再用 0.1 缩回去。
# 【为什么用 num/plain】命令的数值参数只能是命令文本里的字面量,
#   double 直接渲染会带 "d" 后缀, 解析器不认 —— 得转成纯数字字符串。
# ============================================================

$tag @s remove zx.lgo_$(uuid)

scoreboard players set #ol_dmg zx.meta 0
execute store result score #ol_dmg zx.meta run data get storage zx:work a.damage 10
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players operation #ol_dmg zx.meta *= #2 zx.meta
execute unless entity @s[tag=zx.status.liuhuo] if entity @s[tag=zx.status.yehuo] run scoreboard players operation #ol_dmg zx.meta *= #2 zx.meta
execute store result storage zx:work a.num double 0.1 run scoreboard players get #ol_dmg zx.meta
function sweetdream:lib/num/plain

data modify storage zx:work a.target set value "@s"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.4 0.4 0.15 30 normal
execute at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.5 0.3 0.02 14 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.2
