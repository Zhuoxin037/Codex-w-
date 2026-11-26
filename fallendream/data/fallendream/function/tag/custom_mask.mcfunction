# 只读专属状态，所有临时量当次覆盖；不得扣时长或更改层数。
scoreboard players set #tag_extra zx.meta 0
scoreboard players set #tag_rb_left zx.meta 61
execute if entity @s[tag=zx.rb_rainbow] run scoreboard players operation #tag_rb_left zx.meta = @s zx.rb_end
execute if entity @s[tag=zx.rb_rainbow] run scoreboard players operation #tag_rb_left zx.meta -= #now manacore.meta
execute if entity @s[tag=zx.status.shenghen] run scoreboard players add #tag_extra zx.meta 1024
execute if entity @s[tag=zx.status.dianci] run scoreboard players add #tag_extra zx.meta 8192
execute if entity @s[tag=zx.rb_rainbow] run scoreboard players add #tag_extra zx.meta 16384
execute if score @s zx.stg matches 1 run scoreboard players add #tag_extra zx.meta 2048
execute if score @s zx.stg matches 2 run scoreboard players add #tag_extra zx.meta 4096
execute if score @s zx.stg matches 3.. run scoreboard players add #tag_extra zx.meta 6144
execute if score @s zx.fcv_st matches 1 run scoreboard players add #tag_extra zx.meta 32768
execute if score @s zx.fcv_st matches 2 run scoreboard players add #tag_extra zx.meta 65536
execute if score @s zx.fcv_st matches 3 run scoreboard players add #tag_extra zx.meta 98304
execute if score @s zx.fcv_st matches 4 run scoreboard players add #tag_extra zx.meta 131072
execute if score @s zx.fcv_st matches 5.. run scoreboard players add #tag_extra zx.meta 163840
execute if entity @s[tag=zx.status.shenghen] if score @s zx.sh_t matches ..3 run scoreboard players add #tag_extra zx.meta 262144
execute if score @s zx.stg matches 1.. if score @s zx.stg_t matches ..3 run scoreboard players add #tag_extra zx.meta 524288
execute if entity @s[tag=zx.rb_rainbow] if score #tag_rb_left zx.meta matches ..60 run scoreboard players add #tag_extra zx.meta 1048576
execute if score @s zx.fcv_st matches 1.. if score @s zx.fcv_t matches ..3 run scoreboard players add #tag_extra zx.meta 2097152
