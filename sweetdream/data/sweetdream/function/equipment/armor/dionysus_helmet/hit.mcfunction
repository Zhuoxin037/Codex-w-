# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/hit —— 攻击触发(超限·酒力爆发)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/dionysus_helmet_hit
#   (player_hurt_entity + 伤害类型 is_player_attack; 不像炉心那样要求目标在燃烧)
# 【文案(超限·狄俄尼索斯之桂冠, 逐字)】"自身攻击生物时，若自身「酒浆」达到
#   5 层以上则消耗 5 层「酒浆」，之后触发该装备的被动效果且强化为获得力量5
#   效果，且自身技能伤害提升 30%，之后获得一层「酒浆」，并且自身每秒恢复 80
#   点魔力值，之后每秒获得一次瞬间治疗4，持续 5 秒（持续期间不可再次触发）。"
# 【落实】① 酒浆>=5 -> 消耗 5 层; ② 被动(反胃Ⅱ 3秒 + 回魔)但力量强化为 Ⅴ;
#   ③ 技能伤害 +30%(zx.dio_emp 3 秒, hook_calc 消费 —— 与"愿景"升级同口径,
#     三条通道都写, 加算); ④ 酒浆 +1(净 -4 层); ⑤ 回魔 80/秒×3秒;
#   ⑥ 瞬间治疗Ⅳ每秒一次共 5 秒(zx.dio_ih 倒计时), 期间本触发直接短路。
# 【"持续期间不可再次触发"= 瞬间治疗那 5 秒】期间打不出这一下(第一道闸),
#   不是 5 秒内不能攒酒浆。
# 【★ 第一行必须是 revoke ★】一次性进度(规则 5/27); atk_charge 满蓄力闸排在
#   revoke 之后(lib/rearm 契约)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/dionysus_helmet_hit
# ---- 满蓄力闸(全包统一口径): 平A 没蓄满力这一发不触发 ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 戴着**超限版**桂冠才生效
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["dionysus_helmet"],ol:"dionysus_helmet"}] run return 0

# 「酒浆」没到 5 层 -> 什么都不发生(不消耗、不提示)
execute unless score @s zx.dio_wine matches 5.. run return 0

# 持续期间(瞬间治疗 5 秒)不可再次触发
execute if score @s zx.dio_ih matches 1.. run return 0

# ① 消耗 5 层「酒浆」
scoreboard players remove @s zx.dio_wine 5

# ② 触发被动(强化版): 反胃Ⅱ + 力量Ⅴ, 3 秒
effect give @s minecraft:nausea 3 1 true
effect give @s minecraft:strength 3 4 true

# ③ 技能伤害 +30%(3 秒; hook_calc 往加算池三条通道各写 30, 结束自动失效)
scoreboard players set @s zx.dio_emp 3

# ④ 「酒浆」+1(最多 10 层)
scoreboard players add @s zx.dio_wine 1
execute if score @s zx.dio_wine matches 11.. run scoreboard players set @s zx.dio_wine 10

# ⑤ 每秒回 80 魔力, 持续 3 秒
scoreboard players set @s zx.dio_regen 3
scoreboard players set @s zx.dio_ramt 80

# ⑥ 瞬间治疗Ⅳ每秒一次, 持续 5 秒(每秒由 second 补一次效果 + 倒计时)
scoreboard players set @s zx.dio_ih 5

# 反馈(消耗了 5 层、还剩多少)
tellraw @s [{"text":"酒力爆发！消耗 5 层「酒浆」","color":"light_purple","italic":false},{"score":{"name":"@s","objective":"zx.dio_wine"},"color":"aqua"},{"text":" 层剩余","color":"light_purple","italic":false}]
execute at @s run particle minecraft:effect ~ ~1 ~ 0.4 0.5 0.4 0.08 20 normal
execute at @s run playsound minecraft:block.brewing_stand.brew player @s ~ ~ ~ 0.8 1.1
