$data modify storage zx:combat chains."$(chain)" set value {total:0,primary:0,pending:0,closed:0b,spread:0b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),chain:$(chain)}
$data modify storage zx:combat chains."$(chain)".main set value "$(vx_uuid)"
$execute as $(vx_uuid) run function fallendream:internal/attack/chain_center {chain:$(chain)}
