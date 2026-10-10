# ============================================================
# sweetdream:equipment/staff/palette/color_blue —— 蓝色效果: 回魔 + 冷却缩减
# ------------------------------------------------------------
# 【谁调用它】color_hit 第 ⑤ 步(有蓝才调); 【执行者】色彩 item_display
# 【文案】每有一个蓝色则在“色彩”对生物造成伤害后回复自身 150 点魔力值
#   并使技能冷却时间 -5 秒。
# 【口径】按蓝的**个数**乘算: +150×蓝数 魔力, -5×蓝数 秒冷却。
#   "蓝数" = 两个色槽里蓝色的**个数**(0/1/2), **不是"有没有蓝"**:
#   红·蓝 = 1 个蓝 = -5 秒; 蓝·蓝 = 2 个蓝 = -10 秒; 红·黄 = 0 → 不减。
#   (文案就是"每有一个蓝色…-5 秒", 跟红"每有一个红色伤害 +1 倍"、黄"每有一个黄色范围 +8 格"同款句式。)
#   ★★ 2026-10-08 事故订正 ★★
#     用户实测"红蓝/黄蓝 打一下 -10 秒、蓝蓝 -20 秒", 即**所有情况都恰好翻倍**。
#     当时先自查了本文件(数值写的是 5)与命中次数(存档计分项 zx.pal_n = 1, 只打中一只),
#     最后定位到**前置包 manacore**: internal/cooldown/reduce 的两条守卫共用 #amt,
#     被 reduce_sec 中途改写 ⇒ reduce_body 减了两遍 —— 凡是以 {seconds:} 传参的减冷却
#     全都减 2 倍(本例 -5 秒实减 10 秒, 所以"蓝数 1 也 -10")。已在 manacore 侧修好。
#     ⇒ **这里的 5 是对的**, 不要再改成 10 去"迁就"旧现象。
#     自查口径: 施法前看观测镜(palette/look_seg 会显示两个色槽)。
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
