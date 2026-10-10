# ============================================================
# sweetdream:equipment/sword/shadow_blade/kill_other —— 【超限·影刃】分支 B
# ------------------------------------------------------------
# 【文案】若手持的是其他武器则减少手持武器 15 秒主动技能冷却时间。
# 【怎么知道"手持武器的技能名"】本包每件装备的 custom_data.zx[0] 就是它自己的 id,
#   而技能名统一是 `sweetdream:<id>` —— 取出来拼一下交给框架即可。
#   ★ 字符串拼接只能靠宏(data modify 不能把两个串接起来), 所以拆一层宏函数。
#   ★ 主手那格在 SelectedItem(不在 equipment.mainhand, 见 RULES「1.21.5 槽位大改」)。
#   ★ 拿的是原版武器/空手(zx[0] 不存在)就什么都不做 —— 免得把空 skill 写进框架。
# ============================================================

execute unless data entity @s SelectedItem.components."minecraft:custom_data".zx[0] run return 0

data modify storage zx:work sb set value {id:""}
data modify storage zx:work sb.id set from entity @s SelectedItem.components."minecraft:custom_data".zx[0]
function sweetdream:equipment/sword/shadow_blade/kill_other_go with storage zx:work sb
