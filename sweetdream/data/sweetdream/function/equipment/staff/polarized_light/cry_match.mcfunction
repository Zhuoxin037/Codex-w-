# ============================================================
# sweetdream:equipment/staff/polarized_light/cry_match —— 归属匹配(宏)
# ------------------------------------------------------------
# 【谁调用它】cry_scan ⑤(每束光一次; 执行者 = 施法玩家)
# 【宏参数】zx:work pb {u0,u1,u2,u3} = 施法者 UUID 四 int
# 【做什么】把 13 格内**属于这个施法者**的共鸣水晶打成 zx.ch_mine=1
# 【为什么还要宏】归属存在水晶自己的 data.zx.ch.u0..u3(NBT, 见 chime/skill);
#   计分项替不掉 —— 宏参数只能拼进命令文本, 没法拿去和 NBT 比。
#   ★ 但这已经是**每束光 1 次**, 不是原来每步 1 次(见 cry_scan 头注释)。
# ============================================================

$execute as @e[type=minecraft:marker,tag=zx.ch_cry,distance=..13,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] run scoreboard players set @s zx.ch_mine 1
