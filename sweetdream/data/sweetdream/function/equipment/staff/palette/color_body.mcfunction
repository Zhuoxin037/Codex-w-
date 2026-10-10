# ============================================================
# sweetdream:equipment/staff/palette/color_body —— “色彩”的每刻逻辑(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work pc {id, rng}   【执行者】色彩 item_display   【位置】色彩处
#   id  = 这个色彩的唯一编号(标记"已打过"的生物)
#   rng = 追踪 / 存活半径(= 12 + 8×黄数)
# 【文案】“色彩”会离自身 12 格远或对 5 个生物造成伤害后自毁。
#   “色彩”会自动追踪离自身最近的生物并对其造成伤害。“色彩”不会追踪已经攻击过的生物。
# 【★ 只有这两个自毁条件, 没有任何时间限制 ★】(2026-10-08 用户定)
#   用户: "他还会随着时间消失, 但我不想让它随着时间消失, 而是严格按照我的描述来"。
#   所以这里**不再有**任何"兜底寿命 / 倒计时"(曾经加过 30 秒 || 600 刻兜底, 已删)。
#   ⇒ 场上光球正常只会在 ①(离释放者超出 rng) 或 打满阀值(见 color_hit ⑥) 时消失。
#   (想手工清场: 退世界重进 / `/reload` —— `core/load` 会 kill @e[tag=zx.pal_col]。)
# 【★ “离自身”= 离释放者(以距离对称来量)★】距离是对称的: 从色彩处量
#   "释放者在 rng 内" 等价于 "色彩在释放者 rng 内" —— 所以不必把坐标搬去释放者,
#   直接用 @a[tag=zx.mc_by,distance=..rng] 判(见 color_tick 已反查好 zx.mc_by)。
# 【"已经攻击过的生物"= 它身上 zx.pal_hit 计分项 == 本色彩 id】
#   每打过一只就把那只的 zx.pal_hit 记成 id(见 color_hit), 于是同一色彩不会再追同一只。
# 【为什么用计分项而不是标签】标签没法按色彩区分(动态名字做不出来); 计分项的值可以动态写。
# ============================================================

# ① (已删除) 原来这里是"30 秒兜底寿命"(出生时写 zx.pal_end = #now + 600, 到点自毁)。
#   ★ 2026-10-08 删: 文案里没有时间限制, 加兜底反而违反了描述(用户明确反对)。
#   步骤号保留 ②③④⑤ 不变 —— 免得 skill / color_tick / vortex 等处的"见第 N 步"引用错位。

# ② 离释放者超出 rng -> 自毁
$execute unless entity @a[tag=zx.mc_by,distance=0..$(rng),limit=1] run return run function sweetdream:equipment/staff/palette/color_end

# ③ 挑目标: rng 内、没被本色彩打过、离自己最近的一只
tag @e[tag=zx.pal_c,distance=0..] remove zx.pal_c
tag @e[tag=zx.pal_t,distance=0..] remove zx.pal_t
$tag @e[type=!#sweetdream:no_damage,distance=..$(rng)] add zx.pal_c
#   ★★ 排除"本色彩已经打过"的, 判据 = 那只的 zx.pal_hit == 本光球的 id ★★
#   ★ 2026-10-08 修(这是个静默炸了很久的坑) ★
#     原来是 `if score @s zx.pal_hit = $(id)` —— **「计分项与字面量直接比较」原版没有这个语法**:
#     `if score` 的比较符两侧**都必须是计分项**(`<t> <o> <op> <t2> <o2>`), 想跟**字面量**比
#     只能用 `matches <范围>`。所以那句替换成 `... = 7` 之后整条命令解析失败。
#     【★ 为什么一直没被发现 ★】它是一条 `$` 宏行 —— **加载期只校验"这一行有没有 $(变量)",
#       不校验替换之后的命令语法**(日志里的 "Macro without variables" 就是这么报的)。
#       于是错误被推迟到**运行期**, 而运行期一条命令解析失败 = **该行之后的命令全不执行**
#       (函数就地中断)。后果: ③ 的收尾 + ④ 移动 + ⑤ 表现 全部不跑 ——
#       玩家看到的就是"光球生成后不动、也不打人"(而 ①② 仍会跑, 所以它照样会到点/出界消失)。
#     【正确写法】宏参数先落到一个**计分项**上, 再计分项比计分项:
#       `$scoreboard players set #pal_self zx.meta $(id)`  ← 合法的字面量用法(这里是 set)
#       `... if score @s zx.pal_hit = #pal_self zx.meta`   ← 两边都是计分项 ✓
#     ★ 同一口径的另一处参考: color_hit 记 zx.pal_hit 时用的也是计分项(#pal_id zx.meta)。
$scoreboard players set #pal_self zx.meta $(id)
execute as @e[tag=zx.pal_c,distance=0..] if score @s zx.pal_hit = #pal_self zx.meta run tag @s remove zx.pal_c
tag @e[tag=zx.pal_c,distance=0..,sort=nearest,limit=1] add zx.pal_t
tag @e[tag=zx.pal_c,distance=0..] remove zx.pal_c

# ④ 朝目标飞(每刻 0.35 格); 进 1.5 格就结算
#   ★ 位移用 `positioned ^ ^ ^N` + `tp @s ~ ~ ~`(照 begonia/vortex_tick 的拉拽)——
#     方向由本条 facing 定, 不会"只朝固定方向飘"。
#   ★ 2026-10-08 用户: "速度有一点快, 稍微调慢一点(约降低 30% 移速)"。
#     原 `^ ^ ^0.5`(10 格/秒) -> `^ ^ ^0.35`(7 格/秒)。
execute at @s if entity @e[tag=zx.pal_t,distance=0..,limit=1] facing entity @e[tag=zx.pal_t,distance=0..,limit=1] feet run function sweetdream:equipment/staff/palette/visual/color_face
execute at @s if entity @e[tag=zx.pal_t,distance=0..,limit=1] facing entity @e[tag=zx.pal_t,distance=0..,limit=1] feet positioned ^ ^ ^0.35 run tp @s ~ ~ ~
execute at @s if entity @e[tag=zx.pal_t,distance=..1.5,limit=1] run function sweetdream:equipment/staff/palette/color_hit

# ⑤ 表现: 球心光晕 + 拖尾(**有两种颜色就拖两条**)
#   ★ 2026-10-08 用户: "有什么颜色就在后面给上对应的拖尾……如果有两种颜色就加两种"。
#   ★ 拖尾方向 = 朝目标的**反方向**(与 ④ 同款 facing + positioned ^ ^ ^-0.4)
#     ⇒ 正好落在光球的来路上; 主色放"后方偏右"、次色放"后方偏左" ⇒ 两条并排,
#     一眼能看出是两种颜色(不会混成第三种色)。
#   ★ 两处都跑同一套颜色分支, 只是执行位置不同:
#       球心光晕 = 直接调(位置就是 @s);  拖尾 = positioned 到后方再调。
#     颜色取值: 主色 `data.zx.pal.c`(fx_main) / 次色 `data.zx.pal.c2`(fx_second);
#     单色光球 c2 = 0 ⇒ fx_second 一个粒子都不出 ⇒ 只有一条拖尾。
function sweetdream:equipment/staff/palette/fx_main
execute at @s if entity @e[tag=zx.pal_t,distance=0..,limit=1] facing entity @e[tag=zx.pal_t,distance=0..,limit=1] feet positioned ^0.14 ^ ^-0.4 run function sweetdream:equipment/staff/palette/fx_main
execute at @s if entity @e[tag=zx.pal_t,distance=0..,limit=1] facing entity @e[tag=zx.pal_t,distance=0..,limit=1] feet positioned ^-0.14 ^ ^-0.4 run function sweetdream:equipment/staff/palette/fx_second

# ⑥ 收尾: 摘掉挑选标记
tag @e[tag=zx.pal_t,distance=0..] remove zx.pal_t
