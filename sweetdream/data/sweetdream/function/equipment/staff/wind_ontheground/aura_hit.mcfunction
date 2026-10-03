# ============================================================
# sweetdream:equipment/staff/wind_ontheground/aura_hit —— 风声回响的一次伤害
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【伤害】最大魔力 ×0.04 —— 文案是"5 次, 每次 ×0.04", 而这支函数由 aura_tick
#   在 20 秒里**整整调用 5 次**, 所以每次只该给一份 0.04, 合计 0.2。
#   ⚠️ 这里千万别写 0.2: 那是"5 次合并成 1 击"时代的旧值,
#      现在一次 0.2 × 5 次 = 整整 1.0, 会变成文案的 5 倍。
# 【不碰"下一次技能加成"】回响是**本次施法的收尾**, 不是"下一次技能",
#   所以它不吃 wg_bonus —— 见下面 ② 的说明。
# ============================================================

# ① 算基础伤害 = 最大魔力 ×0.04 (一次一份, 共 5 份)
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.04,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value

# ② 【这里故意**不**吃"下一次技能加成"】
#    文案是"为**下一次**自身使用最大魔力值相关的技能伤害提升 1%" ——
#    回响是这一次施法的收尾, 不是"下一次技能"; 而且它在攒到加成 1 秒后
#    就会把加成吃掉, 结果这份加成永远轮不到真正的"下一次"(比如横刀)。
#    所以这里不调用 sweetdream:lib/max_mana_bonus, 让它留着,
#    下次施法时由"风行自己的爆发第 1 轮 / 横刀落点"吃掉。

# ★ 超限的伤害乘区: 0.04 -> 0.048 (和 lore 里的数字一一对应)
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# 记下这一跳算出来的伤害(给 /function sweetdream:debug/wind 排查用)
$data modify storage zx:data wg_dbg."$(uuid)".aura set from storage manacore:out r.damage

# ③ 打自身 5 格内全部生物
# 不写 type: 让 sweetdream:api/damage 用它自己的默认值(可从 zx:config damage_type 改)
# 不写 0.1 那种下限: 施法者是玩家, 本来就被 no_damage 名单排掉了
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",read:"manacore"}
# 记一下这次范围选中了几只(0 = 选择器没选中任何生物), 给 debug/damage 排查用
execute store result score #dbg_sel zx.meta run execute if entity @e[type=!#sweetdream:no_damage,distance=..5]
# 再包一层 at @s: 不管谁调用, 都保证"以施法者本人为中心"结算
execute at @s run function sweetdream:api/damage

# ④ 表现
execute at @s run particle minecraft:small_gust ~ ~1 ~ 4.0 1.2 4.0 0.05 25 normal
execute at @s run playsound minecraft:entity.breeze.idle_air player @a ~ ~ ~ 0.7 1.1
