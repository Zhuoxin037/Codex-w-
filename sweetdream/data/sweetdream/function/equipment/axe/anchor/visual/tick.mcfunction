scoreboard players add @s zx.av_life 1
# ★ 2026-10-23: `nbt={Health:0.0f}` 每刻一次 = 玩家整份 NBT 序列化(≈10 ms)。
#   换成原版 health 计分项 zx.hp_c(引擎自动同步, 纯计分板读取)。
execute if score @s zx.hp_c matches ..0 run return run function sweetdream:equipment/axe/anchor/visual/end
execute if score @s zx.av_life matches 70.. run return run function sweetdream:equipment/axe/anchor/visual/end
function sweetdream:equipment/axe/anchor/visual/dimension
execute unless score @s zx.av_dim = #av_dim zx.meta run return run function sweetdream:equipment/axe/anchor/visual/end
execute if entity @s[tag=test_pending_return] run return 0
execute if score @s zx.av_hand matches 0 store result score #av_slot zx.meta run data get entity @s SelectedItemSlot
execute if score @s zx.av_hand matches 0 unless score @s zx.av_slot = #av_slot zx.meta run return run function sweetdream:equipment/axe/anchor/visual/end
execute if score @s zx.av_hand matches 0 unless items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["anchor"]}] run return run function sweetdream:equipment/axe/anchor/visual/end
execute if score @s zx.av_hand matches 1 unless items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] run return run function sweetdream:equipment/axe/anchor/visual/end
execute if score @s zx.av_phase matches 0..1 run function sweetdream:equipment/axe/anchor/visual/hide
execute if score @s zx.av_phase matches 0 run return 0
execute if score @s zx.av_phase matches 1 run function sweetdream:equipment/axe/anchor/visual/recover
execute if score @s zx.av_phase matches 2 run function sweetdream:equipment/axe/anchor/visual/passive_tick
