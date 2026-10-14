# 通过原框架接口读取真实当前魔力；不扣魔力，也不改变最大魔力。
$data modify storage manacore:in arg set value {uuid:"$(uu)"}
function manacore:api/mana/get
scoreboard players set @s zx.el_mana 0
execute store result score @s zx.el_mana run data get storage manacore:out r.value 1
