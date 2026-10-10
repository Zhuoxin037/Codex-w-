# ============================================================
# sweetdream:equipment/staff/palette/color_hit —— “色彩”命中一只生物
# ------------------------------------------------------------
# 【谁调用它】color_body 第 ④ 步(进 1.5 格); 【执行者】色彩 item_display; 【位置】色彩处
# 【文案】对其造成相当于自身最大魔力值 ×0.1 的伤害。
#   ● 红：每有一个红色都会将伤害提高 1 倍。 -> 伤害 = 最大魔力 ×0.1 ×(1 + 红数)
#   ● 蓝：每有一个蓝色则在造成伤害后回复自身 150 点魔力值并使技能冷却时间 -5 秒。
# 【伤害口径】最大魔力 ×0.1×(1+红数) -> 直接乘到 max_mana_mul 通道(基数 = 面板最大魔力)。
#   执行者是 item_display(不是玩家), 所以 calc 用实体里存的释放者 uuid 查面板;
#   归属用实体里存的 u0..u3(和 ball/hit 同款), 走 internal/damage/with_from。
#   ★ 2026-10-10 修 F13: calc **不再以 item_display 身份跑**, 而是先按 uuid 反查出
#     释放者、以他的身份跑(见 ①' 与 internal/damage/calc_as_owner) —— 否则
#     damage_calc 事件里"玩家限定"的加算 hook 全被跳过, 色彩伤害吃不到主人的装备加成。
# 【★ 每命中一只调一次 color_blue(按蓝数减冷却) ★】所以"色彩"连打两只挤在一起的生物
#   = 各 -5×蓝数 秒。
#   ★ 2026-10-08: "打一下 -10 秒"不是这里打了两只, 而是前置包 cooldown/reduce 把
#     {seconds:} 传参减了 2 倍(见 color_blue 头注释的事故订正); 已修。
# 【"已经攻击过的生物"】打完把那只的 zx.pal_hit 记成本色彩 id(见 color_body 第 ③ 步的排除)。
# ============================================================

# ① 算伤害: 最大魔力 ×0.1 ×(1+红数)。zx.pal_mul 就是 (1+红数)。
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.0}
data modify storage manacore:in arg.uuid set from entity @s data.zx.pal.uuid
execute store result storage manacore:in arg.max_mana_mul double 0.1 run scoreboard players get @s zx.pal_mul

# ①' ★ 以"释放者本人"的身份算伤害(2026-10-10, 修 F13) ★
#   执行者若还是 item_display, #manacore:event/damage_calc 里那些"玩家限定"的
#   加算 hook(愿景升级增伤 / 共振 / 漫步 / 桂冠… 第一行 `unless @s[type=player] return`)
#   会全部跳过 ⇒ 色彩伤害吃不到主人的装备加成(面板基数能读到, 装备加成读不到)。
#   把释放者 uuid 的 4 段装进独立节点 zx:work co(不污染下面要用的 a), 交给
#   calc_as_owner 按 uuid 反查出玩家、以他的身份重算。
data modify storage zx:work co set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work co.u0 set from entity @s data.zx.pal.u0
data modify storage zx:work co.u1 set from entity @s data.zx.pal.u1
data modify storage zx:work co.u2 set from entity @s data.zx.pal.u2
data modify storage zx:work co.u3 set from entity @s data.zx.pal.u3
function sweetdream:internal/damage/calc_as_owner with storage zx:work co

# ② 打成伤害(目标 = 刚挑中的那只; 归属 = 释放者)
data modify storage zx:work a set value {target:"@e[tag=zx.pal_t]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.u0 set from entity @s data.zx.pal.u0
data modify storage zx:work a.u1 set from entity @s data.zx.pal.u1
data modify storage zx:work a.u2 set from entity @s data.zx.pal.u2
data modify storage zx:work a.u3 set from entity @s data.zx.pal.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 把这只记为"本色彩已打过"(不会再追它)
execute as @e[tag=zx.pal_t,distance=0..] run scoreboard players operation @s zx.pal_hit = #pal_id zx.meta

# ④ 记账 +1
scoreboard players add @s zx.pal_n 1

# ⑤ 蓝: 每 1 个 +150 魔力 且 冷却 -5 秒
execute if score @s zx.pal_blu matches 1.. run function sweetdream:equipment/staff/palette/color_blue

# ⑥ 达到阀值(5 + 3×黄数) -> 自毁
execute if score @s zx.pal_n >= @s zx.pal_thr run function sweetdream:equipment/staff/palette/color_end
