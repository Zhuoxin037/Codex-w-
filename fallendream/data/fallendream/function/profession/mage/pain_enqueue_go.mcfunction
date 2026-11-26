$execute unless data storage zx:jobs p."$(uuid)".pains run data modify storage zx:jobs p."$(uuid)".pains set value []
data modify storage zx:work jp_new set value {end:0,no_self:0,book:0,sor:0}
$data modify storage zx:work jp_new.no_self set value $(no_self)
scoreboard players operation #jp_due zx.meta = #now manacore.meta
scoreboard players add #jp_due zx.meta 160
execute store result storage zx:work jp_new.end int 1 run scoreboard players get #jp_due zx.meta
execute store result storage zx:work jp_new.book int 1 run scoreboard players get @s zx.j_fs_book
execute store result storage zx:work jp_new.sor int 1 run scoreboard players get @s zx.j_fs_sor
$data modify storage zx:jobs p."$(uuid)".pains append from storage zx:work jp_new
scoreboard players add @s zx.j_pain_n 1
