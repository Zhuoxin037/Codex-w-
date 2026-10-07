# ============================================================
# sweetdream:equipment/staff/wind_ontheground/hit_pass —— 一轮范围伤害
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【一轮 = 对每个"中心"各打一圈】文案说每个术阵要造成 3 次伤害,
#   这 3 次**拆成三轮、每秒一轮**(由 second 驱动, zx.wg_burst 计数),
#   而不是同一瞬间打三下 —— 后者会被生物的受伤无敌帧吃掉两次,
#   而且「风声」是按"命中几个生物"叠的, 合并了层数就少算了。
# 【伤害是"最大魔力 ×0.07"】注意是每一轮各算一次(当前魔力不变, 所以数值一样)。
#   2026-10-07 起:"风声 / 忘川彼岸 / 无效"给的加成改成走通用乘区钩子
#   (lib/mm_add/hook_calc), 这里**不再**需要自己调一行 —— 三轮回响也照样吃得到。
# ============================================================

# ① 算这一轮的伤害 = 最大魔力 ×0.07
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.07,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
# ★ 超限的伤害乘区: 0.07 -> 0.084 (和 lore 里的数字一一对应)
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# 记下这一轮算出来的伤害(给 /function sweetdream:debug/wind 排查用)
$data modify storage zx:data wg_dbg."$(uuid)".burst set from storage manacore:out r.damage

# ② 逐个中心打一圈(中心已经不在了会自动跳过)
execute if entity @e[tag=zx.wg_c1,limit=1] at @e[tag=zx.wg_c1,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c2,limit=1] at @e[tag=zx.wg_c2,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c3,limit=1] at @e[tag=zx.wg_c3,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c4,limit=1] at @e[tag=zx.wg_c4,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c5,limit=1] at @e[tag=zx.wg_c5,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c6,limit=1] at @e[tag=zx.wg_c6,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c7,limit=1] at @e[tag=zx.wg_c7,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
execute if entity @e[tag=zx.wg_c8,limit=1] at @e[tag=zx.wg_c8,limit=1] run function sweetdream:equipment/staff/wind_ontheground/hit_center
