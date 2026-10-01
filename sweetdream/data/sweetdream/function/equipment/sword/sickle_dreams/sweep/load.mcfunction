# reload 取消在线玩家的旧动作；离线玩家回服时由 leave_game 差值取消。
scoreboard objectives add zx.sd_t dummy
scoreboard objectives add zx.sd_id dummy
scoreboard objectives add zx.sd_leave minecraft.custom:minecraft.leave_game
scoreboard players add #sweep_id zx.meta 0
execute as @a[tag=zx.sd_sweep] at @s run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
