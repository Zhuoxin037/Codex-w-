# ============================================================
# sweetdream:equipment/bow/arc/discharge —— 「电弧」配对放电(主流程)
# ------------------------------------------------------------
# 【谁调用它】hook_victim 第 ⑤ 步(已确认 6 格内有另一只带电刺的生物)
# 【执行者/位置】受害者(@s = 本只, 调用方已 at @s)
# 【伙伴】带 zx.arc_partner 的那只(同一维度, 由 hook_victim 的 6 格扫描选出)
# 【流程】
#   A 拉电线: 从本只出发、朝伙伴走一条"1 格宽"的走廊, 沿途生物打 zx.arc_on
#   B 结算  : 以**射手**身份查面板 -> 基础攻击力 ×2 + 当前魔力 ×0.03 -> 打给 zx.arc_on
#   C 表现  : 音效 + 两端火花
#   D 清场  : 移除双方的「电刺」 + 摘掉本流程的所有临时标签
# 【★ 为什么走廊不用 at 逐点扫、而是"朝伙伴走"】见 wire: 沿朝向递归 positioned
#   前进, 朝向继承所以是直线; 终点用"距伙伴 ≤0.3"判停。
# ============================================================

# ---- A. 拉电线(走廊) ----
# 步数上限用的全局计数, 每轮必须归零(同 cold_crow/step 的 #cc_step 写法)
scoreboard players set #arc_st zx.meta 0
tag @e[tag=zx.arc_on,distance=0..] remove zx.arc_on

# 两端先各自落位(走廊起点就是本只; 伙伴也先标上, 免得步进刚好停在 0.6 边界外)
tag @s add zx.arc_on
tag @e[tag=zx.arc_partner,distance=0..] add zx.arc_on

# 从本只出发, 面朝伙伴(脚), 由 wire 递归步进到伙伴处
execute at @s facing entity @e[tag=zx.arc_partner,distance=0..,limit=1] feet run function sweetdream:equipment/bow/arc/wire

# ---- B. 结算伤害(以射手身份切过去: 归属 + 面板口径都要用射手) ----
execute as @a[tag=zx.arc_pl,limit=1] at @s run function sweetdream:equipment/bow/arc/damage_go

# ---- C. 表现 ----
playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.8 1.4
particle minecraft:electric_spark ~ ~1.0 ~ 0.6 0.8 0.6 0.06 12 normal
execute at @e[tag=zx.arc_partner,distance=0..,limit=1] run particle minecraft:electric_spark ~ ~1.0 ~ 0.6 0.8 0.6 0.06 12 normal

# ---- D. 移除双方的「电刺」(文案: "之后移除「电刺」") ----
tag @s remove zx.status.dianci
tag @e[tag=zx.arc_partner,distance=0..] remove zx.status.dianci

# ---- E. 摘掉本流程的临时标签 ----
tag @e[tag=zx.arc_on,distance=0..] remove zx.arc_on
tag @s remove zx.arc_v
tag @e[tag=zx.arc_partner,distance=0..] remove zx.arc_partner
