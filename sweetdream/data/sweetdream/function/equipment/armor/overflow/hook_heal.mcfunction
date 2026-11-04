# ============================================================
# sweetdream:equipment/armor/overflow/hook_heal —— 过量治疗 → 50% 转临时生命
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

# 50%
scoreboard players set #ovf_2 zx.meta 2
scoreboard players operation #ovf zx.meta /= #ovf_2 zx.meta
execute if score #ovf zx.meta matches ..0 run return 0

scoreboard players operation #thp_v zx.meta = #ovf zx.meta
function sweetdream:lib/thp/add
