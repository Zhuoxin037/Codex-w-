# ============================================================
# sweetdream:equipment/sword/remelt/end —— 熔解状态收尾
# ============================================================
scoreboard players set @s zx.rm_on 0
tellraw @s [{"text":"熔解结束。","color":"gray","italic":true}]
