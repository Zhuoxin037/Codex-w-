# ============================================================
# fallendream:equipment/armor/mottle_vein/reward —— 杂纹: 凑满 3 种后兑现
# ------------------------------------------------------------
# 【谁调用它】batch21/player_tick（zx.mv_pend == 1 时，每刻扫一次）
#   —— 不是 consume 直接调! consume 只落 zx.mv_pend=1（理由见 consume 文件头）
# 【执行者】消耗者玩家
# 【技能原文(基础)】"累计消耗 3 种后，清空记录，立即恢复 20 点魔力值，并获得 3 秒
#   迅捷Ⅱ和抗性提升Ⅰ；若消耗了「流火」则额外恢复 30 点魔力值；若消耗了「夜火」
#   则下一次技能伤害 +20%；若消耗了「噬心」则自身恢复 15% 最大生命值；若消耗了
#   「渊海」则使自身 3 格内的全部生物击退 1 格；若消耗了「白昼梦」则使自身下一次
#   攻击到的生物时停 1 秒。"
# 【技能原文(超限)】"累计消耗 3 种后，清空记录，立即恢复 80 点魔力值，并获得 8 秒
#   迅捷Ⅱ和抗性提升二；若消耗了「流火」则额外恢复 30点魔力值并恢复 1% 魔力值；
#   若消耗了「夜火」则下一次技能伤害 +25%；若消耗了「噬心」则自身恢复 25% 最大生命值；
#   若消耗了「渊海」则使自身 6 格内的全部生物击退 2 格；若消耗了「白昼梦」则使自身
#   下一次攻击到的生物及周围 2 格生物时停 1 秒。若本次消耗的标签超过 4 种，则每秒
#   使自身 8 格内的随机 3 个生物附加一个随机标签，持续 4 秒。"
# 【★ 顺序 ★】先给基础奖励, 再按种类给额外奖励, 最后才清记录 ——
#   额外奖励是"按本轮记过的种类"判的, 一清就判不到了。
# 【★ "超过 4 种" ★】zx.mv_n 记的是**不同种类数**(0..5)。因为兑现延后到本刻末,
#   一次消耗里同时摘掉 5 个标签时 n 就能到 5 => n ≥ 5 才算"超过 4 种"。
# 【★ 迅捷Ⅱ / 抗性提升Ⅱ 的 amplifier ★】Ⅱ = 1, Ⅲ = 2(与包内其它 effect 一致)。
#   `true` = 隐藏粒子(不要因为状态栏飘粒子把视野糊住)。
# ============================================================

# ⓪ 先把待兑现标记清掉(不管后面走不走得通, 都不能让它每刻重复结算)
scoreboard players set @s zx.mv_pend 0

# ① 还穿着杂纹吗(扣到一半脱了就不结算, 记录留着下次重开窗口时被清)
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run return 0

# 档位快照
scoreboard players set #mv_ol zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run scoreboard players set #mv_ol zx.meta 1

# ② 基础回魔: 20 / 80(走前置包接口, 会夹到上限)
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
execute if score #mv_ol zx.meta matches 0 run data modify storage manacore:in arg set value {uuid:"",value:20.0}
execute if score #mv_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ③ 迅捷Ⅱ + 抗性: 基础 3 秒Ⅰ / 超限 8 秒Ⅱ
execute if score #mv_ol zx.meta matches 0 run effect give @s minecraft:speed 3 1 true
execute if score #mv_ol zx.meta matches 0 run effect give @s minecraft:resistance 3 0 true
execute if score #mv_ol zx.meta matches 1 run effect give @s minecraft:speed 8 1 true
execute if score #mv_ol zx.meta matches 1 run effect give @s minecraft:resistance 8 1 true

# ④ 按种类给额外奖励（b_* 内部自己按档取值）
execute if entity @s[tag=zx.mv.liuhuo] run function fallendream:equipment/armor/mottle_vein/b_liuhuo
execute if entity @s[tag=zx.mv.yehuo] run tag @s add zx.mv_ny
execute if entity @s[tag=zx.mv.shixin] run function fallendream:equipment/armor/mottle_vein/b_shixin
execute if entity @s[tag=zx.mv.yuanhai] run function fallendream:equipment/armor/mottle_vein/b_yuanhai
execute if entity @s[tag=zx.mv.dream] run tag @s add zx.mv_ts

# ⑤ ★ 超限: 本次消耗的标签超过 4 种 -> 每秒给 8 格内随机 3 个生物附随机标签, 持续 4 秒
#   剩下的每秒结算在 lib/second -> rain_tick
execute if score #mv_ol zx.meta matches 1 if score @s zx.mv_n matches 5.. run scoreboard players set @s zx.mv_rain 4

# ⑥ 清空记录, 关闭窗口(下一次消费会重新开一个窗口)
# 第二层在同一批次重复兑现；五种雨奖励仍按种类计数。
execute if entity @s[tag=zx.mv2.liuhuo] run function fallendream:equipment/armor/mottle_vein/b_liuhuo
execute if entity @s[tag=zx.mv2.shixin] run function fallendream:equipment/armor/mottle_vein/b_shixin
execute if entity @s[tag=zx.mv2.yuanhai] run function fallendream:equipment/armor/mottle_vein/b_yuanhai
execute if entity @s[tag=zx.mv2.yehuo] run tag @s add zx.mv_ny2
execute if entity @s[tag=zx.mv2.dream] run tag @s add zx.mv_ts2

tag @s remove zx.mv.liuhuo
tag @s remove zx.mv.yehuo
tag @s remove zx.mv.shixin
tag @s remove zx.mv.yuanhai
tag @s remove zx.mv.dream
tag @s remove zx.mv2.liuhuo
tag @s remove zx.mv2.yehuo
tag @s remove zx.mv2.shixin
tag @s remove zx.mv2.yuanhai
tag @s remove zx.mv2.dream
scoreboard players set @s zx.mv_n 0
scoreboard players set @s zx.mv_end 0

# ⑦ 表现: 三条纹路合拢
execute at @s run particle minecraft:dust{color:[0.42,0.1,0.62],scale:1.6} ~ ~1 ~ 0.5 0.6 0.5 0.03 20 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.7 1.2
