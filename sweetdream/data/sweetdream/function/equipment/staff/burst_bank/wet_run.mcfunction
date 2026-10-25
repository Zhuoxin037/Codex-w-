# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_run —— 决堤超限：水流每秒的宏执行层
# ------------------------------------------------------------
# 【谁调用】wet_own（施法者侧，每秒一次），`with storage zx:work bbw`
# 【宏参数】bbw {uuid,dmg,u0..u3}
# 【执行者】施法者本人（@s 不变）
# 【③ 迅捷Ⅰ】"自身在水流上时获得常态的迅捷Ⅰ" —— 每秒续 1 秒，离开水面自然到期；
#   用 $(uuid) 拼 tag 只认**自己的**水流（别人放的水不给自己加速）。
# 【④ 逐点结算】交给 wet_all（再 as 到每个 marker 上），dmg=0 时整段跳过。
# ============================================================
$execute if entity @e[type=marker,tag=zx.bb_wet_$(uuid),distance=..1.5] run effect give @s minecraft:speed 1 0 true
execute if score @s zx.bb_wd matches 1.. run function sweetdream:equipment/staff/burst_bank/wet_all with storage zx:work bbw
