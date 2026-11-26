# ============================================================
# fallendream:equipment/armor/overflow/hook_heal —— 过量治疗 → 50% 转临时生命
# ------------------------------------------------------------
# 【谁调用它】lib/heal 的第 ⑩ 步之后（那一刻 #heal_pt / #heal_got 都还在）
# 【执行者】被治疗的玩家
# 【★ 过量 = 请求量 − 实得 ★】lib/heal 的 ⑥ 会把目标夹到真实上限，所以
#   #heal_got 是"计划实得"，#heal_pt 是"请求量"，差值就是溢出的部分。
# 【★ 只覆盖 lib/heal 这条链 ★】原版再生/瞬治在满血时本来就不产生治疗量，
#   不会"溢出"；本包的治疗技能全部走 lib/heal ⇒ 覆盖面够。
# 【★ 单位都是整点 ★】lib/heal 的入参与出参都是整点，/2 向下取整。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run return 0

scoreboard players set #ovf zx.meta 0
scoreboard players operation #ovf zx.meta = #heal_pt zx.meta
scoreboard players operation #ovf zx.meta -= #heal_got zx.meta
execute if score #ovf zx.meta matches ..0 run return 0

# 分档：基础 50% / 超限 100%（文案"全部转化为临时生命值"）
scoreboard players set #ovf_ol zx.meta 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"],ol:"overflow"}] run scoreboard players set #ovf_ol zx.meta 1
execute if score #ovf_ol zx.meta matches 0 run scoreboard players set #ovf_2 zx.meta 2
execute if score #ovf_ol zx.meta matches 0 run scoreboard players operation #ovf zx.meta /= #ovf_2 zx.meta
execute if score #ovf zx.meta matches ..0 run return 0

# ---- 超限：上限改成最大生命 ×3，且必须走 lib/thp/set 而不是 add ----
#   ★ lib/thp/add 内部把上限夹到 ×2（蓄意/溢流的老口径），这里要 ×3，
#     只能自己算好"已有 + 溢出"再调 set（set 本身不夹，是 add 夹的）。
execute unless score #ovf_ol zx.meta matches 1 run function fallendream:lib/thp/add
execute unless score #ovf_ol zx.meta matches 1 run return 0
scoreboard players add @s zx.thp 0
scoreboard players operation #ovf_new zx.meta = @s zx.thp
scoreboard players operation #ovf_new zx.meta += #ovf zx.meta
execute store result score #ovf_mh zx.meta run attribute @s minecraft:max_health get
scoreboard players set #ovf_3 zx.meta 3
scoreboard players operation #ovf_mh zx.meta *= #ovf_3 zx.meta
execute if score #ovf_new zx.meta > #ovf_mh zx.meta run scoreboard players operation #ovf_new zx.meta = #ovf_mh zx.meta
scoreboard players operation #thp_v zx.meta = #ovf_new zx.meta
function fallendream:lib/thp/set
