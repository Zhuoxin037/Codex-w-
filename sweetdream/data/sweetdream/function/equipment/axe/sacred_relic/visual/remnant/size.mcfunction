# 固定尺寸放大50%，只更新载体TRS与裁剪边界，不改marker、帧或标签flags。
data modify entity @s transformation set value {translation:[0.0f,0.525f,0.0f],scale:[1.05f,1.05f,1.05f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}
data modify entity @s width set value 2.1f
data modify entity @s height set value 2.25f
