# ============================================================
# sweetdream:equipment/staff/final_revelation/auto_light —— 「圣光」满 10 层自动释放
# ------------------------------------------------------------
# 【谁调用它】attack ⑤ —— 每次普攻 +1 层, 到 10 层就调这里。
# 【用户定稿(2026-10-06 晚)】自动释放**免魔力、不进冷却** ——
#   普攻是玩家控制不了的, 攒满还要被罚 500 蓝 / 30 秒冷却不合理。
# 【怎么区分"自动释放"和"手动释放"】zx.fr_auto: 0 = 手动(结束时有 ×0.2 收尾),
#   1 = 自动(没有收尾伤害)。见 end / end_blast。
# 【正在放光柱时攒满怎么办】停在 10 层不释放(不浪费圣光) ——
#   光柱结束后玩家再普攻一下, 层数仍是 10(`matches 10..` 成立)就会补放。
# ============================================================

# ① 已有光柱在释放 -> 停在 10 层, 等它结束后再说
execute if score @s zx.fr_t matches 1.. run scoreboard players set @s zx.fr_light 10
execute if score @s zx.fr_t matches 1.. run return 0

# ② 清空「圣光」
scoreboard players set @s zx.fr_light 0

# ③ 点火: 标记"这次是自动释放"(结束时没有 ×0.2 收尾伤害)
scoreboard players set @s zx.fr_auto 1
scoreboard players set @s zx.fr_t 6

# ④ 表现(和手动释放同一套; 光柱本身的粒子由 tick 每秒铺)
execute at @s anchored eyes run particle minecraft:end_rod ^ ^ ^1 0.25 0.25 0.25 0.0 24 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.6
execute at @s run playsound minecraft:block.respawn_anchor.set_spawn player @a ~ ~ ~ 0.7 1.3
tellraw @s [{"text":"「圣光」已满 10 层 —— 终末天启自动释放","color":"gold"}]
