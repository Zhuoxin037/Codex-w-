# 参数: manacore:work.a {uuid,...}
function manacore:internal/damage/calc with storage manacore:work a
execute if data storage manacore:work a.target run data modify storage manacore:work a.damage set from storage manacore:out r.damage
execute if data storage manacore:work a.target run function manacore:internal/damage/apply with storage manacore:work a
