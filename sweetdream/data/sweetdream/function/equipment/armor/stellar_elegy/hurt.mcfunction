# ============================================================
# sweetdream:equipment/armor/stellar_elegy/hurt —— 受击触发
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/stellar_elegy(entity_hurt_player)
# 【文案】每次受到攻击后获得抗性提升 2 且自身每秒恢复 10 魔力值, 持续 5 秒。
#         之后使自身 5 格内全部有「流火」「夜火」「渊海」「白昼梦」「噬心」中
#         任意一个效果的生物受到一次相当于自身当前魔力值 ×0.02 的伤害。
# 【顺序】先撤销进度 -> 再判断"戴没戴" -> 给 buff -> 最后打范围伤害("之后")
# ============================================================

# ⓪ 撤销自己的进度(不撤销就只有第一次受伤会触发)
advancement revoke @s only sweetdream:equipment/armor/stellar_elegy

# ① 戴着才生效(~ 部分匹配 + 独有标记, 以后改 give 也不用跟着改)
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["stellar_elegy"]}] run return fail

# ② 抗性提升 2(5 秒) + 起"每秒回 10 魔力"的倒计时(5 秒, 由 second 扣)
#   II 级 = amplifier 1; 隐藏粒子(true)是为了别在身上一直冒圈圈
effect give @s minecraft:resistance 5 1 true
scoreboard players set @s zx.se_regen 5

# ③ 之后: 让自身 5 格内"带任意一个通用标签"的生物各吃一次 当前魔力 ×0.02
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work ma.target set value "@e[type=!#sweetdream:no_damage,distance=..5]"
function sweetdream:lib/marks_any with storage zx:work ma
execute if entity @e[tag=zx.marked] run function sweetdream:equipment/armor/stellar_elegy/aoe

# ④ 表现: 一圈暗蓝色的星屑(和"群星"这个主题对上)
execute at @s run particle minecraft:dust{color:[0.55,0.70,1.0],scale:1.2} ~ ~1 ~ 2.6 1.0 2.6 0 35 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.7 1.4
