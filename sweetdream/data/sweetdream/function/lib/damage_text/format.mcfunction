$data modify storage zx:work dt_text set value {value:"$(whole).$(tens)$(ones)"}
$execute if score #dt_dec zx.meta matches 0 run data modify storage zx:work dt_text.value set value "$(whole)"
execute anchored eyes positioned ^ ^ ^ positioned ~ ~0.25 ~ summon minecraft:text_display run function sweetdream:lib/damage_text/init with storage zx:work dt_text
