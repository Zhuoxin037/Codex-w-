execute store result score #eu_t zx.meta run data get storage zx:uuid_entity a.value
scoreboard players operation #eu_b0 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b0 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b0 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b0 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b0 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b1 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b1 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b1 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b1 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b1 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b2 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b2 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b2 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b2 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b2 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b3 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b3 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b3 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b3 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b3 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b4 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b4 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b4 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b4 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b4 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b5 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b5 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b5 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b5 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b5 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b6 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b6 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b6 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b6 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_t zx.meta -= #eu_b6 zx.meta
scoreboard players operation #eu_t zx.meta /= #16 manacore.meta
scoreboard players operation #eu_b7 zx.meta = #eu_t zx.meta
scoreboard players operation #eu_b7 zx.meta %= #16 manacore.meta
scoreboard players operation #eu_b7 zx.meta += #16 manacore.meta
scoreboard players operation #eu_b7 zx.meta %= #16 manacore.meta
execute store result storage zx:uuid_entity a.nib0 int 1 run scoreboard players get #eu_b7 zx.meta
execute store result storage zx:uuid_entity a.nib1 int 1 run scoreboard players get #eu_b6 zx.meta
execute store result storage zx:uuid_entity a.nib2 int 1 run scoreboard players get #eu_b5 zx.meta
execute store result storage zx:uuid_entity a.nib3 int 1 run scoreboard players get #eu_b4 zx.meta
execute store result storage zx:uuid_entity a.nib4 int 1 run scoreboard players get #eu_b3 zx.meta
execute store result storage zx:uuid_entity a.nib5 int 1 run scoreboard players get #eu_b2 zx.meta
execute store result storage zx:uuid_entity a.nib6 int 1 run scoreboard players get #eu_b1 zx.meta
execute store result storage zx:uuid_entity a.nib7 int 1 run scoreboard players get #eu_b0 zx.meta
