# ============================================================
# sweetdream:equipment/staff/twilight/tw_proc —— 20% 命中: 附「噬心」+ 补一发伤害
# ------------------------------------------------------------
# 【谁调用它】twilight/ball_hit(判定成功); 【执行者】法球(@s, 位置 = 命中点)
# 【目标】@e[tag=zx.ball_hit](ball/hit 第 ⑦ 步才会摘这个标签)。
# 【伤害】= 这一发的 dmg(球身上存的 data.dmg), 走 internal/damage/with_from
#   (和 ball/hit 的打法一致: num -> num_str -> 归属 u0..u3)。
# ============================================================

# ① 附「噬心」(统一入口: 会刷新 18 秒租约 + 头顶图标)
data modify storage zx:work ic set value {target:"@e[tag=zx.ball_hit]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ② 额外一次伤害(数值 = 这一发的 dmg)
data modify storage zx:work a set value {target:"@e[tag=zx.ball_hit]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from entity @s data.dmg
data modify storage zx:work a.u0 set from entity @s data.u0
data modify storage zx:work a.u1 set from entity @s data.u1
data modify storage zx:work a.u2 set from entity @s data.u2
data modify storage zx:work a.u3 set from entity @s data.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 表现
#   ★ 暮光的命中音在**这里**, 不在 projectile/ball/fx_twilight_hit ——
#     用户要求: 普攻命中本身保持静音, 只有 20% 触发「噬心」这一下才出声。
#     (音量/音高与原先 fx_twilight_hit 里的一致; 想调改这一行)
execute as @e[tag=zx.ball_hit,distance=0..] at @s run particle minecraft:witch ~ ~1 ~ 0.4 0.6 0.4 0.03 14 normal
execute at @e[tag=zx.ball_hit,distance=0..] run playsound minecraft:entity.wither.shoot player @a ~ ~ ~ 0.55 1.2
