# ============================================================
# sweetdream:equipment/bow/burst_dawn/cast —— 「爆裂黎明」首发(宏 {uu,u0..u3})
# ------------------------------------------------------------
# 【宏参数】zx:work bd {uu, u0, u1, u2, u3} —— 射手 uuid 文本 + 4 个 32 位整数
# 【执行者】射手(玩家); 魔力已在 shot 里扣掉(799)
# 【做什么(按 lore 顺序)】
#   ① 术阵(20 秒 —— 与影的寿命同寿; 术阵槽位满了会建失败, 不影响技能本身,
#      所以不看返回值, 与圣骸 cast 那条一致)
#   ② 在自身位置**左右各**召一个魂灵之影(rotated ~ 0: 只跟随朝向的水平角,
#      抬头/低头时不会把影召到天上或地下)
#   ③ (口径由 shot 写在射手身上的 zx.bd_mode: 1 = 主力 / 2 = 续轰)
#   ④ zx.bd_on = 1(技能进行中的展示位)
# ============================================================

# ① 术阵(25 秒 = 影的 20 秒寿命 + 5 秒余量, 只是**兜底**;
#      正常情况由 end 在"场上没有影了"的那一刻主动撤掉 —— 见 check)
$data modify storage manacore:in arg set value {uuid:"$(uu)",id:"sweetdream:burst_dawn",type:"burst_dawn",duration_seconds:25.0}
function manacore:api/formation/create

# ② 两个魂灵之影(左右各一个; shade_make 自己会按 uu/u0..u3 写归属)
execute at @s rotated ~ 0 positioned ^1.7 ^0.1 ^0 run function sweetdream:equipment/bow/burst_dawn/shade_make with storage zx:work bd
execute at @s rotated ~ 0 positioned ^-1.7 ^0.1 ^0 run function sweetdream:equipment/bow/burst_dawn/shade_make with storage zx:work bd

# ③ (★ 不再给箭打标记 —— 坑 141: 射击那一刻箭可能还没进世界, 打了也打不上。
#     "这一发是主力还是续轰"改记在射手身上的 zx.bd_mode, 由 shot / ammo 写。)

# ④ 技能进入"进行中"
scoreboard players set @s zx.bd_on 1
