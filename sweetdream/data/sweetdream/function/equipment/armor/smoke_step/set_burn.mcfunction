# ============================================================
# sweetdream:equipment/armor/smoke_step/set_burn —— 燧行: 烧着的目标吃 +12% 技能伤害
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段) —— 由 internal/damage/one 从 ob 展开
# 【执行者】被打的那一只（@s = 目标）   【出参】改写 zx:work a.num / a.damage / a.num_str
# 【文案(lore 逐字)】自身对附有「流火」的生物造成的基础攻击力类技能伤害提高 12%
#   （独立乘区）。
# 【★ 为什么排在 deal **之前** ★】这里要改的是"这一下要打出去多少"，必须在
#   internal/damage/deal 之前把 a.num 写好；deal 之后再改就只是改了个没人读的变量。
# 【★ 为什么在 vuln_tag(①.5d) **之后** ★】两者都以 a.num 为底、都是乘法，先乘谁
#   结果一样；但排在它后面能和"目标带夜火 / 噬心"那条走同一段语义 ——
#   "受击侧的各种乘区依次乘上去"，读起来是一条线。
# 【★ 独立乘区 = 乘在求和之后 ★】文案明写「(独立乘区)」⇒ 直接乘 a.num（此刻 a.num
#   已是三条通道求和 + 加算池 + 独立乘区的结果），而不是往某条通道加百分比。
#   判据（attack_mul > 0）只用来**筛选"基础攻击力类"技能**，不是把 12% 并进那条通道。
#   —— 与愠怒(wrath/hook_calc 判 mm 通道)完全同款的做法。
# 【★ 这个 attack_mul 从哪来（2026-10-16 自查修掉的一处静默）★】它**不在**
#   zx:work a 的原始入参里 —— 通道字段只存在于 manacore:work a，由 lib/dmg_ch
#   在 damage_calc 里拍成快照 zx:work ch。真正把它带到这里的，是
#   internal/damage/with_from 在抄 ob 时多抄的那一行（ob.attack_mul ← ch.attack_mul），
#   再由 internal/damage/one 的 ①.5b「a set from ob」还原到 a 上。
#   ⚠️ 一度写成"直接读 zx:work a.attack_mul"就以为万事大吉 —— 那一版里 a 上根本没这个键，
#      data get 取不到值 ⇒ 判据恒 0 ⇒ 整条套装**一次都不会触发**，且零日志。
#   现在这条链是通的；若以后有人把 with_from 那行删掉，这里会**静默归零**（不是报错）。
# 【★ 为什么不折面板 ★】本条生效与否取决于"**目标**身上有没有流火"，而 debug/stats
#   是看着**自己**算的 —— 面板无法表达这个条件。折进去就会让面板显示 ×1.12 而实际
#   打不带流火的怪没有加成 = 面板说假话（违反"显示必须真实生效"的第一原则）。
#   ⇒ 宁少显示不多显示，与本条配套的面板行**不加**。
# 【施法者是谁】从 ob.uuid 四段反查（本包技能伤害都带 `by <玩家>`，见 deal）。
#   反查不到（离线 / 无归属）就直接收工。
# ============================================================

# ⓪ 入参有东西可改吗（有些调用点只写 num、不写 damage）
execute unless data storage zx:work a.num unless data storage zx:work a.damage run return 0

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他穿齐「燧行」两件吗（● 燧帽 = 头盔 / ● 烟履 = 靴子）
#    切到玩家上下文才能判 items —— 判定写在同一条 execute 里，避免多一次往返。
scoreboard players set #sb_on zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.head *[minecraft:custom_data~{zx:["flint_hat"]}] if items entity @s armor.feet *[minecraft:custom_data~{zx:["smoke_step"]}] run scoreboard players set #sb_on zx.meta 1
execute unless score #sb_on zx.meta matches 1 run return 0

# ③ 这一击是"基础攻击力类"技能吗（attack_mul > 0）
#    值由 with_from 冻进 ob、one 的 ①.5b 还原到 a 上（见文件头【这个 attack_mul 从哪来】）。
#    没有这个键（= 本次没有走过 calc，比如裂缝那种"存好的数字"投递）时 data get 不写,
#    #sb_a 保持 0 ⇒ 判成"不是基础攻击力类" —— 宁少不多。
scoreboard players set #sb_a zx.meta 0
execute store result score #sb_a zx.meta run data get storage zx:work a.attack_mul 100
execute unless score #sb_a zx.meta matches 1.. run return 0

# ④ 伤害 ×1.12（独立乘区）
#    乘区 = 100 + 12 = 112；用 #100 + #12 拼出来（core/load 里没有 #112 这个常量）
scoreboard players set #sb_m zx.meta 100
scoreboard players operation #sb_m zx.meta += #12 zx.meta

#    底数 = 当前 a.num(x1000)
scoreboard players set #sb zx.meta 0
execute if data storage zx:work a.num store result score #sb zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #sb zx.meta run data get storage zx:work a.damage 1000

#    【R05 整数上界保护】#sb 此刻是"伤害 ×1000"，下一步要 ×112。
#      计分板是 int32，中间值越过 2,147,483,647 会**回绕成负数** —— 不报错，
#      结果却变成天文数字或负值。这里钳到 INT32_MAX ÷ 乘区；常态（伤害 ≤ 约 1.9 万）
#      一行都不受影响。口径与 vuln_tag / stg_mul 一致。
scoreboard players set #sb_cap zx.meta 2147483647
scoreboard players operation #sb_cap zx.meta /= #sb_m zx.meta
execute if score #sb zx.meta > #sb_cap zx.meta run scoreboard players operation #sb zx.meta = #sb_cap zx.meta

scoreboard players operation #sb zx.meta *= #sb_m zx.meta
scoreboard players operation #sb zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #sb zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num

# ⑤ 重新生成纯数字字符串（交给 internal/damage/deal 去打）
function sweetdream:lib/num/plain
