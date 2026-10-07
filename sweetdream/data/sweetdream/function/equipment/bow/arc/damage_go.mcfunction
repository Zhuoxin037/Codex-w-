# ============================================================
# sweetdream:equipment/bow/arc/damage_go —— 「电弧」放电结算
# ------------------------------------------------------------
# 【谁调用它】discharge 的 B 段(`execute as @a[tag=zx.arc_pl,limit=1] at @s`)
# 【执行者】射手(@s = 玩家); 【位置】射手处
# 【技能原文(lore 逐字)】"...对沿途的生物及他们自身造成一次相当于自身基础攻击力
#   ×2+ 当前魔力值 ×0.03 的伤害..."
# 【伤害口径】"自身" = 射手。基础攻击力 ×2 + 当前魔力 ×0.03 ->
#   attack_mul:2.0(基数 = 面板 base_attack) + other_mul:0.03(基数默认 = 当前魔力)。
#   两条通道都写 -> 没写的 max_mana_mul 当 0(见 manacore internal/damage/calc 的缺省规则)。
# 【为什么以射手身份执行】① 面板要用射手的: calc 靠 `uuid` 查 manacore:players;
#   ② 归属要用射手的: 这里 `@s` 就是玩家, 直接取 UUID[0..3] 拼 by, 击杀才算射手的。
# 【目标】zx.arc_on = discharge 走廊标出来的生物(含两只端点)。选择器带 distance=0..
#   是为了把它**锁在射手所在维度**(裸 @e 会跨维度搜, 见 RULES 坑 55)。
# ============================================================

# ① 算伤害: 射手面板 基础攻击力 ×2 + 当前魔力 ×0.03
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0,other_mul:0.03}
function manacore:api/player/self_uuid
data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
function manacore:api/damage/calc

# ② 打成伤害(目标 = 走廊成员; 归属 = 射手)
data modify storage zx:work a set value {target:"@e[tag=zx.arc_on,distance=0..]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a
