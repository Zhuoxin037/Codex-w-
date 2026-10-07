# ============================================================
# sweetdream:equipment/staff/sail/whirl_spawn —— 在"被记录的生物"处放一个旋风
# ------------------------------------------------------------
# 【谁调用它】sail/skill 第 ⑩ 步: execute at @e[tag=zx.sl_found] run ...
# 【执行者】施法玩家; 【位置】被记录的生物处
# 【参数来源】zx:work sl = {uuid,u0..u3,n,m[]}(释放者 + 属性码列表), 整份抄进 marker。
# 【寿命】zx.sl_t = 15(秒); zx.sl_p = 3(距下一次脉冲的秒数)。
# ============================================================

summon minecraft:marker ~ ~1 ~ {Tags:["zx.sl_vtx","zx.sl_new"],data:{}}
data modify entity @n[limit=1,tag=zx.sl_new] data.zx.sl set from storage zx:work sl
scoreboard players set @n[limit=1,tag=zx.sl_new] zx.sl_t 15
scoreboard players set @n[limit=1,tag=zx.sl_new] zx.sl_p 3
# 表现用的两个初值: zx.sl_a = 当前角度(每刻 +6, 见 whirl_fx);
#   zx.sl_m = 最近一次附着了哪一种属性(0 = 还没附着过 -> 素白风)
scoreboard players set @n[limit=1,tag=zx.sl_new] zx.sl_a 0
scoreboard players set @n[limit=1,tag=zx.sl_new] zx.sl_m 0
tag @n[limit=1,tag=zx.sl_new] remove zx.sl_new
