# ============================================================
# sweetdream:equipment/staff/wind_ontheground/aura_hit —— 风声回响的一次伤害
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【伤害】最大魔力 ×0.04 —— 文案是"5 次, 每次 ×0.04", 而这支函数由 aura_tick
#   在 20 秒里**整整调用 5 次**, 所以每次只该给一份 0.04, 合计 0.2。
#   ⚠️ 这里千万别写 0.2: 那是"5 次合并成 1 击"时代的旧值,
#      现在一次 0.2 × 5 次 = 整整 1.0, 会变成文案的 5 倍。
# 【加成】2026-10-07 起"风声奖励"直接进了「最大魔力值技能倍率」通用乘区
#   (zx.mm_add, 由 lib/mm_add/hook_calc 折进 mm 加算池) —— 它是一份**按秒衰减
#   的 buff**, 不是"谁用一次就吃掉"的一次性槽位。本回响走的就是 max_mana_mul 通道,
#   所以在这 20 秒里照样吃得到它。
#   ⚠️ 这与旧行为不同: 旧版回响**故意不碰** wg_bonus(为的是把那份一次性加成
#      留给"下一次真正的技能"), 现在不存在"留给下一次"这回事了 —— 见下面 ②。
# ============================================================

# ① 算基础伤害 = 最大魔力 ×0.04 (一次一份, 共 5 份)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid

# ② 【关于「风声奖励」】旧版这里故意**不**吃那份一次性加成, 理由是"回响是本次
#    施法的收尾, 不是**下一次**技能; 而且它在攒到加成 1 秒后就会把加成吃掉,
#    结果永远轮不到真正的下一次(比如横刀)"。
#    ★ 2026-10-07 用户定稿: 那份"攒着、用一次就删"的槽位整体取消, 加成改成
#      通用乘区上的一份**限时 buff**(zx.mm_add, 20 秒)。既然不再被"吃掉",
#      "留给下一次"这个顾虑就不存在了 —— 回响本身也是以最大魔力值结算的技能,
#      在 buff 生效期内自然吃得到, 这正是"接入通用乘区"的应有之义。
#      (没有额外代码: 走 manacore:api/damage/calc 就会经 lib/mm_add/hook_calc。)

# ★ 超限的伤害乘区: 0.04 -> 0.048 (和 lore 里的数字一一对应)
# ★ zx.mm_hold ★ 用户口径(2026-10-08): 风声回响这 5 跳**既不吃加成也不清零** ——
#   它们紧跟在"刚攒够加成"那次结算之后 1 秒内出现, 任其消费的话玩家永远
#   轮不到真正的下一次技能。加成照样开着(走 hook_calc), 只是不触发清零。
tag @s add zx.mm_hold
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc
tag @s remove zx.mm_hold

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
