# ============================================================
# sweetdream:equipment/axe/death_bell/dom_one —— 清「白昼梦」+ 两次钟声
# ------------------------------------------------------------
# 【谁调用它】cast ⑧   【执行者】**施法者本人**   【位置】他所在处
# 【目标】zx.dbl_src = 本轮命中者里就近挑中的那一个带「白昼梦」的
# 【★ 身份绝不能换 ★】消耗走统一入口 lib/mark_consume; 余烬只认 **@s**(消耗者),
#   by 默认也是 @s。一旦 `as <目标>`, 余烬就认错人。目标只写成选择器字符串。
# 【★ 只有真的摘掉才敲钟 ★】
#   · ok   = 它身上真有白昼梦(防"选完到消耗之间被别的效果摘掉")。
#   · done = 穿「永恒」时把标签**补回来**了 = 没消耗掉 -> 不该敲钟。
# 【钟声目标】"其 4 格内最多 5 个**其他**生物" —— 以被清白昼梦的那只为中心,
#   排除它自己, 就近取 5。名单**钉一次**(zx.dbl_bell)给两次钟声共用:
#   原文是"释放两次钟声", 不是"每敲一次重新挑一批"。
# 【达标判定 —— 用户 2026-10-17 拍板】**两次钟声的命中次数合计 ≥5**:
#   同一只被两次钟声都打到算 2 次。计数在 bell_once 里逐目标 +1(#dbl_n)。
# ============================================================

# ① 消耗它的「白昼梦」(执行者/身份仍是施法者本人)
data modify storage zx:work a set value {target:"@e[tag=zx.dbl_src,distance=0..,limit=1]",mark:"dream"}
function sweetdream:lib/mark_consume

# ② 它身上本来就没有 -> 收工
execute unless data storage zx:work mc{ok:1b} run return 0
# ③ 被「永恒」补回来了 = 没真的消耗 -> 不敲钟
execute if data storage zx:work mc{done:1b} run return 0

# ④ 本轮钟声命中计数清零(用 zx.meta 上的假玩家, 同 #db_ys 那类一次性计算值)
scoreboard players set #dbl_n zx.meta 0

# ⑤ 圈出"它 4 格内最多 5 个其他生物"(排除它自己, 就近)
tag @e[tag=zx.dbl_bell,distance=0..] remove zx.dbl_bell
execute at @e[tag=zx.dbl_src,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..4,tag=!zx.dbl_src,sort=nearest,limit=5] add zx.dbl_bell
execute unless entity @e[tag=zx.dbl_bell,distance=0..,limit=1] run return 0

# ⑥ 钟声伤害 = 自身最大魔力值 ×0.08
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work dbl.dmg2 set from storage manacore:out r.damage

# ⑦⑧ 两次钟声(名单已钉死, 同一批人吃两次)
#   ★ 两声之间要**重新筛名单**: 第一声可能已经把人打死、或把人震出 4 格;
#     死人和跑出范围的不该再吃第二声(也会让 #dbl_n 多算, 影响达标判定)。
function sweetdream:equipment/axe/death_bell/bell_once
execute as @e[tag=zx.dbl_bell,distance=0..] if data entity @s {Health:0.0f} run tag @s remove zx.dbl_bell
execute at @e[tag=zx.dbl_src,distance=0..,limit=1] run tag @e[tag=zx.dbl_bell,distance=4.01..] remove zx.dbl_bell
function sweetdream:equipment/axe/death_bell/bell_once

# ⑨ 达标: 命中次数合计 ≥5 -> 返 80 魔力 + 冷却 -10 秒
execute if score #dbl_n zx.meta matches 5.. run data modify storage manacore:in arg set value {uuid:"",value:80.0}
execute if score #dbl_n zx.meta matches 5.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #dbl_n zx.meta matches 5.. run function manacore:api/mana/add

execute if score #dbl_n zx.meta matches 5.. run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:death_bell",ticks:200}
execute if score #dbl_n zx.meta matches 5.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #dbl_n zx.meta matches 5.. run function manacore:api/cooldown/reduce

execute if score #dbl_n zx.meta matches 5.. run tellraw @s [{"text":"钟声回响（返还 80 魔力 / 冷却 -10 秒）","color":"aqua"}]

# ⑩ 收尾
tag @e[tag=zx.dbl_bell,distance=0..] remove zx.dbl_bell
