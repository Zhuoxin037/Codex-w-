execute if entity @s[tag=zx.j_body] run return 0
execute if entity @s[tag=zx.j_twin] run return 0
# ============================================================
# fallendream:internal/damage/one —— 对"一个"目标打伤害(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只(由 with_from 用 execute as 逐个送进来)
# 【顺序很重要】
#   ①   (2026-10-12 坑 138 已删) 原本在打之前数目标身上的通用标签(#dmk),
#       服务于「黄昏黎明之交界」超限版的 100×X。那整套附魔回调方案已经废弃 ——
#       原版 post_attack 只读攻击者的**主手物品**, 附魔挂在靴子上永远不触发。
#       现在 X 由 5 条标签进度独立数出, 见 equipment/armor/dusk_dawn/kill_mark。
#   ①.5 ★ 每只目标都从专用基准节点 zx:work ob 复原入参 ★
#        + 目标带「升痕」且"居高临下"时, 把伤害乘区加上
#   ②   打伤害(带 by <攻击者>, 击杀才算玩家头上) —— 走 internal/damage/deal
#   ③   (2026-10-12 坑 138 已删) 原本"这一下打死就调 kill_mark_from_skill 补 +100"。
# 【★ 为什么每只都要"复原"★】见 with_from 的长注释: a 是全包共用的临时节点,
#   伤害循环里任何嵌套调用都可能动它。所以每只目标开打前, 都把 deal 需要的入参
#   从 ob(专用基准) 拉回来一次 —— 这样"每只都从同一份原始伤害起算", 加成绝不会
#   串到下一条没有升痕的命上。
# ============================================================

# ①.5a 读这只目标自己的「升痕」层数(0 = 没升痕)
scoreboard players set #stg zx.meta 0
execute if entity @s[scores={zx.stg=1..}] store result score #stg zx.meta run scoreboard players get @s zx.stg

# ①.5a-2 攻击者 Y(×100)从本批快照复原 —— 每批只在 with_from 反查一次(见那里)
#   嵌套伤害(击杀记账 / 收尾钩子触发的新一次 calc)可能改过 #stg_ay, 这里拉回基准值。
scoreboard players set #stg_ay zx.meta 0
execute if data storage zx:work ob.ay store result score #stg_ay zx.meta run data get storage zx:work ob.ay

# ①.5b ★ 整份复原 deal 的入参(基准 = zx:work ob) ★
#   num_str / type / u0..u3 是 deal 那条宏的参数; damage 是下面 stg_mul 的底数。
#   ★★ 2026-10-10 修 F08: 原来是"挑字段恢复", **漏了 num** ★★
#     stg_mul / vuln_tag 都是"读 a.num 当底数、再写回 a.num"的**累积式**改写。
#     只恢复 damage/num_str 不恢复 num ⇒ 第二只带易伤(夜火/噬心)的目标会在
#     **第一只放大后的 num** 上再乘一次: 100 → 115 → 132.25 … 越往后越离谱,
#     而且结果取决于选择器遍历顺序(换个目标顺序数值就变)。
#     改成**整份 set from ob**: ob 是这批伤害的不可变快照(见 with_from),
#     每只目标开打前一律拉回它, 中途谁改过 a 都不影响, 与目标顺序无关。
data modify storage zx:work a set from storage zx:work ob
execute if entity @s[tag=zx.pn_vul] unless data storage zx:work a{pn_extra:1b} run function fallendream:equipment/axe/throe/settle
function fallendream:upgrade/breach/target

# ①.5c 天穹「升痕」加伤: 目标带升痕 + 这一击"来自比它更高处" -> 本次伤害 ×(1+5%×层数)
#   【开销】平时(目标没升痕)只多一条选择器判定; 走这条的只有被天穹打过、且被居高临下
#   命中的生物, 很罕见。stg_mul 的宏参数用 $(u0).., 上面刚复原过, 一定在。
#   stg_mul 满足条件时会**就地覆盖** a.num / a.damage / a.num_str(交给下面的 deal)。
execute unless data storage zx:work a{fixed:1b} if score #stg zx.meta matches 1.. run function fallendream:internal/damage/stg_mul with storage zx:work a

# ①.5d 通用标签的"受击侧加乘"(2026-10-06 加)
#   · 夜火: 受到技能伤害 +15%  —— "技能伤害"包含两种来源:
#       ① 本包技能类型 fallendream:skill(玩家侧);
#       ② 敌方技能(src:"enemy", 走 api/enemy_damage)。
#     ★ 两条分支**必须互斥**: 若敌方技能同时也用了 fallendream:skill 类型, 两个条件会同时
#       成立 -> vuln_tag 跑两次 = +32%(而不是 +15%)。所以第一条多带一个
#       `unless ... src:"enemy"`(敌方技能只走第二条)。
#   · 噬心: 受到真实伤害 +15%  (type = fallendream:true_damage; 敌方的真实伤害同样适用)
#     ★ 若某一下既是"敌方技能"又是"真实伤害", 且目标同时带夜火+噬心 -> 两条各 +15%
#       (×1.3225)。这是两个**不同标签**叠在一起, 属于预期(它们不是同一条加成)。
#   ★ 必须是"目标带标签 + 这一下的伤害类型/来源对得上"两个条件都成立; 共用同一个
#     internal/damage/vuln_tag。
#   ★ 放在 stg_mul(升痕)**之后**: vuln_tag 以当前 a.num 为底, 语义是"升痕算完再乘一道";
#     反过来(以 ob.num 为底)会让两者互相顶掉, 只生效一个。
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.status.yehuo] if data storage zx:work a{type:"fallendream:skill"} unless data storage zx:work a{src:"enemy"} run function fallendream:internal/damage/vuln_tag
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.status.yehuo] if data storage zx:work a{src:"enemy"} run function fallendream:internal/damage/vuln_tag
execute unless data storage zx:work a{fixed:1b} if data storage zx:work a{type:"fallendream:true_damage"} if entity @s[tag=zx.status.shixin] run function fallendream:internal/damage/vuln_tag

# ①.5d' 灵视(头盔, 2026-11-22 超限): 目标被戴超限灵视的玩家圈住 ⇒ 其受到的
#   **最大魔力值相关的技能伤害** +24%。
#   【为什么在受击侧】这条加成的条件是"目标在谁的 8 格内", damage_calc 每次施法只算
#     一遍、分发给所有目标, 那里读不到"这一只"的位置 ⇒ 只能在 one 里做。
#   【为什么不用反查玩家】灵视每秒给范围内生物打了 zx.ss_ol(带 3 秒到期),
#     这里只判标签; 玩家反查是伤害热路径上的大开销(卡顿坑 1)。
#   【"最大魔力值相关"怎么判】读 ob.max_mana_mul(由 with_from 冻进快照),
#     不用 ch —— ch 是全局临时节点, 范围伤害中途会被别的 calc 整份换掉。
#   ★ ob 只许 with_from / one / stg_mul 三个文件碰(check 规则), 所以通道读数写在
#     本文件里, vuln_mm 只消费 #ss_mm; 没带标记的目标连这次 data get 都不做。
scoreboard players set #ss_mm zx.meta 0
execute if entity @s[tag=zx.ss_ol] store result score #ss_mm zx.meta run data get storage zx:work ob.max_mana_mul 1000
execute unless data storage zx:work a{fixed:1b} if score #ss_mm zx.meta matches 1.. if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/spirit_sight/vuln_mm

# ①.5g 针眠(头盔, 2026-11-22 超限): 对附有「噬心」的目标造成伤害后,
#   施法者本装备的冷却 -1 秒。
#   【为什么在受击侧】"造成伤害"包含技能伤害, 进度 needle_sleep_hit 只覆盖普攻;
#     而伤害结算跑在目标上下文里, 只能靠 ob 的 u0..u3 反查施法者。
#   【★ 先判标签再反查 ★】不带噬心的目标连那 4 次 data get 都不做。
#   【★ 敌方伤害不算 ★】文案是"自身对…造成伤害", 怪打玩家不该帮玩家减冷却。
#   【★ 不加 fixed 门控 ★】冷却减少与伤害数值无关, 固定伤害也属于"造成伤害"。
#   【★ 攻击者 UUID 只在本文件从 ob 抄出来 ★】ob 是专用基准节点, check 规则只许
#     with_from / one / stg_mul 碰; 抄到 nsu 之后宏叶子只读 nsu。
execute if entity @s[tag=zx.status.shixin] run data modify storage zx:work nsu set value {u0:0,u1:0,u2:0,u3:0}
execute if entity @s[tag=zx.status.shixin] store result storage zx:work nsu.u0 int 1 run data get storage zx:work ob.u0
execute if entity @s[tag=zx.status.shixin] store result storage zx:work nsu.u1 int 1 run data get storage zx:work ob.u1
execute if entity @s[tag=zx.status.shixin] store result storage zx:work nsu.u2 int 1 run data get storage zx:work ob.u2
execute if entity @s[tag=zx.status.shixin] store result storage zx:work nsu.u3 int 1 run data get storage zx:work ob.u3


# ①.5d' 超限·锈犬(2026-10-23 批 K4): 目标带「被召唤物攻击 +30%」(zx.svul 秒数),
#   且本次投递带 sm:1b(由召唤物自己打标记) -> 这一段 ×1.30。
#   ★ 两个条件缺一不可: 只判标签会让玩家自己的伤害也吃 30%;
#     只判 sm 会让场上所有召唤物对谁都更疼。
#   ★ 只在 sm 标记存在时才多这一条选择器判定 —— 绝大多数伤害(玩家平A/技能)一行就过。
execute unless data storage zx:work a{fixed:1b} if data storage zx:work a{sm:1b} if entity @s[scores={zx.svul=1..}] run function fallendream:internal/damage/vuln_summon

# ①.5e 五世恶咒·第三世: 带 zx.fcv_3 的目标, **技能伤害**额外 ×1.20(2026-10-13 批 12)
#   【为什么单独一条、不并进 vuln_tag】vuln_tag 的 115 是夜火/噬心共用的固定值;
#     世咒要的是 120, 另起 internal/damage/vuln_fcv3, 两边互不影响。
#   【互斥口径与夜火一致】只认 fallendream:skill 且非敌方来源, 免得与夜火那条
#     对同一次伤害重复加乘(那会变成 ×1.15×1.20, 不是文案里的二选一)。
#     ★ 若目标同时带夜火和世咒三世, 两条**各**跑一次(= ×1.38)—— 那是两个不同
#       debuff 叠加, 属于预期(与"夜火 + 噬心"同族)。
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.fcv_3] if data storage zx:work a{type:"fallendream:skill"} unless data storage zx:work a{src:"enemy"} run function fallendream:internal/damage/vuln_fcv3

# ①.5e' 返汐(靴子, 2026-10-25 批 14): 目标正被海浪减速 ⇒ 受到的伤害 +0.3%/档(最多 +9%)
#   【文案】"生物受到的伤害也将根据在海浪上的移速来增加，每比初始数值慢 10% 则
#     其受到的伤害 +3%。"
#   【为什么放在**受击侧**而不是 damage_calc hook】damage_calc 每次施法只算**一遍**,
#     结果再分发给每只目标(见 api/damage) ⇒ 那里只能读施法者、读不到"这一只是不是
#     在浪上"。返汐自己的施法者侧加成走 ebb_tide/hook_calc, 受害者侧必须在这里。
#   【为什么也认敌方来源】文案只说"生物受到的伤害", 没限定来源 ⇒ 不筛 type/src。
execute unless data storage zx:work a{fixed:1b} if entity @s[scores={zx.et_e=1..}] run function fallendream:internal/damage/vuln_ebb

# ①.5e''' 涤火(超限, 2026-11-22): 目标带 zx.pf_vuln ⇒ 受到的伤害 ×1.20
#   【文案】"…使其在该「流火」或「夜火」的持续时间内受到的伤害 +20%…"
#   【为什么另起一份】vuln_tag 里的 115 是夜火/噬心共用的固定值(同世咒 vuln_fcv3 的理由)。
#   【不筛来源/类型】文案只写"受到的伤害"（与返汐 vuln_ebb 同口径）。
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.pf_vuln] run function fallendream:equipment/armor/purge_fire/vuln

# ①.5e'' 迟暮(护腿, 2026-10-25 用户原稿): 受到伤害 ⇒ 立即清除抗性提升Ⅴ
#   【文案】"累计消耗 3 层「回光」后获得 15 秒抗性提升Ⅴ，若受到伤害则立即清除抗性提升。"
#   【判据】zx.ld_r5 = 那个抗性的到期时刻（≥1 = 是我们给的, 才允许清）
#     —— 用标记而不是无条件 `effect clear`, 免得把别的来源的扛性一起抹掉。
#   【为什么在受击侧最前面】它只跟"我挨打了"有关, 与其他乘区无交集。
execute if entity @s[type=minecraft:player,scores={zx.ld_r5=1..}] run effect clear @s minecraft:resistance
execute if entity @s[type=minecraft:player,scores={zx.ld_r5=1..}] run scoreboard players set @s zx.ld_r5 0

# ①.5f 燧行套装(批次 15-4): 目标带「流火」时, 施法者的"基础攻击力类"技能伤害 ×1.12
#   【为什么排在 vuln_tag / 世咒之后】它们都是"乘在 a.num 上"的乘区, 先乘谁结果一样;
#     排在一起读起来是一条线:"受击侧乘区依次乘上去"。
#   【为什么必须在 deal **之前**】它改的是"这一下要打出去多少"(a.num), deal 之后
#     再改就没有消费者了。所以本段与 ①.6 的世咒记录都落在 deal 前。
#   【判据分工】"目标带流火"在本地判(entity @s); "施法者穿齐两件 + 本次走 atk 通道"
#     由被调函数判 —— 它需要 ob 里的施法者 UUID, 只能用宏展开。
execute unless data storage zx:work a{fixed:1b} if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.liuhuo] run function fallendream:equipment/armor/smoke_step/set_burn with storage zx:work ob

# ①.5g 缝心套装(批次 15-4): 对带「噬心」的目标造成**真实伤害**时, 有「绯结」就消耗 1 层,
#   这一段真伤 ×1.15(独立乘区) + 施法者 2 秒抗性提升Ⅰ(该强化 5 秒节流)
#   【为什么排在 deal **之前**】"这一段真实伤害提高 15%"改的是 a.num。
#   【判据】本地判"目标带噬心"(与 ①.8 殓丝同条件); 施法者侧的"穿齐两件 / 有绯结 /
#     节流 / 消耗"全在被调函数里(它需要 ob 的 UUID 才能反查到人)。
#   ★ 与 ①.8 是**两件事**: 殓丝(副手)换「殓结」, 缝心(胸甲)吃「绯结」的现成增益 ——
#     同条件不同装备, 各跑各的, 互不影响(两件可以同时带)。
execute unless data storage zx:work a{fixed:1b} if data storage zx:work ob{type:"fallendream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function fallendream:equipment/armor/crimson_seam/set_true_hit with storage zx:work ob

# ①.5h 明烛(批 14, 2026-10-25): 对带「流火」的目标造成伤害 ⇒ 在其位置召唤「烛火」
#   【为什么挂在 one 而不是进度】"造成伤害"要覆盖近战 / 弩 / 技能 / 真伤**全部来源**,
#     而进度只覆盖原版事件那几种(与 ①.5 空枕那条同一条理由)。
#   【判据分工】本地只判"目标带流火"; 施法者侧的"戴着明烛吗 / 8 秒节流"全在
#     被调函数里(它要用 ob 的 UUID 反查到人)。选不到人 = 无归属伤害, 自然跳过。

# ①.5i 借火(批 14, 2026-10-25): 对**在燃烧**的生物造成伤害 ⇒ 下一次平A 充能
#   【判据分工】本地只判"目标在燃烧"; 施法者侧的"穿没穿借火"在被调函数里。
#   ★ `type=!player`: 这一条要读目标的 Fire(NBT), 玩家 NBT 序列化 ≈10ms/次
#     —— 对玩家目标一律跳过(卡顿坑 1)。

# 缚烬：流火与原版缓慢必须同时成立，非固定段才乘 1.5。
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.status.liuhuo] if data entity @s active_effects[{id:"minecraft:slowness"}] run function fallendream:equipment/axe/bind_ember/multiply with storage zx:work a

# 痛楚（2026-11-01）：带 zx.pn_vul 的目标，受到的伤害 ×1.1（固定伤害不吃）。
#   与 vuln_tag / stg_mul 同一口径：以当前 a.num 为底、累积式改写。
execute if entity @s[tag=zx.pn_vul] unless data storage zx:work a{fixed:1b} run function fallendream:equipment/axe/throe/vuln

# 倾囊超限（批 K8）：这一笔带「固定伤害追伤」窗口 → 先把 psadd 并进 a.fixed_add
#   ★ 必须在下面 fixed_add 那行之前：fixed_add 负责把 a.fixed_add 加进 a.num 并重算
#     num_str，之后再改 fixed_add 就没有消费者了。
execute if data storage zx:work psadd run function fallendream:equipment/staff/pour_sack/ol_apply

execute if data storage zx:work a.fixed_add run function fallendream:internal/damage/fixed_add

# ①.6 五世恶咒·第五世: 记录窗口开着时, 把这一下累计进 zx.fcv_rec(2026-10-13 批 12)
#   【为什么放在 deal **之前**】此时 a.num 已是最终伤害(升痕/易伤都算完了),
#     记到的是"实际要打出去多少"; 放到 deal 之后再读就已经被别的调用点改过了。
execute if entity @s[tag=zx.fcv_5] run function fallendream:equipment/staff/five_curses/record

# ①.6b 迟暮「记录接下来 5 秒其受到的伤害」(2026-10-25 用户原稿)
#   【为什么放在 deal **之前**】同 ①.6: 此时 a.num 已是最终伤害, 记到的是"实际打出去多少"。
#   【★ 记全部来源 ★】文案是"其受到的伤害", 不区分谁打的 ⇒ 只按"窗口开着没有"判,
#     由 late_dusk/record 自己判 zx.ld_rt。
execute if entity @s[tag=zx.lr_watch] run function fallendream:equipment/armor/late_dusk/watch

# 夜缚的弹射引用这一段最终技能数值；千分单位保留小数。
execute if data storage zx:work a{nb_measure:1b} store result score @s zx.nb_extra run data get storage zx:work a.num 1000

# ② 打伤害(有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来)
execute if entity @s[tag=sd.hk.body] run function fallendream:boss/husk/hurt/before_skill
# Per-invocation result stack remains valid across recursive proc damage.
execute unless data storage zx:work hit_success_stack run data modify storage zx:work hit_success_stack set value []
data modify storage zx:work hit_success_stack append value {result:{ok:0b},was:{}}
execute if entity @s[tag=zx.status.liuhuo] run data modify storage zx:work hit_success_stack[-1].was.liuhuo set value 1b
execute if entity @s[tag=zx.status.dream] run data modify storage zx:work hit_success_stack[-1].was.dream set value 1b
scoreboard players set #hit_fire zx.meta 0
execute store result score #hit_fire zx.meta run data get entity @s Fire
execute if score #hit_fire zx.meta matches 1.. run data modify storage zx:work hit_success_stack[-1].was.burning set value 1b
execute if entity @s[tag=zx.status.shixin] run data modify storage zx:work hit_success_stack[-1].was.shixin set value 1b
execute unless data storage zx:work ob{src:"enemy"} run function fallendream:lib/damage_text/before with storage zx:work a
execute if entity @s[tag=zx.j_eroded] unless data storage zx:work a{fixed:1b} run function fallendream:profession/twin/vulnerability
data modify storage zx:work hit_success_stack[-1].s2_source set from storage zx:work ob
function fallendream:equipment/armor/rebirth_veil/open
function fallendream:internal/damage/deal with storage zx:work a
function fallendream:equipment/armor/rebirth_veil/after
execute if entity @s[tag=sd.hk.body] run data modify storage fallendream:husk skill_kind set value {dot:0b}
execute if entity @s[tag=sd.hk.body] if data storage zx:work ob{dot:1b} run data modify storage fallendream:husk skill_kind.dot set value 1b
execute if entity @s[tag=sd.hk.body] run function fallendream:boss/husk/hurt/after_skill with storage zx:work ob
function fallendream:lib/damage_text/after
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work hit_success_stack[-1].was{shixin:1b} unless data storage zx:work ob{src:"enemy"} run function fallendream:internal/attack/needle_damage
execute unless data storage zx:work ob{src:"enemy"} run function fallendream:internal/attack/from_damage
execute if score #native_active zx.meta matches 1 unless entity @s[type=minecraft:player] if entity @s[type=#fallendream:living] run function fallendream:internal/native/stamp
execute if entity @s[tag=zx.lr_watch] run function fallendream:equipment/armor/late_dusk/watch
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.liuhuo] run function fallendream:equipment/armor/bright_candle/on_hit with storage zx:work ob
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} unless data storage zx:work ob{src:"enemy"} unless entity @s[type=minecraft:player] run function fallendream:equipment/armor/borrow_fire/on_hit with storage zx:work ob
execute if entity @s[type=player] run function fallendream:equipment/tool/retro_shine/from_skill with storage zx:work ob

# ①.9a 超限·息影(2026-11-23): 被"冷却减半"武装的技能命中 -> 给每只目标附随机一大标签
#   【信号来自 hook_calc(施法者侧 calc)】zx:work fd.tag=1b；calc 每次施法只算一遍,
#     范围伤害的每只目标在这里各掷一次(stellar_elegy 同款)。
#   【为什么排 deal 之后】文案是"受到伤害的生物"——打得出去才算命中。
#   【敌方伤害不算】doc:"该装备…释放的技能", src:enemy 不是玩家主动技能。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work fd.tag if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/fade/rnd_tag

# ①.9 批 15-4 · 潮线的两段(顺序不可反, 见下)
#   ① 潮线**套装**: 技能伤害命中**已带「渊海」**的生物 -> 主手主动技能冷却 -2 秒(6 秒节流)
#   ② 候潮(单件):  主动技能命中生物 -> 耗 30 魔力给它挂「渊海」(10 秒节流)
#   ★ 顺序必须是"先判套装、再挂渊海" ★
#     套装文案是"命中了**附有**渊海的生物" —— 指命中那一刻它已经带着;
#     若先跑候潮把渊海挂上去, 本次刚挂上的渊海会让套装**也**跟着触发 =
#     "打谁都减冷却"。这是那种不报错、只是悄悄变强的错。
#   ★ 都排在 deal **之后** ★
#     (a) 两段文案都写"命中了…后";
#     (b) 挂上去的渊海不该回头影响这一击的受击侧乘区。
#   ★ 都只在"本包技能伤害、非敌方来源"时进 ★(敌方技能走 src:"enemy", 不是玩家主动技能)
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.yuanhai] run function fallendream:equipment/armor/beach_vein/set_cd with storage zx:work ob
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/tide_watch/on_skill_hit with storage zx:work ob

# ①.9b0 超限·焦衣(2026-11-22): 攻击**被本件偷过基础攻击力**的生物
#   -> 追加一次"相当于自身基础攻击力"的伤害。
#   【文案】"自身攻击被偷取了任意属性的生物时都会使其额外受到一次相当于自身基础
#     攻击力的伤害。"
#   【★ 必须排在 ①.9b（转化）**之前** ★】zx.cc_steal 是 ①.9b 才打上的; 排在它后面的话,
#     刚偷完的这一击会**当场**追加一次 —— 而文案是"之后…时"。排在前面的副作用是
#     "偷完的那一下不追加"，正是想要的。
#   【本地只判两件便宜事】受害者带 zx.cc_steal + 这一笔不是固定伤害（防自我递归）。
#     "穿没穿超限焦衣 / 攻击者是谁 / 基础攻击力多少"全在子文件里（要反查玩家）。
#   【★ ob → nsu ★】ob 只许 with_from / one / stg_mul 碰；子文件只读 nsu（与 ①.5g 同做法）。
#     只有带标记的目标才做这 4 次 data get，普通命中一行选择器就过。
execute if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} run data modify storage zx:work nsu set value {u0:0,u1:0,u2:0,u3:0}
execute if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} store result storage zx:work nsu.u0 int 1 run data get storage zx:work ob.u0
execute if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} store result storage zx:work nsu.u1 int 1 run data get storage zx:work ob.u1
execute if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} store result storage zx:work nsu.u2 int 1 run data get storage zx:work ob.u2
execute if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} store result storage zx:work nsu.u3 int 1 run data get storage zx:work ob.u3
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if entity @s[tag=zx.cc_steal] unless data storage zx:work a{fixed:1b} unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/char_coat/ol_hit with storage zx:work nsu

# ①.9b 焦衣(批 15-4): 主动技能命中"带流火、未带夜火"的生物 -> 耗 80 魔力把流火升级成夜火
#   【必须在 deal **之后**】夜火的受击侧效果是"受到技能伤害 +15%"(vuln_tag)。
#     若在 deal 之前升级, 这一击会当场多吃 15% —— 而文案写的是"命中了…**后**转化"。
#   【"转化"走 tag/unmark + tag/mark】不是 mark_consume: 流火是"变成"夜火, 不是被消耗,
#     走消耗入口会白触发余烬/回潮扣/烛跬那些"消耗"被动。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run function fallendream:equipment/armor/char_coat/on_skill_hit with storage zx:work ob

# ①.9b2 超限·沸痕(2026-11-22): 挨过火伤后的 4 秒窗口里, **第一次**技能伤害命中生物
#   -> 附加「流火」; 若其原本已有「流火」而未附「夜火」, 则转化为「夜火」。
#   【为什么排在这里和焦衣同段】同样是"命中了…后"、同样要避开夜火的当场 +15% 受击乘区。
#   【两个条件在子文件里判】"穿着超限沸痕 + 窗口还开着"要靠 ob 的 u0..u3 反查玩家, 写
#     在这里等于每次技能命中都反查一次; 但这里**没有**更便宜的判据(施法者身份只在 ob 里),
#     与 221 行候潮同款做法。窗口兑现后由子文件立刻清零 => 只会命中一次。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:skill"} unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/boil_trace/ol_hit with storage zx:work ob

# ①.9b4 涤火·超限(2026-11-22): 对"本件给它上过标记"的生物造成一次伤害
#   -> 自身基础攻击力 +1（每次单独持续 12 秒, 8 槽轮转）
#   【文案】"…且自身每对其造成一次伤害则自身基础攻击力 +1，每次单独持续 12 秒。"
#   【为什么排在 deal 之后】改的是**之后**的伤害, 不是这一击; 排在前面会让本击也吃到
#     一个刚加的 1 点攻击力(虽然影响极小, 但口径上不该)。
#   【调用处先本地判 zx.pf_tgt】没被涤火标记过的目标连一次 u_by 都不做。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if entity @s[tag=zx.pf_tgt] unless data storage zx:work ob{src:"enemy"} run function fallendream:equipment/armor/purge_fire/stack_hit with storage zx:work ob

# ①.9c 迟暮·消耗「回光」(护腿, 2026-10-25 用户原稿)
#   【文案】"自身对附有「白昼梦」的生物造成伤害时消耗一层「回光」，之后使其时停
#     2 秒并记录接下来 5 秒其受到的伤害。"
#   【为什么排在 deal 之后】文案是"造成伤害时" —— 这一击已经打出去了才算数。
#   【★ 只对非玩家目标 ★】白昼梦只贴非玩家活体（tag/mark 的既有口径）, 这里跟它对齐。
#   【★ 传的是 ob 的 u0..u3 ★】要反查**动手的人**才能扣他身上的回光;
#     裸调会因为缺 $(u0) 整段跳过（宏行规则）。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if entity @s[type=!minecraft:player,tag=zx.status.dream] run function fallendream:equipment/armor/late_dusk/hit with storage zx:work ob

# ①.8b 绯缝(批 15-4): 同条件下**直接回血**(最大生命值 5%, 6 秒节流)
#   【与 ①.8 是两件不同装备】殓丝是副手(换「殓结」)、绯缝是胸甲(直接回血);
#     两件可以同时带：先做不消耗噬心的回血，再让殓丝消耗，避免同一击漏判。
#   【排在 deal 之后】文案是"命中了…后"; 且回血不该回头影响这一击。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function fallendream:equipment/armor/crimson_seam/on_true_hit with storage zx:work ob

# ①.8 殓丝: 这一下是**真实伤害**且目标还带着「噬心」-> 交给持殓丝的玩家去换「殓结」
#   【为什么排在 deal 之后】文案写"且仍存活"，由 on_true_hit 显式检查 Health。
#   【为什么读 ob 而不是 a】deal 里可能有嵌套调用改过 zx:work a; ob 是本批不可变快照。
#   【为什么不用 a.type 而用 ob.type】同理 —— a 在 deal 之后已经不可信。
#   【只认"自身造成"】src:"enemy" 的敌方真伤不算(它不是玩家打出来的)。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{type:"fallendream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function fallendream:equipment/tool/coffin_silk/on_true_hit with storage zx:work ob

# ①.10 剖面(批 14, 2026-10-25): 对带「噬心」的生物造成伤害 ⇒ 命中次数 +1(满 3 次兑现)
#   【为什么排在 deal 之后】文案是"造成 3 次伤害**后**"; 且兑现的回血不该回头影响这一击。
#   ★ 原版平A 不经过这里 ⇒ 那一路由进度 equipment/armor/profile_hit 补(见 hit_melee)。
#   ★ 两条路都进 profile/count, 它内部用 zx.pf_hl 做"同刻同目标"去重。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function fallendream:equipment/armor/profile/count with storage zx:work ob

# ①.11 套装·剖脉(批 14, 2026-10-25): 对**同时**带「噬心」和「泵动」的生物造成伤害
#   ⇒ 立即触发一次剖面的全部效果 + 两者各 +1 秒（每只 10 秒一次）
#   【为什么排在 ①.10 之后】套装是"在这一击之上再补一份", 先记满三下再补, 顺序不影响数值。
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin,tag=zx.hv_pump] run function fallendream:equipment/armor/profile/set_bonus with storage zx:work ob

# 圣骸: 保留准确受害者上下文, 已死后不要再用 @e 查找。归属读取不可变的 ob。
function fallendream:equipment/axe/sacred_relic/skill_kill with storage zx:work ob

# ③ (2026-10-12 坑 138 已删) 这里原本是"带标签 + 这一下打死了 ⇒ 调
#   dusk_dawn/kill_mark_from_skill 让攻击者补 +100×X"。随附魔回调方案一并废弃
#   (原版 post_attack 只读攻击者主手物品, 附魔挂在靴子上不触发 ⇒ 这行从来没生效)。
#   现在技能击杀也走原版 player_killed_entity 进度: 本包技能伤害都带 `by <玩家>`
#   (见 internal/damage/deal), 击杀会正常归到玩家头上, 5 条标签进度照常触发。

execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{wound_hit:1b} run tag @s add zx.ws_landed
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{chorus_final:1b} run tag @s add zx.cs_final_hit
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{weave_hit:1b} run tag @s add zx.weave_landed
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{burial_hit:1b} run tag @s add zx.burial_landed
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{s2_echo:1b} run data modify storage zx:b21 echo_stack[-1].ok set value 1b
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} if data storage zx:work ob{s2_scene:1b} run tag @s add zx.s2_scene_landed
# Always pop after all victim-side callbacks; nested one calls have their own entry.
execute if entity @s[tag=zx.pn_vul] run function fallendream:equipment/axe/throe/stamp
execute if data storage zx:work hit_success_stack[-1].result{ok:1b} unless data storage zx:work hit_success_stack[-1].s2_source{src:"enemy"} run function fallendream:equipment/staff/fate_thread/damage_adapter
function fallendream:internal/attack/finish_damage_event
data remove storage zx:work hit_success_stack[-1]
