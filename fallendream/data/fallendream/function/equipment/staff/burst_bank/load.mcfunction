# distance锁定玩家当前维度；跨维度/异常传送由controller看门清理。
$data modify storage zx:work bb set from entity @e[type=marker,tag=zx.bb_ctrl_$(uuid),distance=..64,limit=1] data.bb
