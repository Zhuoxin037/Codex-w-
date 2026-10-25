# ============================================================
# sweetdream:equipment/bow/dragon_tongue/fire —— 「龙舌」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(@s 就是射手, 因为 apply 用 as/at 送进来)
# 【技能原文(lore 逐字, 按它逐句实现)】2026-10-13 口径更新
#   「每次射击若射击附加了「夜火」效果的生物，则使其消除「夜火」并在其 2 格内
#    释放一次箭雨，箭矢随机落下并命中落点处的生物。每根箭的伤害相当于自身当前
#    魔力值 ×X×0.01，箭的数量为 X×3。X 为被命中的生物 6 格内附有「流火」或
#    「夜火」的生物数量，其中附有「夜火」的每个记为 2。」
# 【★ 顺序(很重要) ★】
#   ① 先数 X      —— 必须在**消除「夜火」之前**数。X 统计的是**箭到达那一刻**的
#      场上状态; 先把受害者的夜火消了再数, 就会少算 1(而且"改状态前先拍快照"
#      是本包铁律, 见坑 123)。
#   ② 算这一箭的伤害 —— 用射手**当前**魔力值(已扣掉这发的 60)。
#   ③ 消除「夜火」  —— 走 lib/mark_consume, 让「永恒」(不消、原地刷新)与
#      「余烬」(消掉流火/夜火给被动)两件装备正常生效。
#   ④ 放箭雨        —— 在**被打中的那只**周围 4 格内随机落 X×3 根箭;
#      ★ 随机的是**落点**, 不是"随机挑一只生物"(2026-10-13 用户反馈修正):
#      每根箭先在 4 格范围内取一个随机坐标落下, 再看那个点上站着谁 ——
#      落在空地就是空的(合法结果), 落在某只脚下就打它。详见 rain_deal。
# 【为什么伤害只算一次】"每根箭的伤害"是同一个公式(取决于射手当前魔力与 X),
#   所以算一次、给每根箭复用。伤害本身照常过 manacore 的 calc(通道加成、
#   易伤、升痕都在 internal/damage/one 里按目标逐只结算)。
# 【★ 范围怎么圈 ★】(2026-10-13 改)
#   以前是"以受害者为中心开一个边长 5 的判定箱、从里面随机挑生物" —— 那样每一根
#   箭都会**必定命中某个生物**, 玩家看到的是"群体攻击 + 一堆粒子", 与文案
#   "箭随机落下"的观感完全不符。
#   现在改成: 每根箭独立取一个**随机落点**(marker 实体搬到随机坐标),
#   再用"一支箭那么大"的判定箱(0.8×2.2×0.8)在那个点上找站着的生物。
#   于是" arrow 到底砸到谁"由**落点**决定, 而不是预先挑好的目标 ⇒ 会落空、会
#   不均分, 这才是箭雨该有的样子。
# 【★ 超限(批 K7, 2026-10-23) ★】主手那把带 ol:"dragon_tongue"(shot 已把
#   zx.dt_ol 写进玩家身上)时, 本函数有四处不同:
#     · 扣费 60 -> 100(在 shot 里);
#     · X 的**计数半径** 8 -> 10 格(① 里两档互斥);
#     · 箭雨**落点半径** 4 -> 6 格(在 rain_deal ②, 用 #800/#400 与 #1200/#600 两套互斥);
#     · 箭数 > 20 时, 箭雨结束后再加一段范围伤害 + 附「流火」(⑥.5 -> ol_burst)。
#   每根箭的伤害式子(当前魔力 × X × 0.01)、夜火记 2 点这些口径都不变。
# ============================================================

# ① X = 被打中那只 8 格内带「流火」或「夜火」的生物数(每只只数一次)
#    【★ 为什么以「受害者」为中心而不是「射手」★】2026-10-13 用户实测反馈修正:
#      原实现按**射手** 6 格数, 而弩射程远远超过 6 格 —— 站远处射一只带夜火的怪,
#      那只怪根本不在射手 6 格内 ⇒ X = 0 ⇒ 箭数 0、伤害 0, 整发技能在最常用的
#      场景里**完全空转**(夜火照样消掉, 玩家只看到一句 X=0)。
#      改成以**被打中的那只**为中心之后: 它自己带着夜火、而夜火记 2 点
#      ⇒ **X ≥ 2 恒成立**, 远距离射击也能正常放箭雨(至少 6 根),
#      与文案"在其 2 格内释放一次箭雨"的语境一致。
#    【为什么要先 tag 再数】同一只可能同时带两个标签, 直接"两个选择器各数一遍"
#    会把它数两次; 先并成一个标签 zx.dt_x 再去重计数。
#    【注意 at/as 的顺序】`execute at <受害者> as @e[...]` —— at 把**位置**搬到受害者
#    身上, as 再切换执行者; 这样后面的 distance=..6 才是相对受害者量的。
#    写成 `execute as @e[...] at @s` 会错: 那是对每个生物各自at回自己数了个寂寞。
#    【★ 夜火记 2 个 X ★】(2026-10-13 用户定口径): 夜火是比流火更"重"的标记,
#    每只带「夜火」的生物合计贡献 2 点 X(带「流火」的仍是 1 点)。
#    拆成两次累加: 先按"带任一标记"去重记 1 点(避免同时带两个的被记两次基数),
#    再给带夜火的每只**额外 +1** ⇒ 夜火 = 2、流火 = 1、两者都有 = 2(取高值)。
#    ★ 由此 X ≥ 2 恒成立: 被射中那只必定带夜火(hook_victim 的门控), 它自己就贡献 2。
tag @e[tag=zx.dt_x,distance=0..] remove zx.dt_x
execute if score @s zx.dt_ol matches 0 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=..8] run tag @s add zx.dt_x
execute if score @s zx.dt_ol matches 0 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=..8] run tag @s add zx.dt_x
execute if score @s zx.dt_ol matches 1 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=..10] run tag @s add zx.dt_x
execute if score @s zx.dt_ol matches 1 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=..10] run tag @s add zx.dt_x
scoreboard players set #dt_x zx.meta 0
execute as @e[tag=zx.dt_x,distance=0..] run scoreboard players add #dt_x zx.meta 1
execute if score @s zx.dt_ol matches 0 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=..8] run scoreboard players add #dt_x zx.meta 1
execute if score @s zx.dt_ol matches 1 at @e[tag=zx.dt_v,limit=1] as @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=..10] run scoreboard players add #dt_x zx.meta 1

# ② 这一箭的伤害 = 当前魔力 × X × 0.01
#    【走 calc 的 other 通道】other_base 默认就是"玩家当前魔力", 所以把
#    other_mul 设成 X×0.01 就正好等于文案的式子 —— 不必自己拼接定点乘法。
#    (X 现在的下界是 2, 见上面 ① 的"夜火记 2"口径。)
execute store result storage zx:work dt.mul double 0.01 run scoreboard players get #dt_x zx.meta
data modify storage manacore:in arg set value {uuid:"",other_mul:0.0,other_base:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:work dt.uuid
data modify storage manacore:in arg.other_mul set from storage zx:work dt.mul
function manacore:api/damage/calc
data modify storage zx:work dt.dmg set value 0.0
data modify storage zx:work dt.dmg set from storage manacore:out r.damage

# ③ 消除受害者身上的「夜火」(统一入口: 永恒/余烬被动在这里生效)
#    【by 传射手】"消耗者"是射手本人 —— 余烬(回蓝+力量)与永恒(原地刷新)都认它。
data modify storage zx:work a set value {target:"@e[tag=zx.dt_v,limit=1]",mark:"yehuo",by:"@a[tag=zx.dt_pl,limit=1]"}
function sweetdream:lib/mark_consume

# ④ 箭雨: 在被打中的那只周围 2 格内落 X×3 根箭
#    【★ 不再预先圈 AoE 范围 ★】2026-10-13: 旧的 zx.dt_aoe 大盒子(边长 5)已删除 ——
#     它是"从这个范围里随机挑一只生物"的配套设施, 而现在随机的是**落点**:
#     每根箭自己在 ±2 格里取随机坐标、再用"一支箭那么大"的判定箱判定(见 rain_deal)。
#     预先圈范围不但没必要, 还会让人误以为判定是按那个大盒子做的。
#    【★ X 的下界 ★】(2026-10-13 改) 被射中那只必定带「夜火」(hook_victim 的门控),
#     而夜火记 2 点 ⇒ **X ≥ 2 恒成立**, 箭雨至少有 6 根。
#     旧的"站远处射 ⇒ X = 0 ⇒ 完全没有箭雨"已不复存在 —— 那是旧口径按**射手**
#     6 格数出来的后遗症, 现改为按受害者周围搜寻后已修掉。
#     下面这句只剩**异常兜底**: X ≤ 1 意味着通用标签 zx.status.* 根本没挂上,
#     属于不该发生的情况 —— 按坑 145 的要求, 把零日志的静默点翻译成人话。
execute if score #dt_x zx.meta matches ..1 run tellraw @s [{"text":"「龙舌」: X 异常偏低(≤ 1) —— 通用标签 zx.status.yehuo / zx.status.liuhuo 可能没挂上, 请检查标签系统","color":"red"}]

#    【箭数 = X×3, 伤害与归属一起备好给循环用】
scoreboard players operation #dt_n zx.meta = #dt_x zx.meta
scoreboard players set #dt_three zx.meta 3
scoreboard players operation #dt_n zx.meta *= #dt_three zx.meta
execute store result storage zx:work dt.n int 1 run scoreboard players get #dt_n zx.meta
execute store result storage zx:work dt.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work dt.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work dt.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work dt.u3 int 1 run data get entity @s UUID[3]

# ⑤ 表现: 播一声"弓弦齐鸣"(纯听觉, 不代表任何具体根数)
#   【★ 这里不再画箭 ★】(2026-10-13) 原先 fx 里有一团固定的 60 个箭粒子, 和真正
#     结算的根数 X×3 **毫无关系** ⇒ X=1(3 根箭)时头顶却铺了 60 个粒子, 视觉/实际
#     差到几十倍, 玩家数出来的"箭的数量"永远对不上 —— 这正是用户报的"数量不对"。
#     按坑 145 的表现必须同源规则删掉了它: 箭的视觉现在**只**由 rain_deal 逐根播,
#     落一根播一处 ⇒ 有几根就有几处, 天然随 X 线性变化。
#   【为什么这行条件还是要留】X 的下界现在是 2(夜火记 2), 正常永远成立;
#     留着是异常兜底 —— X 真算成 0 时不该响"箭雨开始了"。
execute if score #dt_x zx.meta matches 1.. run function sweetdream:equipment/bow/dragon_tongue/fx with storage zx:work dt

# ⑤.5 【伤害 = 0 的兜底提示】dt.dmg 由 manacore:out r.damage 回填; 若 uuid 有问题
#   导致 calc 没跑, `set from` 会失败并留着上面的 0.0 —— 同样是"有特效没伤害"。
scoreboard players set #dt_dbg8 zx.meta 0
execute store result score #dt_dbg8 zx.meta run data get storage zx:work dt.dmg 1000
execute if score #dt_dbg8 zx.meta matches ..0 run tellraw @s [{"text":"「龙舌」: 每箭伤害算出来是 0 —— 检查当前魔力是否为 0 / manacore:out r.damage 是否取到","color":"red"}]

# ⑥ 逐箭结算(同步循环: rain_one 一次一根, 打完递归下一根)
#   【★ 两个诊断锚每次结算归零 ★】"从没写过(空白)"和"写过但是 0"在 probe 里
#    长得不一样, 而 `if score X matches ..0` 对不存在的分数恒假 —— 不归零的话
#    "循环一根都没转"这个最关键的症状会被 probe 漏掉。
scoreboard players set #dt_dbg6 zx.meta 0
scoreboard players set #dt_dbg7 zx.meta 0
scoreboard players set #dt_i zx.meta 0
function sweetdream:equipment/bow/dragon_tongue/rain_one

# ⑥.5 【超限·批 K7】箭数 > 20 -> 箭雨结束后额外一段
#   文案:「若本次箭数量超过20个则在结束后额外对范围内的生物造成一次相当于自身
#          当前魔力值 x X x0.01 的伤害并使其附加「流火」。」
#   ★ 判据用 #dt_n(= X×3, 真正的箭数), 不能用 X 本身。
#   ★ 伤害复用 dt.dmg: 它已经是"当前魔力 × X × 0.01", 与文案完全同一式子。
#   ★ 必须排在 ⑦ 清标签之前(ol_burst 要用 zx.dt_v 当圆心)。
execute if score @s zx.dt_ol matches 1 if score #dt_n zx.meta matches 21.. run function sweetdream:equipment/bow/dragon_tongue/ol_burst

# ⑦ 收尾: 清掉本次用过的计数标签(否则会污染下一箭)
#    (zx.dt_aoe 已随旧口径一并删除; zx.dt_drop / zx.dt_hit 由 rain_deal 自己管)
tag @e[tag=zx.dt_x,distance=0..] remove zx.dt_x
