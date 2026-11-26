$bossbar remove fallendream:husk_$(id)
$data remove storage fallendream:husk bars[{id:$(id)}]
$data remove storage fallendream:husk targets."$(id)"
$data remove storage fallendream:husk reflects."$(id)"
$data remove storage fallendream:husk queues."$(id)"

$function fallendream:boss/husk/leap/clean {id:$(id)}
