$bossbar remove sweetdream:husk_$(id)
$data remove storage sweetdream:husk bars[{id:$(id)}]
$data remove storage sweetdream:husk targets."$(id)"
$data remove storage sweetdream:husk reflects."$(id)"
$data remove storage sweetdream:husk queues."$(id)"

$function sweetdream:boss/husk/leap/clean {id:$(id)}
