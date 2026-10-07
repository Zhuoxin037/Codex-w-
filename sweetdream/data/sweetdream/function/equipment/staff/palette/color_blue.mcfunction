# ============================================================
# sweetdream:equipment/staff/palette/color_blue —— 蓝色效果: 回魔 + 冷却缩减
# ------------------------------------------------------------
# 【谁调用它】color_hit 第 ⑤ 步(有蓝才调); 【执行者】色彩 marker
# 【文案】每有一个蓝色则在“色彩”对生物造成伤害后回复自身 150 点魔力值
#   并使技能冷却时间 -5 秒。
# 【口径】按蓝的**个数**乘算: +150×蓝数 魔力, -5×蓝数 秒冷却。
# 【-5 秒冷却减的是哪个技能】调色盘自己的主动技能(sweetdream:palette)。
#   只有它正在冷却时才真的减(api/cooldown/reduce 自带这个判断)。
# ============================================================

# ① 回魔: 150 × 蓝数
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from entity @s data.zx.pal.uuid
execute store result storage manacore:in arg.value double 150 run scoreboard players get @s zx.pal_blu
function manacore:api/mana/add

# ② 冷却 -5 × 蓝数 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:palette",seconds:0.0}
data modify storage manacore:in arg.uuid set from entity @s data.zx.pal.uuid
execute store result storage manacore:in arg.seconds double 5 run scoreboard players get @s zx.pal_blu
function manacore:api/cooldown/reduce
