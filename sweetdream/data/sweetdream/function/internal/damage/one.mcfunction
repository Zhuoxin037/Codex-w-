# ============================================================
# sweetdream:internal/damage/one —— 对"一个"目标打伤害(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只(由 with_from 用 execute as 逐个送进来)
# 【顺序很重要】
#   ①   先看它身上有没有 5 个通用标签 —— 生物一死就查不到了, 所以必须打之前看
#   ①.5 ★ 每只目标都从专用基准节点 zx:work ob 复原入参 ★
#        + 目标带「升痕」且"居高临下"时, 把伤害乘区加上
#   ②   打伤害(带 by <攻击者>, 击杀才算玩家头上) —— 走 internal/damage/deal
#   ③   如果"带标签"且"这一下把它打死了"(Health 被夹到 0.0f), 就让攻击者补 +100
#       —— 走的是和进度回调**同一条**逻辑(kill_mark_go), 那边是"差值记账",
#          所以两条路都跑也不会加两遍。
# 【★ 为什么每只都要"复原"★】见 with_from 的长注释: a 是全包共用的临时节点,
#   伤害循环里任何嵌套调用都可能动它。所以每只目标开打前, 都把 deal 需要的入参
#   从 ob(专用基准) 拉回来一次 —— 这样"每只都从同一份原始伤害起算", 加成绝不会
#   串到下一条没有升痕的命上。
# ============================================================

# ① 打之前: 它身上有任意一个通用标签吗?
scoreboard players set #dmk zx.meta 0
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.yehuo] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.shixin] run scoreboard players set #dmk zx.meta 1
execute if entity @s[tag=zx.status.dream] run scoreboard players set #dmk zx.meta 1

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

# ② 打伤害(有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来)
function sweetdream:internal/damage/deal with storage zx:work a

# ③ 带标签 + 这一下打死了 -> 让攻击者补 +100
#   【宏源用 ob 而不是 a】/damage 有可能同步触发进度回调(那边会动 a),
#   而这里只要 u0..u3(攻击者 uuid)。ob 是不可变的快照, 用它万无一失。
execute if score #dmk zx.meta matches 1 if data entity @s {Health:0.0f} run function sweetdream:equipment/armor/dusk_dawn/kill_mark_from_skill with storage zx:work ob
