# Private synchronous look scan; the six slots share one snapshot, never the last player's data.
data remove storage zx:work es
$data modify storage zx:work es.id set from storage zx:look_scan player.$(p).components."minecraft:custom_data".zx[0]
execute if data storage zx:work es.id run function sweetdream:debug/equip_mark with storage zx:work es
