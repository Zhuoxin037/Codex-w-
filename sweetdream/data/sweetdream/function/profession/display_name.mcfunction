# Read only player scoreboards; the action bar calls this synchronously per player.
data modify storage zx:work profession_name set value "我"
execute if score @s zx.job matches 1 run data modify storage zx:work profession_name set value "魔导士"
execute if score @s zx.job matches 2 run data modify storage zx:work profession_name set value "狂徒"
execute if score @s zx.job matches 3 run data modify storage zx:work profession_name set value "歌者"
execute if score @s zx.job matches 4 run data modify storage zx:work profession_name set value "“同生”·本我者"
execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run data modify storage zx:work profession_name set value "“同生”·同生体"
