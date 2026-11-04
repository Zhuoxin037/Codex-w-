# 清醒与幻觉：把"每秒自伤 / 主动那一下最大生命 ×0.5"统一投出去。
# 【宏参数】zx:work li.v = 伤害点(double)
# 【为什么单独一个文件】玩家 NBT 不可写（原版禁止），只能用 /damage + 宏传值；
#   宏参数必须是"带 $ 的行"，和调用方混在一个文件里会互相牵连。
$damage @s $(v) sweetdream:parallel_true_damage
