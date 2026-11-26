$execute unless entity $(vx_uuid) run return 0

# ③ 【兑现】攒满了吗 + 目标未带白昼梦吗 -> 扣 30 魔力并附加
$execute if score @s zx.ms_arm matches 1 unless data entity $(vx_uuid) {Tags:["zx.status.dream"]} run function fallendream:equipment/armor/mirror_sleep/apply

# ④ 【计数】攻击次数 +1；满 3 则归零并武装
scoreboard players add @s zx.ms_cnt 1
execute if score @s zx.ms_cnt matches 3.. run scoreboard players set @s zx.ms_cnt 0
execute if score @s zx.ms_cnt matches 0 run scoreboard players set @s zx.ms_arm 1

# ⑤ 收尾
$tag $(vx_uuid) remove zx.victim
