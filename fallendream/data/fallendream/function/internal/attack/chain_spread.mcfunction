$data modify storage zx:combat chains."$(chain)".spread set value 1b
$execute in $(dimension) positioned $(x) $(y) $(z) run function fallendream:internal/attack/chain_spread_go {chain:$(chain),main:"$(main)",primary:$(primary),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
