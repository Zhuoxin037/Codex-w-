$execute unless entity $(vx_uuid) run return 0

# 对它放一次闪电(超限: 对其释放**三次**闪电)
#   "几次"用 #chg_n 递给 strike(它自己数着次数递归), 免得这里写三行一模一样的命令。
scoreboard players set #chg_n zx.meta 1
execute if score @s zx.chg_ol matches 1 run scoreboard players set #chg_n zx.meta 3
$execute at $(vx_uuid) run function fallendream:equipment/axe/charge/strike

# 对它 1 格内全部生物造成"当前魔力 ×0.05"(超限 ×0.08)的伤害
#   (位置挪到目标身上 -> 里面的 distance=..1 就是"目标 1 格内")
$execute at $(vx_uuid) run function fallendream:equipment/axe/charge/hit_area

# 该武器技能冷却: 基础 -3 秒(= 60 tick) / **超限 -4 秒**(= 80 tick)
#   ★ 2026-10-10 改(用户定稿): **两种形态都减**, 但**超限版多减 1 秒**。
#     基础 give 的文案写的是 -3 秒, 超限 oldef 的文案写的是 -4 秒 ⇒ 一行里不能写死一个数。
#     写法: 先按基础 60 填, 再 `if chg_ol matches 1` 覆盖成 80(与"基础/超限共用的一行"
#     的通用解法一致 —— 保留基础值, 另起一行补超限值)。
#   ★ 为什么不能用 `@s zx.chg_mode`: 第二形态是"首次自动使用"才进的, 状态期间根本还没进;
#     而 `chg_ol` 是 cast 那一刻拍下的"这次施法是不是超限版"的快照(状态期间一直有效)。
#   ★ (旧注释保留教训) 曾经判据写成 `if … matches 0`: 还没进过第二形态的玩家身上
#     zx.chg_mode **没有分数**, `matches 0` 直接判假 ⇒ 减冷却一次都不跑(2026-10-09
#     用户报"普攻没有减冷却")。表达"没开启"一律用 `unless … matches <开启值>`。
#   ★ 注意它也在最上面那道"满蓄力闸"之后: 只有**蓄满力**的那一发平A才会减冷却。
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:charge",ticks:60}
execute if score @s zx.chg_ol matches 1 run data modify storage manacore:in arg.ticks set value 80
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

# 第二形态的代价: 每次攻击对自身造成 最大生命值 ×0.05 的伤害
execute if score @s zx.chg_mode matches 1 run function fallendream:equipment/axe/charge/self_hurt

$tag $(vx_uuid) remove zx.victim
