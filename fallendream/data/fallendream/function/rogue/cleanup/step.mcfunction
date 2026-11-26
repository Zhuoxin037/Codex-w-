execute if score #rv_clean_i zx.meta matches 0 run fill -16 79 -16 -9 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 1 run fill -8 79 -16 -1 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 2 run fill 0 79 -16 7 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 3 run fill 8 79 -16 15 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 4 run fill 16 79 -16 23 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 5 run fill 24 79 -16 31 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 6 run fill 32 79 -16 39 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 7 run fill 40 79 -16 47 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 8 run fill 48 79 -16 55 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 9 run fill 56 79 -16 63 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 10 run fill 64 79 -16 71 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 11 run fill 72 79 -16 79 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 12 run fill 80 79 -16 87 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 13 run fill 88 79 -16 95 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 14 run fill 96 79 -16 103 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 15 run fill 104 79 -16 111 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 16 run fill 112 79 -16 119 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 17 run fill 120 79 -16 127 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 18 run fill 128 79 -16 135 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 19 run fill 136 79 -16 143 95 144 minecraft:air
execute if score #rv_clean_i zx.meta matches 20 run fill 144 79 -16 144 95 144 minecraft:air
scoreboard players add #rv_clean_i zx.meta 1
execute if score #rv_clean_i zx.meta matches 21.. run function fallendream:rogue/cleanup/finish
