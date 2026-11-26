# ============================================================
# fallendream:equipment/armor/char_coat/on_skill_hit —— 焦衣: 把目标的「流火」升级成「夜火」
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【文案(lore 逐字)】自身魔力值上限 +130。自身主动技能的**普通伤害**命中了附有
#   「流火」而未附有「夜火」的生物后，若魔力足够，则消耗 80 魔力，将其「流火」
#   转化为「夜火」。该效果 10 秒内最多触发一次。
# 【★ 排在 deal **之后** ★】两个理由:
#   ① 文案是"命中了…后";
#   ② 更要紧 —— 「夜火」的受击侧效果是"受到**技能伤害** +15%"(见 internal/damage/
#      vuln_tag)。若在 deal 之前就把流火升级成夜火, 这一击会**当场**多吃那 15%,
#      而文案明确是"**之后**转化"。所以必须等这一击结算完再转。
# 【★ "转化" ≠ "消耗" ★】流火不是被"消费掉"的, 而是**变**成了夜火 ⇒
#   摘模板走 tag/unmark(**不是** lib/mark_consume)。走消耗入口会白给
#   余烬/回潮扣/烛跬那一串"消耗触发"的被动(等于凭空多一份收益)。
#   代价: 本转化**不会**触发自家烛跬的"消费流火回 8 魔力"(它是转化, 不是消费) ——
#   与文案口径一致。
# 【★ 顺序: 先摘流火、再挂夜火 ★】反过来的话, 目标会短暂同时带两个,
#   ttl 与图标也会多刷一次。
# ============================================================

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他穿着「焦衣」吗（胸甲）
scoreboard players set #cc_on zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"]}] run scoreboard players set #cc_on zx.meta 1
execute unless score #cc_on zx.meta matches 1 run return 0

# ②.5 分档: 超限·焦衣(2026-11-22)
#   【文案(逐字)】"自身魔力值上限 +180。自身主动技能的普通伤害命中了附有「流火」而
#     未附有「夜火」的生物后，若魔力足够，则消耗 50 魔力，将其「流火」转化为「夜火」，
#     之后偷取生效生物的 20% 基础攻击力并加在自身上，持续 8 秒。该效果 10 秒内最多
#     触发一次。自身攻击被偷取了任意属性的生物时都会使其额外受到一次相当于自身基础
#     攻击力的伤害。"
#   与基础版差: 上限 130->180 / 魔力 80->50 / 多"偷取 20% 基础攻击力(8 秒)" 与
#               "攻击被偷者时追加一次自身基础攻击力的伤害"。
scoreboard players set #cc_ol zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"],ol:"char_coat"}] run scoreboard players set #cc_ol zx.meta 1

# ③ 目标仍要满足"带流火 + 未带夜火"（one 里已判过一次，这里复判 —— 本件要能独立测，
#    也不能被别处误调）
execute unless entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run return 0

# ④ 10 秒节流（账本记在**施法者**身上）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set #cc_due zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run execute store result score #cc_due zx.meta run scoreboard players get @s zx.cc_cd
execute if score #cc_due zx.meta > #now manacore.meta run return 0

# ⑤ 拿施法者的 uuid（扣魔力的公共输入口要它）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work cc.uuid set from storage zx:data self.uuid

# ⑥ 消耗魔力（够才扣）：基础 80 / 超限 50
data modify storage manacore:in arg set value {uuid:"",value:80.0}
execute if score #cc_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:work cc.uuid
function fallendream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 转化：先摘「流火」，再挂「夜火」
#    摘模板会顺手撤掉流火那条"护甲 -20%"的修饰符与它的剩余秒数(见 tag/unmark_one)。
data modify storage zx:work cc set value {target:"@s",mark:"liuhuo"}
function fallendream:tag/unmark with storage zx:work cc
data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
function fallendream:tag/mark with storage zx:work ic

# ⑧ 表现
execute at @s run particle minecraft:soul_fire_flame ~ ~0.8 ~ 0.4 0.5 0.4 0.01 12 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.6 1.1

# ⑧.5 超限: 偷取这只的 20% 基础攻击力（8 秒）+ 给它打"被偷"标记
#   ★ 生物的"基础攻击力"读原版 attack_damage 属性 ★ 怪物没有面板,
#     原版属性就是它挥拳用的那个数; ×1000 取定点后算 20%。
#   ★ 标记打在**被偷的那只**身上, 供"自身攻击被偷者时追加伤害"认人 ★
scoreboard players set #cc_a zx.meta 0
execute if score #cc_ol zx.meta matches 1 store result score #cc_a zx.meta run attribute @s minecraft:attack_damage get 1000
scoreboard players set #cc_20 zx.meta 20
scoreboard players set #cc_100 zx.meta 100
scoreboard players set #cc_cap zx.meta 2147483647
execute if score #cc_ol zx.meta matches 1 run scoreboard players operation #cc_cap zx.meta /= #cc_20 zx.meta
execute if score #cc_ol zx.meta matches 1 if score #cc_a zx.meta > #cc_cap zx.meta run scoreboard players operation #cc_a zx.meta = #cc_cap zx.meta
execute if score #cc_ol zx.meta matches 1 run scoreboard players operation #cc_a zx.meta *= #cc_20 zx.meta
execute if score #cc_ol zx.meta matches 1 run scoreboard players operation #cc_a zx.meta /= #cc_100 zx.meta

#   ★ "被偷"标记打在受害者身上后**不设期限** ★ 它随生物一起消失, 不占计分项;
#     文案"自身攻击被偷取了任意属性的生物时都会…"是一条常驻条款, 不与"加在自身上
#     持续 8 秒"绑在一起（8 秒那份由施法者身上的 zx.cc_ba / cc_end 管）。
execute if score #cc_ol zx.meta matches 1 run tag @s add zx.cc_steal

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if score #cc_ol zx.meta matches 1 run function fallendream:lib/u_by
execute if score #cc_ol zx.meta matches 1 if score #cc_a zx.meta matches 1.. as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/char_coat/steal_apply

# ⑨ 记下"下次可触发刻"（现在 + 200 刻 = 10 秒）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.cc_cd = #now manacore.meta
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.cc_cd += #200 zx.meta
