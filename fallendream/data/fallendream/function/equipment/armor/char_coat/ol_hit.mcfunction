# ============================================================
# fallendream:equipment/armor/char_coat/ol_hit —— 超限·焦衣：追加一次"自身基础攻击力"
# ------------------------------------------------------------
# 【宏参数】$(u0)..$(u3) = 攻击者 UUID 四段（由 internal/damage/one 从 ob 抄进 zx:work nsu）
# 【执行者】被打的那一只（@s 必须留作受击者）
# 【调用点】internal/damage/one ①.9b0（本地已判"受害者带 zx.cc_steal"）
# 【文案(逐字)】"自身攻击被偷取了任意属性的生物时都会使其额外受到一次相当于自身
#   基础攻击力的伤害。"
# 【★ 为什么必须有 fixed 门控 ★】"额外受到一次伤害"是**新投递一笔**，它同样会进
#   internal/damage/one ⇒ 不加门控就会无限套娃（每次追加再触发一次追加）。
#   追加的那一笔带 fixed:1b，而 one 里的入口写的是 `unless a{fixed:1b}` ⇒
#   只认真打出去的那一下，链子到此为止。
# 【★ 为什么只能 type:"fallendream:true_damage" + uncapped:1b ★】见 deal 第 51–54 行:
#   deal 只给 skill / true_damage 两种"逻辑类型"开了绕开受伤冷却的平行通道; 其它类型会
#   走普通 /damage，被刚打出的那一刀的无敌帧吞掉（不报错、静默零伤害）。
#   ★ 用 true_damage 这一条只是为了搭这段通道; 数值本身带 fixed:1b ⇒ one 里所有
#     vuln / 升痕 / 噬心分支都带 `unless a{fixed:1b}`，这一笔不会被任何乘区放大。
# 【★ 数值口径 ★】"相当于自身基础攻击力" ⇒ 读面板 base_attack（×100 定点），
#   与超限·焱的 ol_melee_hit、承星的固定伤害同一条路。
# ============================================================

# ① 攻击者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他穿着**超限**·焦衣吗（基础版没有这一条）
#   ★ 只有超限的文案里有"追加伤害"这件事，基础版到"转化为夜火"就结束了 ★
scoreboard players set #cc_hit zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"],ol:"char_coat"}] run scoreboard players set #cc_hit zx.meta 1
execute unless score #cc_hit zx.meta matches 1 run return 0

# ③ 读他的基础攻击力（要借执行者身份 ⇒ 拆到 ol_ba）
scoreboard players set #cc_ba zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/char_coat/ol_ba
execute unless score #cc_ba zx.meta matches 1.. run return 0

# ④ 追加一笔固定伤害
#   ★ 先把当前这一笔的 zx:work a 存起来 ★ 嵌套的 with_from 结束时会把 a 还原成
#     **它自己那份入参**；不手动复原的话，one 里本行之后的回调（殓丝/剖面/圣骸…）
#     读到的就是追加那一笔的入参（同一只目标，但 type/fixed 全变了）。
data modify storage zx:work cc_save set from storage zx:work a
$data modify storage zx:work a set value {fixed:1b,uncapped:1b,target:"@s",type:"fallendream:true_damage",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work a.num double 0.01 run scoreboard players get #cc_ba zx.meta
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
data modify storage zx:work a set from storage zx:work cc_save
data remove storage zx:work cc_save

# ⑤ 表现
execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.3 0.3 0.05 6 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.4 1.6
