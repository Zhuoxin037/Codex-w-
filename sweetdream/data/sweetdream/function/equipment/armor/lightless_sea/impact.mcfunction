# ============================================================
# sweetdream:equipment/armor/lightless_sea/impact —— 虚弱Ⅲ + 回魔(每秒结算)
# ------------------------------------------------------------
# 【谁调用它】passive 第 ⑧ 步(执行者 = 玩家; 已判穿着 + 有受影响目标)
# 【文案】使其 3 格内的全部生物获得 2 秒虚弱Ⅲ, 且每影响一个生物都会为
#   自身回复 5 魔力值。
# 【去重】zx.ls_hit 已在 passive 里按"所有源生物 3 格圈的并集"去重过。
# ============================================================

# ① 虚弱Ⅲ(amp 2) 2 秒, 全部受影响生物
execute as @e[tag=zx.ls_hit] run effect give @s minecraft:weakness 2 2 true

# ② 回魔: n × 5(即时收益, 不占账本)
scoreboard players operation #n5 zx.meta = #n zx.meta
scoreboard players operation #n5 zx.meta *= #5 zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #n5 zx.meta
function manacore:api/mana/add

# ③ 表现
particle minecraft:bubble_pop ~ ~1 ~ 1.2 0.8 1.2 0.02 20 normal
