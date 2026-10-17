# ============================================================
# sweetdream:equipment/armor/boil_trace/on_hurt —— 沸痕: 挨了火伤就把火递出去
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/boil_trace_hurt
#   触发器 entity_hurt_player，条件 damage.type.tags 含 sweetdream:fire_damage
#   ★ 那个标签是**本包自己定义的**（data/sweetdream/tags/damage_type/fire_damage.json
#     = in_fire / on_fire / lava / hot_floor / campfire）—— 不用 #minecraft:is_fire，
#     那个来自原版 jar，写错了会**静默永不触发**且我们看不到定义。
# 【执行者】玩家（挨火的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +80，最大生命值 +4。自身实际受到火焰或燃烧伤害后，
#   若 4 格内有未附有「流火」的生物，则使最近一个生物附加「流火」并为自身恢复 4 点
#   生命值，之后熄灭自身身上的火焰。该效果 8 秒内最多触发一次。
# 【★ 描述里那句"熄灭自身身上的火焰" —— 走"临时细雪", 见 ⑦ ★】
#   2026-10-16 定论(三次收敛, 前面两轮的判断都是错的):
#     ① `Fire` 对玩家**根本写不进去**。原版**禁止用命令修改玩家 NBT**: `/data` 与
#        `/execute store` 对玩家一律抛 `commands.data.entity.invalid` =
#        "Unable to modify player data"(已在 1.21.5 客户端 jar 的 en_us.json 里核到
#        该键, 引用它的正是 data 命令那个类)。历来的 `{Fire:-1s}` / `{Fire:-20s}` +
#        每刻重写(imm_tick) **全部无效**, 与负值大小无关。
#     ② **抗火也不灭火**。wiki 原文: "在Java版中, 抗火不能消除着火; 在基岩版中,
#        抗火使生物不能着火" —— 所以在 JE 里给 fire_resistance 只是"这 1 秒不吃火伤",
#        玩家身上照样在烧(用户实测反馈"火还是没灭", 与 wiki 一致)。
#     ③ ⇒ 真正能灭火的只剩"接触水/细雪": Java 版里实体**接触细雪会被熄灭**
#        ("细雪可以熄灭燃烧中的实体"), 而且**着火的实体碰到细雪会把细雪撞毁**
#        (方块直接消失, 不掉落) —— 这两个特性合起来正好: 放一块、灭完自己消失。
#   ⇒ 落地方式: 临时在玩家身上放一块细雪(见 ⑦), 由 core/tick 兜底回收。
#   用户口径(2026-10-16): **不改描述**, 按纯机制处理; 以后别再"顺手"写进描述。
# 【★ 整段都受"4 格内有目标"限制（2026-10-15 用户拍板）★】
#   最后那句"之后熄灭自身身上的火焰"也在这个"若…"里 —— 没找到目标就什么都不发生
#   （不附加、不回血、**也不熄火**）。所以下面在挑不到目标时直接 return。
# 【最大生命值 +4 不在这里做】那是常驻被动，走 armor_hp 的每秒差值注册
#   （见 equipment/armor/armor_hp/passive）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/boil_trace_hurt

# ① 没穿沸痕就没这事（胸甲）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["boil_trace"]}] run return 0

# ② 8 秒节流
scoreboard players set #bt_due zx.meta 0
execute store result score #bt_due zx.meta run scoreboard players get @s zx.boil_cd
execute if score #bt_due zx.meta > #now manacore.meta run return 0

# ③ 4 格内最近的、**未带「流火」**的生物
tag @e[tag=zx.bt_t,distance=0..] remove zx.bt_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..4,tag=!zx.status.liuhuo,sort=nearest,limit=1] add zx.bt_t

# ④ ★ 没目标 = 整段不发生（含熄火）★
execute unless entity @e[tag=zx.bt_t,distance=0..,limit=1] run return 0

# ⑤ 给它附加「流火」（附着 -> tag/mark）
data modify storage zx:work ic set value {target:"@e[tag=zx.bt_t,limit=1]",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 为自身恢复 4 点生命值（lib/heal 的入参是**整点数**）
scoreboard players set #heal_pt zx.meta 4
function sweetdream:lib/heal

# ⑦ "熄灭自身身上的火焰" —— **临时细雪**(写不了 Fire, 抗火也不灭火; 见文件头 ③)
#   【为什么放 `~ ~1 ~`(头部那格)】玩家碰撞箱是 [0, 1.8), 这一格与它必然相交 ⇒
#     原版认得到"接触" ⇒ 会熄灭+撞毁; 同时它离脚最远(玩家站着时脚在地面), 不会
#     让人"陷进细雪"里 —— 视觉上只是头顶闪过一格白(2 刻 = 0.1 秒后就被撞毁)。
#   【为什么用 keep】只在目标是**空气**时才放 —— 玩家在 1 格高的洞里、贴着天花板时
#     那格不是空气, 于是**什么都不放**(不灭火, 但也绝不破坏任何已有方块)。
#   【★ 这次是全包第一次"动方块", 有意的 ★】没有别的办法: 见文件头 ①②③。
#   【marker 锚点】细雪正常会被**正在燃烧的玩家自己**撞毁(无需我们出手); 但玩家若在
#     被 tick 到之前就跳开/走开, 那块会留下。marker 记着它的**精确坐标**, 2 刻后由
#     core/tick 派 pw_off 精确清掉(玩家跑多远都清得准), 不留隐形陷阱。
execute at @s run setblock ~ ~1 ~ minecraft:powder_snow keep
execute at @s run summon minecraft:marker ~ ~1 ~ {Tags:["zx.bt_pw","zx.bt_pw1"]}

# ⑧ 表现 + 记账 + 收尾
execute at @e[tag=zx.bt_t,limit=1] run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.03 8 normal
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.6 1.2
scoreboard players operation @s zx.boil_cd = #now manacore.meta
scoreboard players operation @s zx.boil_cd += #160 zx.meta
tag @e[tag=zx.bt_t,distance=0..] remove zx.bt_t
