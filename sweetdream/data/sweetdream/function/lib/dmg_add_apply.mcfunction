# ============================================================
# sweetdream:lib/dmg_add_apply —— 把"加算池"按**分量级**并进最终伤害
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc —— 排在**所有加算 hook 之后、独立乘区之前**
#   (顺序由 check 规则 dmgord 盯着)。
# 【★ 口径 B(2026-10-11 用户定 · D01)★】
#   每条通道的加算只作用在**它自己那条通道的分量**上, 不再交叉作用到整段:
#       伤害 = [ seg_m×(1+add_m) + seg_a×(1+add_a) + seg_o×(1+add_o) + seg_x ] × im
#   · seg_* = calc 算好的三条通道各自分量(x1000), 读 manacore:out r.seg_*;
#   · seg_x = 固定伤害 + 生命项(x1000), 读 r.seg_x —— **不吃**任何通道加算(预留扩展点);
#   · im    = 独立乘区(calc 已落进 out r.im, 见下);
#   · add_* = 该通道加算池里的百分比(0.30 -> 30), 读 zx:work add.*。
#   ★ 与旧口径(技能级)的差: 旧写法是 (Σseg + seg_x) ×(1 + Σadd) ——
#     mm 的加成会连 atk 段一起乘、atk 的加成会连 mm 段一起乘。
#     报告验收例: 100mm + 10atk 技能 + 炽天使(+50%→atk) = 100 + 15 = **115**(旧口径给 165)。
#     玩家同时挂 mm 加成 + atk 加成时: 旧 = (100+100)×(1+0.3+0.5)=360, 现 = 130+150=280。
# 【★ 不再读快照 zx:work ch 判通道 ★】
#   分段式天然自带筛选: 没被用到的通道 seg_i = 0, 乘不乘都一样。
#   (ch 快照仍由 begonia / wrath 用来把"技能归类"分流 —— 口径 B 只改加成的
#    **作用范围**, 不改"通道筛选技能"。)
# 【★ 为什么不用裸乘 ★】seg(可达 ~2e9)×(100+add) 会越过 int32 回绕 ⇒ 全部走
#   manacore:internal/damage/mul_pct 的"除余分解"(既不溢出也不掉精度, 同 N10)。
# 【★★ A01(2026-10-11 三审): mul_pct 调用的 obj 参数必须与自己的 objective 一致 ★★】
#   本文件的分数全在 **zx.meta**, 所以每个 mul_pct 调用传 `obj:"zx.meta"`,
#   出参也读 `#mul_out zx.meta`。原来少了这个参数, mul_pct 去 manacore.math 读输入
#   ⇒ 一律读成 0 ⇒ "只要有增伤, 伤害变 0"。check.py 的 `mulobj` 规则逐处核对。
# 【★ 全 0 早退 ★】三条 add 全 0 时直接 return, 沿用 calc 已写好的 r.damage ——
#   此时两者逐位相同(seg 不带加成 ⇒ mul_pct 的 ×100÷100 是恒等), 不白绕一圈定点运算。
# 【★ 为什么 im 从 out 里读、不读 manacore:work a ★】
#   事件里 resonance/hook_calc 会经 api/formation/count 把 work a 整份重置,
#   此刻读 a.independent_multiplier 只会读到默认值(见 lib/dmg_ch 头注释)。
#   所以 calc 把 im 一并落进 manacore:out r.im。
# 【出参】无 —— 直接覆盖 manacore:out r.damage。
# ============================================================

# ---- ① 读三条加算百分比(x100; 池子里 0.30 -> 30) ----
#   一律"先归零再 store": data get 读不到时 store 不执行, 会留着上一个值。
scoreboard players set #a_m zx.meta 0
execute store result score #a_m zx.meta run data get storage zx:work add.mm 100
scoreboard players set #a_a zx.meta 0
execute store result score #a_a zx.meta run data get storage zx:work add.atk 100
scoreboard players set #a_o zx.meta 0
execute store result score #a_o zx.meta run data get storage zx:work add.oth 100

# ---- ② 三条都没有正贡献 -> 走人 ----
#   (沿用旧的 `matches 1..`: 纯负加成 / 全 0 都不施加 —— 与历史行为一致)
scoreboard players set #ax zx.meta 0
scoreboard players operation #ax zx.meta += #a_m zx.meta
scoreboard players operation #ax zx.meta += #a_a zx.meta
scoreboard players operation #ax zx.meta += #a_o zx.meta
execute unless score #ax zx.meta matches 1.. run return 0

# ---- ③ K_i = 100 + add_i(mul_pct 的 mul 档: 1.5 -> 150) ----
scoreboard players set #k_m zx.meta 100
scoreboard players operation #k_m zx.meta += #a_m zx.meta
scoreboard players set #k_a zx.meta 100
scoreboard players operation #k_a zx.meta += #a_a zx.meta
scoreboard players set #k_o zx.meta 100
scoreboard players operation #k_o zx.meta += #a_o zx.meta

# ---- ④ 读四条分量(x1000, int; 由 calc 的 ⑤b 落进 out) ----
scoreboard players set #s_m zx.meta 0
execute store result score #s_m zx.meta run data get storage manacore:out r.seg_m
scoreboard players set #s_a zx.meta 0
execute store result score #s_a zx.meta run data get storage manacore:out r.seg_a
scoreboard players set #s_o zx.meta 0
execute store result score #s_o zx.meta run data get storage manacore:out r.seg_o
scoreboard players set #s_x zx.meta 0
execute store result score #s_x zx.meta run data get storage manacore:out r.seg_x

# ---- ⑤ 各段各乘自己那条通道的 K(x100 -> x1000), 再与 seg_x 合并 ----
#   ★ mul_pct 只写 #mul_out、不动入参, 所以逐个调用互不干扰。
#   ★★ A01(2026-10-11 三审): 本文件的分数全在 **zx.meta**, 所以每个调用都必须
#      传 `obj:"zx.meta"`(mul_pct 按 $(obj) 读输入/写出参)。原来漏了这个参数 ⇒
#      mul_pct 去 manacore.math 读 #s_*/#k_* ⇒ 一律读不到(0) ⇒ 只要本轮有增伤,
#      重算结果就是 0(报告例 115 -> 0)。守门 check.py 的 `mulobj` 锁着这条接线。
function manacore:internal/damage/mul_pct {src:"#s_m",mul:"#k_m",obj:"zx.meta"}
scoreboard players operation #tot zx.meta = #mul_out zx.meta
function manacore:internal/damage/mul_pct {src:"#s_a",mul:"#k_a",obj:"zx.meta"}
scoreboard players operation #tot zx.meta += #mul_out zx.meta
function manacore:internal/damage/mul_pct {src:"#s_o",mul:"#k_o",obj:"zx.meta"}
scoreboard players operation #tot zx.meta += #mul_out zx.meta
scoreboard players operation #tot zx.meta += #s_x zx.meta

# ---- ⑥ 独立乘区(乘在"加算合并"之后) ----
#   im 由 calc 落进 out r.im; 万一没落(直接调本函数)按 ×1 兜底。
scoreboard players set #im zx.meta 0
execute store result score #im zx.meta run data get storage manacore:out r.im
execute unless data storage manacore:out r.im run scoreboard players set #im zx.meta 100
function manacore:internal/damage/mul_pct {src:"#tot",mul:"#im",obj:"zx.meta"}
scoreboard players operation #tot zx.meta = #mul_out zx.meta

# ---- ⑦ 负值夹 0(与 calc 末尾同款) + 写回 r.damage(x1000 -> double) ----
execute if score #tot zx.meta matches ..0 run scoreboard players set #tot zx.meta 0
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #tot zx.meta
