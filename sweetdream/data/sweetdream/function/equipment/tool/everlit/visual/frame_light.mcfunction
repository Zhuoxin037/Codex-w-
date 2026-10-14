scoreboard players operation #el_frame zx.meta = @s zx.el_time
scoreboard players add #el_frame zx.meta 300
scoreboard players operation #el_dim_back zx.meta = @s zx.el_time
scoreboard players operation #el_dim_back zx.meta /= #el_2 zx.meta
scoreboard players set #el_dim zx.meta 8
scoreboard players operation #el_dim zx.meta -= #el_dim_back zx.meta
