$data remove storage zx:rogue p."$(uuid)".q[{components:{"minecraft:custom_data":{zx:["$(kind)"]}}}]
$execute if data storage zx:rogue p."$(uuid)".prep_off{components:{"minecraft:custom_data":{zx:["$(kind)"]}}} run data remove storage zx:rogue p."$(uuid)".prep_off
