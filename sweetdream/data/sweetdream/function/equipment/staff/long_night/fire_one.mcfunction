# ============================================================
# sweetdream:equipment/staff/long_night/fire_one —— 夜原一秒钟的"消耗 → 增伤 → 打击"
# ------------------------------------------------------------
# 【谁调用它】prepare ②   【执行者】施法者本人   【位置】夜原中心   【维度】夜原所在维度
# 【技能原文】"每秒消耗其中一个生物的「夜火」并使其附加「流火」，且其护甲值及护甲韧性
#   -60%。之后对其造成一次相当于自身最大魔力值 ×0.12 的伤害。每消耗一次，则"夜原"的
#   后续伤害提高 8%（独立乘区）。"
# 【★ 顺序与口径(2026-10-16 实装) ★】
#   ① 先消耗(统一入口, 余烬/永恒/烛跬/回潮扣 都认对) -> 只有**真摘掉**才继续
#     ("永恒"把标签补回来的那次不算消耗, 那条路直接收工)。
#   ② 附着「流火」= **附着**不是消耗 ⇒ 直调 tag/mark(走 mark_consume 会白送一次余烬被动)。
#   ③ 护甲值/韧性 -60%: 挂原版属性修饰符, 打 zx.ln_debuff 让人认领;
#     ★ 用户 2026-10-16 拍板: 持续 = **整个夜原期间**, 由 field_end 统一撤销。
#   ④ 本秒的伤害按 **+0 之后**的次数取值(= 上一秒累计的消耗次数), 打完才 +1。
#     ★ 口径说明 ★ 原文两句要连起来读: "之后对其造成一次相当于自身最大魔力值 ×0.12 的
#       伤害。每消耗一次，则'夜原'的**后续**伤害提高 8%" —— "后续"= 这一跳之后的那些跳。
#       ⇒ 第 1 秒必须是**干净的 ×0.12**(否则正文那个 0.12 就永远对不上),
#       第 2 秒起才吃 1.08、1.08²、…、1.08⁷。所以计数放在伤害**之后**加。
#   ⑤ 独立乘区 = damage/calc 的 independent_multiplier, 值查表 1.08^n(n 只有 0..8 九种)。
# ============================================================

# ① 消耗它的「夜火」
data modify storage zx:work a set value {target:"@e[tag=zx.ln_tgt,distance=0..,limit=1]",mark:"yehuo"}
function sweetdream:lib/mark_consume

# ①.5 只有真的摘掉才算"消耗"
#   · ok   = 它身上真有这个标签(防选完到消耗之间被别的效果摘掉)
#   · done = 穿「永恒」时把标签补回来了 = 不算消耗(见 lib/mark_take)
execute unless data storage zx:work mc{ok:1b} run return 0
execute if data storage zx:work mc{done:1b} run return 0

# ② 附着「流火」("并使其附加流火")
data modify storage zx:work ic.target set value "@e[tag=zx.ln_tgt,distance=0..,limit=1]"
data modify storage zx:work ic.mark set value "liuhuo"
function sweetdream:tag/mark with storage zx:work ic

# ③ 护甲值 / 护甲韧性 -60%(原版属性修饰符; 重贴同 id 已存在时 add 会失败, 无副作用)
#   ★ 这两条是**实体数据**, 不撤就是永久 -60% ⇒ 必须挂 zx.ln_debuff 让人认领
execute as @e[tag=zx.ln_tgt,distance=0..,limit=1] run attribute @s minecraft:armor modifier add sweetdream:nightyard_armor -0.6 add_multiplied_base
execute as @e[tag=zx.ln_tgt,distance=0..,limit=1] run attribute @s minecraft:armor_toughness modifier add sweetdream:nightyard_tough -0.6 add_multiplied_base
tag @e[tag=zx.ln_tgt,distance=0..] add zx.ln_debuff

# ④ 本秒的伤害 ×0.12(计数在 ⑥ 之后才 +1 —— 见文件头 ④ 的口径说明)

# ⑤ 算这一段伤害 = 自身最大魔力值 ×0.12 × 1.08^已消耗次数(独立乘区)
#   ★★ 必须在这里重取一次 uuid ★★
#   damage/calc 是**按 uuid 查这个人的面板**(最大魔力值 / 基础攻击力)来算的, 而
#   zx:data self.uuid 是**全包共用的"最后一次 lib/uuid 的结果"** —— fire_one 是在
#   施放后 1..8 秒才逐秒跑的, 中间只要另一个玩家用过任何 lib/uuid, 这份值就变成别人的了
#   ⇒ 伤害会按别人的魔力算(静默、不报错)。@s 此刻正是施法者(prepare 用
#   `at @s as @a[tag=zx.mc_by]` 换进来的), 所以直接重取即可。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
scoreboard players set #ln_n zx.meta 0
execute store result score #ln_n zx.meta run scoreboard players get @e[tag=zx.ln_center,distance=0..,limit=1] zx.ln_n
execute if score #ln_n zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 1.08
execute if score #ln_n zx.meta matches 2 run data modify storage manacore:in arg.independent_multiplier set value 1.17
execute if score #ln_n zx.meta matches 3 run data modify storage manacore:in arg.independent_multiplier set value 1.26
execute if score #ln_n zx.meta matches 4 run data modify storage manacore:in arg.independent_multiplier set value 1.36
execute if score #ln_n zx.meta matches 5 run data modify storage manacore:in arg.independent_multiplier set value 1.47
execute if score #ln_n zx.meta matches 6 run data modify storage manacore:in arg.independent_multiplier set value 1.59
execute if score #ln_n zx.meta matches 7 run data modify storage manacore:in arg.independent_multiplier set value 1.71
execute if score #ln_n zx.meta matches 8 run data modify storage manacore:in arg.independent_multiplier set value 1.85
function manacore:api/damage/calc

# ⑥ 打它(带归属: 施法者 UUID 四个整数)
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.ln_tgt,distance=0..,limit=1]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑥.5 "每消耗一次, '夜原'的后续伤害提高 8%" —— 这一次打完了, 才把计数 +1
#   记在**夜原 marker** 上(不是玩家身上): "后续伤害"属于这一次夜原, 换个夜原重新起算。
#   文案的"每消耗一次"是按消耗次数算, 与"这一秒有没有打出去"无关; 走到这里 = 真消耗过了。
execute as @e[tag=zx.ln_center,distance=0..,limit=1] run scoreboard players add @s zx.ln_n 1

# ⑦ 表现 + 收尾(摘本轮目标标签)
execute at @e[tag=zx.ln_tgt,distance=0..,limit=1] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.5 0.6 0.5 0.03 22 normal
execute at @e[tag=zx.ln_tgt,distance=0..,limit=1] run particle minecraft:dust{color:[0.3,0.1,0.5],scale:1.4} ~ ~1 ~ 0.5 0.6 0.5 0.02 16 normal
tag @e[tag=zx.ln_tgt,distance=0..] remove zx.ln_tgt
