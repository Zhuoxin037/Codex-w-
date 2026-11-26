advancement revoke @s only fallendream:equipment/sword/mirrored_scene
execute unless score @s zx.job matches 4 run return fail
function fallendream:profession/twin/record
data remove storage zx:work s2_scene_origin
execute if score @s zx.j_form matches 0 if data storage zx:work jt_record.twin.pos run data modify storage zx:work s2_scene_origin set from storage zx:work jt_record.twin
execute if score @s zx.j_form matches 1 if data storage zx:work jt_record.body.pos run data modify storage zx:work s2_scene_origin set from storage zx:work jt_record.body
execute unless data storage zx:work s2_scene_origin.pos run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:mirrored_scene",mana:140.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:140.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:mirrored_scene",cooldown_seconds:28.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
execute anchored eyes positioned ^ ^ ^ run function fallendream:equipment/sword/mirrored_scene/aim_end
scoreboard players set #s2_scene_step zx.meta 0
execute anchored eyes positioned ^ ^ ^ run function fallendream:equipment/sword/mirrored_scene/aim
execute if score @s zx.j_form matches 0 run function fallendream:equipment/sword/mirrored_scene/calc_body
execute if score @s zx.j_form matches 1 run function fallendream:equipment/sword/mirrored_scene/calc_twin
data modify storage zx:work s2_scene_origin.damage set from storage manacore:out r.damage
data modify storage zx:work s2_scene_origin.s2_b_damage set value {n:0,d:1}
data modify storage zx:work s2_scene_origin.s2_b_damage set from storage manacore:out r.s2_b_damage
function fallendream:lib/uuid
data modify storage zx:work s2_scene_origin.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_scene_origin.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_scene_origin.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_scene_origin.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_scene_origin.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:equipment/sword/mirrored_scene/near_aim
function fallendream:equipment/sword/mirrored_scene/create with storage zx:work s2_scene_origin
