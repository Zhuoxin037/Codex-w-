# ============================================================
# sweetdream:core/tick —— 每游戏刻执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/tick.json
# 【现在做四件事】都靠"先筛人/筛实体再干活", 没参与的对象开销为零:
#   · 把"自撤销型"进度整体归零(安全网, 见下)
#   · 给开着数值面板的玩家刷新动作栏(标签 @a[tag=test_look_on])
#   · 推横刀的突进(分数 zx.dash >= 1 的玩家)
#   · 推法球(场上所有 zx.ball)
# 【以后加东西】每刻的逻辑写这里; 每秒的逻辑建议挂到 #manacore:event/second。
# ============================================================

# ★ 安全网: 把"自撤销型"进度整体撤销一遍(每刻) ★
#   一次性的技术类进度(打到生物 / 使用物品 / 受击 …)必须先被撤销, 下次事件
#   才会重新授予 —— 正常情况下奖励函数第一行就自己 revoke 了, 那时这里完全是
#   空操作(撤销一条没授予的进度 = 什么都不发生)。它只在一个死角里起作用:
#   **奖励函数被跳过**(该刻命令预算打满 65536 条, 排在后面的函数整段不跑),
#   此时 revoke 不会执行, 进度永久卡在"已授予" -> 对应效果静默失效、
#   一个字都不报。真实事故 2026-10-04 04:08:55: upgrade/attack 卡住 ->
#   魔力增殖 α/β/Ω 的攻击回魔全死, 玩家描述为"升级失效了"。
#   【为什么放每刻 + 最前面】① 每刻跑才有意义 —— 那次事故恰恰发生在"每秒"
#     这一次没轮到的 tick 上; ② 它是兜底, 不能排在下面这些重活后面被拖累。
#   【开销】32 条 revoke, 相对 65536 的预算可忽略; 正常情况全是空操作。
#   清单在 lib/rearm; check.py 规则 27 盯着它的完整性。
function sweetdream:lib/rearm

# 【备份公共输入口】下面三套每刻逻辑都会写 manacore:in arg(观测镜要查术阵数量),
#   不还回去的话你在聊天栏手填的参数每刻都被冲掉 —— 见 lib/in_bak。
function sweetdream:lib/in_bak

execute as @a[tag=test_look_on] run function sweetdream:equipment/tool/look/render

# 横刀突进: 只有分数 >= 1 的玩家参与, 平时完全不参与(开销为零)
execute as @a[scores={zx.dash=1..}] at @s run function sweetdream:equipment/sword/hengdao/dash_tick

# 深海的回响 · 释放动画: 只有施法中的玩家参与(zx.de_cast 从 0 走到 33, 共 34 tick)
#   必须走每 tick 的节拍、不能借每秒被动 —— 释放动画要 20 fps 才不卡。
#   这里不加 return 兜底: anim/end 自己会摘 tag, 中途把剑丢了也照样走完计数。
execute as @a[tag=zx.de_cast] run function sweetdream:equipment/sword/deepsea_echo/anim/tick

# 深海的回响 · 连锁推进: 每人自己的倒计时 zx.de_t 归零就推一波(1 秒 = 20 tick)
#   【为什么不用 schedule】schedule 按函数名排队 + 默认 replace, 两个人同时放
#     会互相顶掉(水链少一波)。详见 cast ⑦ 的注释。
#   【顺序】先减 1 再判 <=0 —— 设 20 就正好 20 tick 后推进, 和原来的 1s 等价。
#   【开销】只对带 zx.de_run 的玩家跑, 没施法时选择器全空。
#   【链断了会自己停】最后一波在 wave_go 里调 finish, finish 摘掉 zx.de_run。
execute as @a[tag=zx.de_run] run scoreboard players remove @s zx.de_t 1
execute as @a[tag=zx.de_run,scores={zx.de_t=..0}] at @s run function sweetdream:equipment/sword/deepsea_echo/wave_self

# 冷冻: TicksFrozen 每 tick 会自己 -2(离开粉雪就衰减), 这里帮被冻住的生物续回 140,
#   这样"冻 N tick"就是真的 N tick(见 lib/freeze_hold)。
#   只对带 zx.freeze 的生物跑, 没冻住东西时开销为零。
execute in minecraft:overworld as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_nether as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_end as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold

# 法球(法杖类普攻的载体): 场上没有法球时这个选择器是空的, 开销为零
#   为什么不用 @a 而是 @e: 法球是 minecraft:marker, 要靠它自己带的数据飞,
#   和"谁在拿着法杖"无关 —— 发射出去之后你切武器、走开都不影响它。
execute in minecraft:overworld as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_nether as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_end as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data

# 标签位置每 2 tick 更新；完整状态校验固定每 20 tick，跨原版三维度。
scoreboard players add #icon_t zx.meta 1
execute if score #icon_t zx.meta matches 2.. run function sweetdream:tag/follow_all
execute if score #icon_t zx.meta matches 2.. run scoreboard players set #icon_t zx.meta 0
scoreboard players add #tag_clock zx.meta 1
execute if score #tag_clock zx.meta matches 20.. run function sweetdream:tag/second
execute if score #tag_clock zx.meta matches 20.. run scoreboard players set #tag_clock zx.meta 0

# 寒鸦逐箭快照: 给"这一刻之前就已经存在的箭"都打上 zx.cc_seen。
#   【为什么要这么绕】想把"这一发的层数/伤害"绑到**具体某一支箭**上, 就必须在
#     射击那一刻把它认出来。按"离玩家最近的一支"认会被地上插着的老箭骗
#     (以前就是栽在这上面)。而 #minecraft:tick 跑在实体刻**之前**, 所以:
#       这一刻开始时 -> 场上所有旧箭都带 zx.cc_seen
#       同一刻稍后玩家扣扳机 -> 新箭出生, 它是**唯一**不带这个标签的
#     -> shot 里用 tag=!zx.cc_seen 就能精确抓到它(连多重射击的 3 支一起抓)
#   下一次 tick 开头再把它们补上标记, 循环继续。没参与时开销为零。
#   【为什么写三行】tick 函数的执行维度默认是主世界, @e 不会跨维度。
execute in minecraft:overworld run tag @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen
execute in minecraft:the_nether run tag @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen
execute in minecraft:the_end run tag @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen

# 霜矢:「箭打中了谁」由弩上自带的附魔回调(hook_arrow / hook_victim)交给原版判定

# 焚舟: 每刻推 烈空(只对穿着焚舟的人跑)
#   攻击命中时 hurt 里的 buff_on 也会写 manacore:in arg, 所以放在
#   in_restore 之前, 让这一整段都在公共输入口的备份保护里。
execute as @a[tag=zx.im_on] at @s run function sweetdream:equipment/armor/immolate/tick

# 调试用的 /trigger: 只有刚按过的人分数 >= 1, 平时三个选择器全空。
#   它也写 manacore:in arg(查数值/清冷却都要走前置包接口), 所以放在
#   in_restore 之前, 让这一整段都在公共输入口的备份保护里。
function sweetdream:debug/tg_router

function sweetdream:lib/in_restore
