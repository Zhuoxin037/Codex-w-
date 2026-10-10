# 原实体仍由术阵的既有清理逻辑管理；这里只更新外观旋转。
data modify entity @s interpolation_duration set value 4
data modify entity @s transformation.left_rotation set from storage zx:work domain_quat
data modify entity @s start_interpolation set value 0
