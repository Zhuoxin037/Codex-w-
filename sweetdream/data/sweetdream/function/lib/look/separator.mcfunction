scoreboard players operation #ly_was zx.meta = #ly_first zx.meta
scoreboard players set #ly_first zx.meta 0
execute if score #ly_was zx.meta matches 1 run data modify storage zx:look xline append value {text:" ｜ ",color:"dark_gray"}
execute if score #ly_was zx.meta matches 0 run data modify storage zx:look xline append value {text:" · ",color:"dark_gray"}
