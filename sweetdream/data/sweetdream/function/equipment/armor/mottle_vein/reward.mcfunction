# ============================================================
# sweetdream:equipment/armor/mottle_vein/reward —— 杂纹: 凑满 3 种后兑现
# ------------------------------------------------------------
# 【谁调用它】consume ③   【执行者】消耗者玩家
# 【技能原文】"累计消耗 3 种后，清空记录，立即恢复 20 点魔力值，并获得 3 秒
#   迅捷Ⅱ和抗性提升Ⅰ；若消耗了「流火」则额外恢复 30 点魔力值；若消耗了「夜火」
#   则下一次技能伤害 +20%；若消耗了「噬心」则自身恢复 15% 最大生命值；若消耗了
#   「渊海」则使自身 3 格内的全部生物击退 1 格；若消耗了「白昼梦」则使自身下一次
#   攻击到的生物时停 1 秒。"
# 【★ 顺序 ★】先给基础奖励, 再按种类给额外奖励, 最后才清记录 ——
#   额外奖励是"按本轮记过的种类"判的, 一清就判不到了。
# 【★ 迅捷Ⅱ / 抗性提升Ⅰ 的 amplifier ★】Ⅰ = 0, Ⅱ = 1(与包内其它 effect 一致)。
#   `true` = 隐藏粒子(不要因为状态栏飘粒子把视野糊住)。
# 【★ 只回 3 秒, 不做每秒扫描 ★】effect 自带倒计时, 到期原版自己摘, 不用记账。
# ============================================================

# ① 基础: 回 20 魔力(走前置包接口, 会夹到上限)
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg set value {uuid:"",value:20.0}
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function manacore:api/mana/add

# ② 基础: 3 秒迅捷Ⅱ + 抗性提升Ⅰ
effect give @s minecraft:speed 3 1 true
effect give @s minecraft:resistance 3 0 true

# ③ 按种类给额外奖励
execute if entity @s[tag=zx.mv.liuhuo] run function sweetdream:equipment/armor/mottle_vein/b_liuhuo
execute if entity @s[tag=zx.mv.yehuo] run tag @s add zx.mv_ny
execute if entity @s[tag=zx.mv.shixin] run function sweetdream:equipment/armor/mottle_vein/b_shixin
execute if entity @s[tag=zx.mv.yuanhai] run function sweetdream:equipment/armor/mottle_vein/b_yuanhai
execute if entity @s[tag=zx.mv.dream] run tag @s add zx.mv_ts

# ④ 清空记录, 关闭窗口(下一次消费会重新开一个 8 秒窗口)
tag @s remove zx.mv.liuhuo
tag @s remove zx.mv.yehuo
tag @s remove zx.mv.shixin
tag @s remove zx.mv.yuanhai
tag @s remove zx.mv.dream
scoreboard players set @s zx.mv_n 0
scoreboard players set @s zx.mv_end 0

# ⑤ 表现: 三条纹路合拢
execute at @s run particle minecraft:dust{color:[0.42,0.1,0.62],scale:1.6} ~ ~1 ~ 0.5 0.6 0.5 0.03 20 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.7 1.2
