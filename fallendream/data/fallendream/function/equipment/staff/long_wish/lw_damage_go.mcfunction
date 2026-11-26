# @s = 领域主人(lib/find_by 反查得到)。目标用 zx.lw_cons 标签, 不依赖已被摘掉的原选择器。
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.lw_cons]",damage:0.0,read:"manacore",uncapped:1b}
function fallendream:internal/attack/api_skill
