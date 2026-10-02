# 宏: 按账本里的数值把攻击力修正加回去
# 【为什么单独一个文件】attribute modifier add 的数值必须写在命令行里,
#   没法从计分板直接读 —— 只能用宏把数字拼进命令。
$attribute @s minecraft:attack_damage modifier add sweetdream:eqp_bl_atk $(v) add_value
