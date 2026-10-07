# ============================================================
# sweetdream:equipment/staff/begonia/vortex_make —— 在"这只生物"处生成一个漩涡
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑧ 步: execute as @e[tag=zx.bg_src] at @s run ...
# 【执行者/位置】被选中的「渊海」生物(位置 = 它脚下)
# 【参数来源】zx:work bgv = {uuid,u0..u3}(释放者), 直接整份抄进 marker 的 data.zx.bg
#   ★ 这里不用宏: `set from storage` 会把值拷过去, 不需要拼字符串。
# 【寿命】zx.bg_t = 8(秒), 由 begonia/second -> vortex_tick 每秒 -1, 到 0 收尾。
# ============================================================

summon minecraft:marker ~ ~ ~ {Tags:["zx.bg_vtx","zx.bg_new"],data:{}}
data modify entity @n[limit=1,tag=zx.bg_new] data.zx.bg set from storage zx:work bgv
scoreboard players set @n[limit=1,tag=zx.bg_new] zx.bg_t 8
tag @n[limit=1,tag=zx.bg_new] remove zx.bg_new
