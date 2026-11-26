# ============================================================
# fallendream:equipment/armor/eagle_hat/orb_gain —— 超限·鹰羽帽：获得法球回 1% 魔力
# ------------------------------------------------------------
# 【执行者】魔导士玩家
# 【文案】自身获得法球和消耗法球时自身恢复 1 % 魔力值。
# 【★ 1% 是"当前最大魔力"还是"基础"? 取最大魔力 ★】与包内同款(借火 2% / 杂纹 20 点)
#   一致, 都是按上限的百分比算, 这样魔力上限堆高时这件仍然有用。
# 【定点】api/stats/get 出 r.value(点), ×1000 得定点; 再 ÷100 = 1%。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #eh_m zx.meta 0
execute store result score #eh_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #eh_m zx.meta matches 1.. run return 0

scoreboard players set #eh_100 zx.meta 100
scoreboard players operation #eh_m zx.meta /= #eh_100 zx.meta
execute unless score #eh_m zx.meta matches 1.. run scoreboard players set #eh_m zx.meta 1

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #eh_m zx.meta
function manacore:api/mana/add
