# 潮涌，潮枯：自身每秒流失 2% 生命值。
# 【宏参数】zx:work se.v = 伤害点(double)
# 【★ 真伤、且不改玩家 NBT ★】同 肉盾/牺牲：玩家 Health 写不了，走 /damage。
$damage @s $(v) fallendream:parallel_true_damage
