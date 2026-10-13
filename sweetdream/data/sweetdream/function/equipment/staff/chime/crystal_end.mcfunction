# ============================================================
# sweetdream:equipment/staff/chime/crystal_end —— 共鸣水晶: 到期/被顶掉 自毁
# ------------------------------------------------------------
# 【谁调用它】
#   · chime/second(寿命到点)
#   · chime/skill(超限: 另一个「共鸣水晶」被召唤出来 -> 旧的立即自毁)
# 【执行者/位置】水晶 marker
# 【原版】表现 + kill(文案没有自毁伤害)。
# 【超限】除了表现与 kill, 还要:
#   "自毁时会吸引一次其 5 格内的全部生物并造成相当于自身当前魔力值 ×0.2 的伤害。"
#   -> ① 先圈出水晶 5 格内的全部生物(zx.ch_e)
#      ② 把它们朝水晶方向拽 2 格("吸引")
#      ③ 反查释放者打 当前魔力 ×0.2(见 crystal_end_set / crystal_end_go)
#   ★ 判据 = 水晶自己的 data.zx.ch.ol(skill 召唤时按 is_ol 写进去的)。
# 【★ "吸引"的实现口径】原文只给了"吸引一次"三个字 —— 这里取最直白的一种:
#   把圈内生物沿"生物 → 水晶"方向 `tp` 2 格(与超限·崩裂的"裂缝锁"同款手法)。
# 【★ 为什么目标要圈成标签而不是让结算处现算】结算处跑在 "as 释放者" 的链上,
#   check 规则 asnoat 不许那里出现 ~ / distance= —— 一律走标签最稳(同 pass_go)。
# ============================================================

# ⓪ 表现(两版相同)
particle minecraft:end_rod ~ ~0.6 ~ 0.3 0.4 0.3 0.06 24 normal
particle minecraft:enchant ~ ~0.6 ~ 0.4 0.4 0.4 0.4 20 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 1.4

# ① 超限: 圈出"自毁时其 5 格内的全部生物"
execute if data entity @s data.zx.ch{ol:1} run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.ch_e

# ② 超限: 吸引 —— 朝水晶方向拽 1.5 格
#   ★ 只拉"1.5 ~ 5 格"的: 已经在贴身距离的再拉会穿到水晶另一侧, 反而更远。
#   ★ 先给"正在自毁的这颗水晶"打个临时标签, 免得 as 换人之后 @s 指不到它
execute if data entity @s data.zx.ch{ol:1} run tag @s add zx.ch_end_me
execute as @e[tag=zx.ch_e,distance=1.5..5] at @s facing entity @e[tag=zx.ch_end_me,distance=0..,limit=1] feet run tp @s ^ ^ ^1.5
tag @e[tag=zx.ch_end_me] remove zx.ch_end_me

# ③ 超限: 自毁伤害(反查释放者, 当前魔力 ×0.2)
data modify storage zx:work che set from entity @s data.zx.ch
function sweetdream:equipment/staff/chime/crystal_end_set with storage zx:work che

# ④ 收尾: 清本轮目标标签 + 自毁
tag @e[tag=zx.ch_e,distance=0..] remove zx.ch_e
kill @s
