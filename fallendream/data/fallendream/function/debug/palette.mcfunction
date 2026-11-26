# Player-only, read-only palette animation diagnostics.
tellraw @s [{"text":"调色盘 · 施法帧 ","color":"gold"},{"score":{"name":"@s","objective":"zx.pv_age"}},{"text":" · 槽 I "},{"score":{"name":"@s","objective":"zx.pal_c1"}},{"text":" · 槽 II "},{"score":{"name":"@s","objective":"zx.pal_c2"}}]
tellraw @s [{"text":"主手模型 ","color":"gray"},{"nbt":"SelectedItem.components.\"minecraft:custom_model_data\".floats","entity":"@s"}]
tellraw @s [{"text":"副手模型 ","color":"gray"},{"nbt":"equipment.offhand.components.\"minecraft:custom_model_data\".floats","entity":"@s"}]
