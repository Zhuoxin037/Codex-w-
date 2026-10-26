scoreboard players set #jmod_b_old zx.meta -1
scoreboard players set #jmod_s_old zx.meta -1
scoreboard players operation #jmod_b_old zx.meta = @s zx.j_book_t
scoreboard players operation #jmod_s_old zx.meta = @s zx.j_sor_t
scoreboard players set @s zx.j_book_t -1
scoreboard players set @s zx.j_sor_t -1
$execute if score @s $(book_obj) matches 1 run scoreboard players operation @s zx.j_book_t = #now manacore.meta
$execute if score @s $(sor_obj) matches 1 run scoreboard players operation @s zx.j_sor_t = #now manacore.meta
