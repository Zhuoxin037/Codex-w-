# ============================================================
# internal/damage/calc —— 技能伤害计算(三通道 + 独立乘区)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,
#          max_mana_mul, attack_mul, other_mul,   <- 三条倍率通道
#          base_attack, other_base,               <- 基数覆盖(-1 = 用通道默认基数)
#          custom_damage, health_ratio, independent_multiplier}
# 【公式】
#    伤害 =   最大魔力   x max_mana_mul
#            + 基础攻击力 x attack_mul
#            + 其他基数   x other_mul
#            + custom_damage
#            + 最大生命   x health_ratio
#    最后整体 x independent_multiplier
#
# 【★ D01 口径 B(2026-10-11 用户定): 通道加成只作用于"本通道分量" ★】
#   事件里的加算 hook 会按通道往 zx:work add 写百分比, 由 lib/dmg_add_apply 施加。
#   口径 = **分量级**(不是"整段"):
#       伤害 = [ seg_m×(1+add_m) + seg_a×(1+add_a) + seg_o×(1+add_o) + seg_x ] × im
#     其中 seg_m/seg_a/seg_o = 上面三条通道**各自**的贡献, seg_x = custom_damage + 生命项
#     (seg_x **不吃**任何通道加成 —— 目前没有"给固定伤害加成"的武器, 预留扩展点)。
#   ⇒ 本函数额外把 seg_* 与 im 落到 manacore:out(见 ⑤b), 供 dmg_add_apply 重算。
#   ★ 本函数自己算的 r.damage **仍是老式**(先求和再×im), 一字未改 —— 只在
#     "池子全 0"时被 dmg_add_apply 原样沿用(那种情况下两者逐位相同)。
# ------------------------------------------------------------
# 【★ 三条倍率通道各吃什么基数 ★】
#   max_mana_mul : 最大魔力值技能倍率, 基数 = 玩家面板 max_mana
#   attack_mul   : 基础攻击力倍率,     基数 = base_attack 字段, -1 = 面板 base_attack
#   other_mul    : 其他倍率,           基数 = other_base 字段, -1 = 面板 current_mana
#   前者给"以最大魔力结算"的技能, 中者给"以攻击力结算"的技能,
#   后者给其余口径(最常见的是"当前魔力结算", 所以默认基数就是当前魔力)。
#
# 【★ 缺省规则(很重要) ★】
#   ① 三条通道一条都没给 -> 按旧行为: 基础攻击力 x1。
#      所以老调用 `{base_attack:-1, skill_multiplier:2.0}` 结果不变。
#   ② 只要给了任意一条 -> 没给的通道一律当 0。
#      所以"最大魔力类技能"只写 max_mana_mul 就够了, **不会**再顺手加一份面板攻击力。
#
# 【为什么要把一条拆成三条】旧版只有一个 skill_multiplier, "吃什么"是靠
#   **改写 base_attack** 表达的(先读 max_mana 塞进 base_attack, 再乘 skill_multiplier)。
#   同一个字段既当"伤害基数"又当"口径开关", 于是面板上没法把三类加成分开显示,
#   也没法给某一类单独加乘区。拆开之后: 技能显式声明走哪条通道, 基数由框架取。
#
# 【旧字段兼容】skill_multiplier = attack_mul 的旧名, 只在没给 attack_mul 时生效。
#   新写的代码请直接用 attack_mul。
#
# 【定点运算】基数按 x1000, 倍率按 x100, 相乘后除回 #100 -> 结果 x1000。
#   计分板是 32 位有符号整数(上限 21.4 亿)。若两个操作数都按 x1000 相乘,
#   中间量到 x1000000, 裸数值超过约 2147 就溢出成负数, 然后被下面的
#   "matches ..0 -> 0" 夹成 0(现象就是伤害突然变 0.0d)。
#   倍率降一个数量级后中间量只有 x100000, 上限提升到约 21474。
# ★ N10(2026-10-11): 这个 21,474 依然不够 —— 报告例"max_mana 30,000 ×1.0"
#   就被顶过 int32 回绕成 0。现在四处定点乘法**全部改走
#   internal/damage/mul_pct 的"除余分解"**: 既不溢出、也不掉精度(详见该文件头)。
#   ★ Q06(2026-10-11 四审): 分解式原来还残留一条"99·倍率 ≤ int32"的暗礁
#     (与结果无关, 倍率稍大就错) —— 已由 mul_pct 的"对倍率二次分解"消掉。
#     ⇒ 本链路现在的唯一实质上限 = **结果 x1000 装得下 int32**(即伤害 ≤ 2,147,483.647)
#       + 各倍率字段自身按 x100 能装进计分板(≤ 约 2.1e7 倍)。越界的表现是回绕,
#       所以给 API 传倍率时请自己守住量级 —— 详见 mul_pct / health_part 头部。
#   ★ A01(2026-10-11 三审): mul_pct 的输入 objective 是**宏参数 $(obj)** —— 本文件
#     的分数都在 manacore.math, 所以四处调用一律传 obj:"manacore.math"。
#   ⇒ 本文件里**不应**再出现 `… *= #mul_x` / `*= #im` 这种裸乘(守门 regress 锁着)。
# 【为什么要走宏参数】倍率/固定伤害在不同技能里完全不同, 用宏参数传进来
#   就能"一个函数服务所有技能", 不必为每个技能写一份计算函数。
# 【出参】manacore:out.damage; 并抛 #manacore:event/damage_calc 供外部改算
#   ★ D01 口径 B: 另出 r.seg_m / r.seg_a / r.seg_o / r.seg_x(各 x1000 int)
#     与 r.im(= independent_multiplier ×100), 供 lib/dmg_add_apply 按分量级重算。
# 【★ 事件前后会备份/恢复 manacore:work a ★】见第 ⑥ 步 —— 事件里的 hook 会通过
#   api/* 重置这个入参节点, 不还回去调用方(skill/go、damage/deal)就读不到 target 了。
# ============================================================

# ---- ① 旧字段兼容 + 补默认(直接调 internal 时也自给自足) ----
execute unless data storage manacore:work a.attack_mul if data storage manacore:work a.skill_multiplier run data modify storage manacore:work a.attack_mul set from storage manacore:work a.skill_multiplier
execute unless data storage manacore:work a.attack_mul unless data storage manacore:work a.max_mana_mul unless data storage manacore:work a.other_mul run data modify storage manacore:work a.attack_mul set value 1.0
execute unless data storage manacore:work a.attack_mul run data modify storage manacore:work a.attack_mul set value 0.0
execute unless data storage manacore:work a.max_mana_mul run data modify storage manacore:work a.max_mana_mul set value 0.0
execute unless data storage manacore:work a.other_mul run data modify storage manacore:work a.other_mul set value 0.0
execute unless data storage manacore:work a.base_attack run data modify storage manacore:work a.base_attack set value -1.0
execute unless data storage manacore:work a.other_base run data modify storage manacore:work a.other_base set value -1.0
execute unless data storage manacore:work a.custom_damage run data modify storage manacore:work a.custom_damage set value 0.0
execute unless data storage manacore:work a.health_ratio run data modify storage manacore:work a.health_ratio set value 0.0
execute unless data storage manacore:work a.independent_multiplier run data modify storage manacore:work a.independent_multiplier set value 1.0

# ---- ② 三个基数(x1000) ----
#   一律"先归零再 store": data get 读不到时 store 不执行, 会留着上一个值。
scoreboard players set #base_a manacore.math 0
execute store result score #base_a manacore.math run data get storage manacore:work a.base_attack 1000
execute if score #base_a manacore.math matches ..-1 run function manacore:internal/damage/use_base with storage manacore:work a

scoreboard players set #base_m manacore.math 0
$execute store result score #base_m manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000

scoreboard players set #base_o manacore.math 0
execute store result score #base_o manacore.math run data get storage manacore:work a.other_base 1000
execute if score #base_o manacore.math matches ..-1 run function manacore:internal/damage/use_other with storage manacore:work a

# ---- ③ 三条倍率(x100) ----
execute store result score #mul_m manacore.math run data get storage manacore:work a.max_mana_mul 100
execute store result score #mul_a manacore.math run data get storage manacore:work a.attack_mul 100
execute store result score #mul_o manacore.math run data get storage manacore:work a.other_mul 100

# ---- ④ 三通道贡献相加(x1000) ----
# 【★ N10 修】每一条"基数 × 倍率 ÷ 100"都交给 mul_pct 做除余分解 ——
#   结果写 #mul_out, 这里再累加。顺序与原来逐字一致(基数 × 倍率, 后除回 x1000),
#   只是中间不再有"越过 int32 的裸乘"。
# 【★ D01 口径 B 修(2026-10-11)★】除了累加进 #dmg, 每一步**另存一份分量**
#   #seg_m / #seg_a / #seg_o —— 供 lib/dmg_add_apply 按"分量级"分别施加通道加成。
#   ★ #dmg 的累加逻辑**一字不动**(老路径 r.damage 保持逐位不变), 分量只是额外输出。
scoreboard players set #dmg manacore.math 0
function manacore:internal/damage/mul_pct {src:"#base_m",mul:"#mul_m",obj:"manacore.math"}
scoreboard players operation #seg_m manacore.math = #mul_out manacore.math
scoreboard players operation #dmg manacore.math += #mul_out manacore.math
function manacore:internal/damage/mul_pct {src:"#base_a",mul:"#mul_a",obj:"manacore.math"}
scoreboard players operation #seg_a manacore.math = #mul_out manacore.math
scoreboard players operation #dmg manacore.math += #mul_out manacore.math
function manacore:internal/damage/mul_pct {src:"#base_o",mul:"#mul_o",obj:"manacore.math"}
scoreboard players operation #seg_o manacore.math = #mul_out manacore.math
scoreboard players operation #dmg manacore.math += #mul_out manacore.math

# ---- ⑤ 固定伤害 + 生命项 + 独立乘区 ----
execute store result score #cd manacore.math run data get storage manacore:work a.custom_damage 1000
scoreboard players operation #dmg manacore.math += #cd manacore.math
# 【D01 口径 B】固定伤害/生命项是"第四条分量" seg_x —— 它**不吃**任何通道加算
#   (用户 2026-10-11 定: 目前没有给固定伤害加成的武器, 预留扩展点)。
scoreboard players operation #seg_x manacore.math = #cd manacore.math
execute store result score #hr manacore.math run data get storage manacore:work a.health_ratio 100
execute if score #hr manacore.math matches 1.. run function manacore:internal/damage/health_part with storage manacore:work a
execute store result score #im manacore.math run data get storage manacore:work a.independent_multiplier 100
# 【★ N10 修】独立乘区同样走 mul_pct(src 与 dst 都是 #dmg, 但 mul_pct 只写
#   #mul_out、不动入参, 所以自乘安全)。原来这里是 `*= #im` / `/= #100`。
function manacore:internal/damage/mul_pct {src:"#dmg",mul:"#im",obj:"manacore.math"}
scoreboard players operation #dmg manacore.math = #mul_out manacore.math
execute if score #dmg manacore.math matches ..0 run scoreboard players set #dmg manacore.math 0
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #dmg manacore.math

# ---- ⑤b 出参: 四条分量 + 独立乘区(给 lib/dmg_add_apply 按"分量级"重算; D01 口径 B) ----
# 【为什么必须在这里落 out】
#   加算 hook(lib/dmg_add_apply)在下面第 ⑥ 步的事件里跑, 而那时 manacore:work a
#   很可能已被 resonance/hook_calc(经 api/formation/count)整份重置 —— 于是它读不到
#   independent_multiplier。所以在抛事件**之前**把分量与 im 一起写进 manacore:out
#   (out 不受重置影响, 见第 ⑥ 步的长注)。
# 【量纲】seg_* 都是"伤害 ×1000"的整数, im = independent_multiplier ×100。
# 【谁读它】sweetdream:lib/dmg_add_apply; 其它任何消费者都不该依赖这几个键。
execute store result storage manacore:out r.seg_m int 1 run scoreboard players get #seg_m manacore.math
execute store result storage manacore:out r.seg_a int 1 run scoreboard players get #seg_a manacore.math
execute store result storage manacore:out r.seg_o int 1 run scoreboard players get #seg_o manacore.math
execute store result storage manacore:out r.seg_x int 1 run scoreboard players get #seg_x manacore.math
execute store result storage manacore:out r.im int 1 run scoreboard players get #im manacore.math

$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "calc"
# ---- ⑥ 抛事件, 并把调用上下文原样还回去(2026-10-10, 修 F07) ----
# 【★★ 为什么非备份不可 ★★】
#   事件里的 hook(共振 / 漫步冥河 / 炽天使之翼 / 狄俄尼索斯之冠 / …)会调 manacore
#   的公开 API, 而**每个** api/* 的第一行都是
#       `data modify storage manacore:work a set value {...}`
#   —— 直接把本函数的入参节点整个重置成它自己那套默认值。
#   可调用方在 calc 返回之后还要接着用这个节点:
#     · internal/skill/go    -> 读 a.target 决定"打不打", 再用 a 调 damage/apply
#     · internal/damage/deal -> 同上(calc 后立刻读 a.target)
#   ⇒ 不还回去的话: 只要施法者身上带了任何一件"会在 calc 事件里调 API"的装备,
#     **带 target 的技能就一次都打不出伤害**, 而且完全静默 —— 选择器读不到 target,
#     整段跳过, 零日志。玩家看到的是"穿了共振/漫步之后, 技能只有特效没伤害"。
# 【只还 a, 不还 out】事件里的 hook 正是要改 out.damage(见 lib/dmg_add_apply),
#   连 out 一起恢复等于把它们的加算/独立乘区全抹掉。
# 【为什么用 ctx 这个节点名】manacore:work 下没有别的 ctx 用途(已 grep 确认);
#   ctx 里只放这一份快照, 事件返回后立刻删, 不留给下一次。
data modify storage manacore:work ctx set from storage manacore:work a
function #manacore:event/damage_calc
data modify storage manacore:work a set from storage manacore:work ctx
data remove storage manacore:work ctx
