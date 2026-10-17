# ============================================================
# sweetdream:internal/damage/one —— 对"一个"目标打伤害(宏 {num_str,type,u0..u3})
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

# ①.5c 天穹「升痕」加伤: 目标带升痕 + 这一击"来自比它更高处" -> 本次伤害 ×(1+5%×层数)
#   【开销】平时(目标没升痕)只多一条选择器判定; 走这条的只有被天穹打过、且被居高临下
#   命中的生物, 很罕见。stg_mul 的宏参数用 $(u0).., 上面刚复原过, 一定在。
#   stg_mul 满足条件时会**就地覆盖** a.num / a.damage / a.num_str(交给下面的 deal)。
execute if score #stg zx.meta matches 1.. run function sweetdream:internal/damage/stg_mul with storage zx:work a

# ①.5d 通用标签的"受击侧加乘"(2026-10-06 加)
#   · 夜火: 受到技能伤害 +15%  —— "技能伤害"包含两种来源:
#       ① 本包技能类型 sweetdream:skill(玩家侧);
#       ② 敌方技能(src:"enemy", 走 api/enemy_damage)。
#     ★ 两条分支**必须互斥**: 若敌方技能同时也用了 sweetdream:skill 类型, 两个条件会同时
#       成立 -> vuln_tag 跑两次 = +32%(而不是 +15%)。所以第一条多带一个
#       `unless ... src:"enemy"`(敌方技能只走第二条)。
#   · 噬心: 受到真实伤害 +15%  (type = sweetdream:true_damage; 敌方的真实伤害同样适用)
#     ★ 若某一下既是"敌方技能"又是"真实伤害", 且目标同时带夜火+噬心 -> 两条各 +15%
#       (×1.3225)。这是两个**不同标签**叠在一起, 属于预期(它们不是同一条加成)。
#   ★ 必须是"目标带标签 + 这一下的伤害类型/来源对得上"两个条件都成立; 共用同一个
#     internal/damage/vuln_tag。
#   ★ 放在 stg_mul(升痕)**之后**: vuln_tag 以当前 a.num 为底, 语义是"升痕算完再乘一道";
#     反过来(以 ob.num 为底)会让两者互相顶掉, 只生效一个。
execute if entity @s[tag=zx.status.yehuo] if data storage zx:work a{type:"sweetdream:skill"} unless data storage zx:work a{src:"enemy"} run function sweetdream:internal/damage/vuln_tag
execute if entity @s[tag=zx.status.yehuo] if data storage zx:work a{src:"enemy"} run function sweetdream:internal/damage/vuln_tag
execute if data storage zx:work a{type:"sweetdream:true_damage"} if entity @s[tag=zx.status.shixin] run function sweetdream:internal/damage/vuln_tag

# ①.5e 五世恶咒·第三世: 带 zx.fcv_3 的目标, **技能伤害**额外 ×1.20(2026-10-13 批 12)
#   【为什么单独一条、不并进 vuln_tag】vuln_tag 的 115 是夜火/噬心共用的固定值;
#     世咒要的是 120, 另起 internal/damage/vuln_fcv3, 两边互不影响。
#   【互斥口径与夜火一致】只认 sweetdream:skill 且非敌方来源, 免得与夜火那条
#     对同一次伤害重复加乘(那会变成 ×1.15×1.20, 不是文案里的二选一)。
#     ★ 若目标同时带夜火和世咒三世, 两条**各**跑一次(= ×1.38)—— 那是两个不同
#       debuff 叠加, 属于预期(与"夜火 + 噬心"同族)。
execute if entity @s[tag=zx.fcv_3] if data storage zx:work a{type:"sweetdream:skill"} unless data storage zx:work a{src:"enemy"} run function sweetdream:internal/damage/vuln_fcv3

# ①.5f 燧行套装(批次 15-4): 目标带「流火」时, 施法者的"基础攻击力类"技能伤害 ×1.12
#   【为什么排在 vuln_tag / 世咒之后】它们都是"乘在 a.num 上"的乘区, 先乘谁结果一样;
#     排在一起读起来是一条线:"受击侧乘区依次乘上去"。
#   【为什么必须在 deal **之前**】它改的是"这一下要打出去多少"(a.num), deal 之后
#     再改就没有消费者了。所以本段与 ①.6 的世咒记录都落在 deal 前。
#   【判据分工】"目标带流火"在本地判(entity @s); "施法者穿齐两件 + 本次走 atk 通道"
#     由被调函数判 —— 它需要 ob 里的施法者 UUID, 只能用宏展开。
execute if data storage zx:work ob{type:"sweetdream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.liuhuo] run function sweetdream:equipment/armor/smoke_step/set_burn with storage zx:work ob

# ①.5g 缝心套装(批次 15-4): 对带「噬心」的目标造成**真实伤害**时, 有「绯结」就消耗 1 层,
#   这一段真伤 ×1.15(独立乘区) + 施法者 2 秒抗性提升Ⅰ(该强化 5 秒节流)
#   【为什么排在 deal **之前**】"这一段真实伤害提高 15%"改的是 a.num。
#   【判据】本地判"目标带噬心"(与 ①.8 殓丝同条件); 施法者侧的"穿齐两件 / 有绯结 /
#     节流 / 消耗"全在被调函数里(它需要 ob 的 UUID 才能反查到人)。
#   ★ 与 ①.8 是**两件事**: 殓丝(副手)换「殓结」, 缝心(胸甲)吃「绯结」的现成增益 ——
#     同条件不同装备, 各跑各的, 互不影响(两件可以同时带)。
execute if data storage zx:work ob{type:"sweetdream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function sweetdream:equipment/armor/crimson_seam/set_true_hit with storage zx:work ob

# ①.6 五世恶咒·第五世: 记录窗口开着时, 把这一下累计进 zx.fcv_rec(2026-10-13 批 12)
#   【为什么放在 deal **之前**】此时 a.num 已是最终伤害(升痕/易伤都算完了),
#     记到的是"实际要打出去多少"; 放到 deal 之后再读就已经被别的调用点改过了。
execute if entity @s[tag=zx.fcv_5] run function sweetdream:equipment/staff/five_curses/record

# ② 打伤害(有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来)
function sweetdream:internal/damage/deal with storage zx:work a

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
execute if data storage zx:work ob{type:"sweetdream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.yuanhai] run function sweetdream:equipment/armor/beach_vein/set_cd with storage zx:work ob
execute if data storage zx:work ob{type:"sweetdream:skill"} unless data storage zx:work ob{src:"enemy"} run function sweetdream:equipment/armor/tide_watch/on_skill_hit with storage zx:work ob

# ①.9b 焦衣(批 15-4): 主动技能命中"带流火、未带夜火"的生物 -> 耗 80 魔力把流火升级成夜火
#   【必须在 deal **之后**】夜火的受击侧效果是"受到技能伤害 +15%"(vuln_tag)。
#     若在 deal 之前升级, 这一击会当场多吃 15% —— 而文案写的是"命中了…**后**转化"。
#   【"转化"走 tag/unmark + tag/mark】不是 mark_consume: 流火是"变成"夜火, 不是被消耗,
#     走消耗入口会白触发余烬/回潮扣/烛跬那些"消耗"被动。
execute if data storage zx:work ob{type:"sweetdream:skill"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run function sweetdream:equipment/armor/char_coat/on_skill_hit with storage zx:work ob

# ①.8 殓丝: 这一下是**真实伤害**且目标还带着「噬心」-> 交给持殓丝的玩家去换「殓结」
#   【为什么排在 deal **之后**】文案写"且仍存活" —— 被打死的那一只已经从世界移除、
#     身上的「噬心」也没了, 所以放在 deal 后面才判得出"仍存活"。
#   【为什么读 ob 而不是 a】deal 里可能有嵌套调用改过 zx:work a; ob 是本批不可变快照。
#   【为什么不用 a.type 而用 ob.type】同理 —— a 在 deal 之后已经不可信。
#   【只认"自身造成"】src:"enemy" 的敌方真伤不算(它不是玩家打出来的)。
execute if data storage zx:work ob{type:"sweetdream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function sweetdream:equipment/tool/coffin_silk/on_true_hit with storage zx:work ob

# ①.8b 绯缝(批 15-4): 同条件下**直接回血**(最大生命值 5%, 6 秒节流)
#   【与 ①.8 是两件不同装备】殓丝是副手(换「殓结」)、绯缝是胸甲(直接回血);
#     两件可以同时带 ⇒ 两个钩子各跑各的。
#   【排在 deal 之后】文案是"命中了…后"; 且回血不该回头影响这一击。
execute if data storage zx:work ob{type:"sweetdream:true_damage"} unless data storage zx:work ob{src:"enemy"} if entity @s[tag=zx.status.shixin] run function sweetdream:equipment/armor/crimson_seam/on_true_hit with storage zx:work ob

# 圣骸: 保留准确受害者上下文, 已死后不要再用 @e 查找。归属读取不可变的 ob。
function sweetdream:equipment/axe/sacred_relic/skill_kill with storage zx:work ob

# ③ (2026-10-12 坑 138 已删) 这里原本是"带标签 + 这一下打死了 ⇒ 调
#   dusk_dawn/kill_mark_from_skill 让攻击者补 +100×X"。随附魔回调方案一并废弃
#   (原版 post_attack 只读攻击者主手物品, 附魔挂在靴子上不触发 ⇒ 这行从来没生效)。
#   现在技能击杀也走原版 player_killed_entity 进度: 本包技能伤害都带 `by <玩家>`
#   (见 internal/damage/deal), 击杀会正常归到玩家头上, 5 条标签进度照常触发。
