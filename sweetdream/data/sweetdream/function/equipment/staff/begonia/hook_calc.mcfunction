# ============================================================
# sweetdream:equipment/staff/begonia/hook_calc —— 漩涡增强: mm 通道 +20%(加算)
# ------------------------------------------------------------
# @calc: add     ← 加算型: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply 之前
#   (顺序由 check 规则 dmgord 盯着)。
# 【技能原文(超限·海棠)】"若有生物在漩涡范围内死亡，则对该漩涡进行增强：
#   在漩涡内使用关于最大魔力值的技能时造成的伤害提升 20%。"
# 【三个判据逐个落实】
#   ① "关于最大魔力值的技能" = 本次结算走 mm 通道(读快照 zx:work ch.max_mana_mul,
#      与 lib/mm_add/take 同一口径) —— 平A / 攻击力类 / 当前魔力类都吃不到;
#   ② "在漩涡内" = 施法者站在某个**增强了**的漩涡 6 格内(6 = 超限漩涡的半径,
#      漩涡本体 = item_display, tag zx.bg_vtx, 增强后 tag zx.bg_emp);
#   ③ "对该漩涡" = 归属校验: 漩涡 data.zx.bg.u0..u3 必须是**这个玩家**的 UUID
#      —— 别人增强的漩涡不能给你加成(多玩家不串)。
# 【写入哪个池】mm 通道 +20(加算, 和共振/漫步冥河/mm_add 同一条流水线)。
#   ★ 不消费(与 mm_add 不同): 增强跟着漩涡寿命走, 不是"下一次"口径。
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / marker 在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 本次结算走的是 mm 通道吗(没走就不用查漩涡了)
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.max_mana_mul 100
execute unless score #u zx.meta matches 1.. run return 0

# ② + ③ 施法者 UUID 四 int 备进宏节点(归属校验只能拼进选择器)
data modify storage zx:work bgc set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work bgc.u0 set from entity @s UUID[0]
data modify storage zx:work bgc.u1 set from entity @s UUID[1]
data modify storage zx:work bgc.u2 set from entity @s UUID[2]
data modify storage zx:work bgc.u3 set from entity @s UUID[3]

# 6 格内有没有"我自己增强过的漩涡"(增强 = tag zx.bg_emp, 归属 = data.zx.bg.u0..u3)
$execute if entity @e[tag=zx.bg_vtx,tag=zx.bg_emp,nbt={data:{zx:{bg:{ol:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},distance=..6,limit=1] run function sweetdream:equipment/staff/begonia/emp_put
