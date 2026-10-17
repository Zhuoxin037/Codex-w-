# ============================================================
# sweetdream:equipment/staff/other_shore/passive_true —— 双状态者的 ×0.03 真实伤害
# ------------------------------------------------------------
# 【谁调用它】hit_go ②   【执行者】发射者(玩家)   【位置】第一只目标处
# 【技能原文】"若其同时附有「渊海」和「噬心」，则额外造成一次相当于自身最大魔力值
#   ×0.03 的真实伤害。"
# 【★ 归属与面板都靠玩家身份 ★】所以本文件只能在 hit_go(已换回玩家)里调;
#   ball_hit 先用 lib/find_by 把发射者反查出来, 就是为了这一步。
# 【★ 真伤类型 = sweetdream:true_damage ★】无视护甲; 由 api/damage 的 type 字段指定。
# ============================================================

# ① 算伤害: 最大魔力值 ×0.03
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打(只打"同时有两种状态"的那几只)
data modify storage zx:in arg set value {target:"@e[tag=zx.os_pass,tag=zx.os_both,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ③ 表现: 两界之间被撕开的一道口子
execute at @e[tag=zx.os_pass,tag=zx.os_both,distance=0..,limit=1] run particle minecraft:dust{color:[0.45,0.1,0.65],scale:1.6} ~ ~1 ~ 0.5 0.6 0.5 0.02 18 normal
execute at @e[tag=zx.os_pass,tag=zx.os_both,distance=0..,limit=1] run playsound minecraft:block.soul_sand.break player @a ~ ~ ~ 0.7 1.2
