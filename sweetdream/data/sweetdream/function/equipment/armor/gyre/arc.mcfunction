# ============================================================
# sweetdream:equipment/armor/gyre/arc —— 回旋·绕后过程（**每刻推一步**，执行者 = 玩家）
# ------------------------------------------------------------
# 【谁调用它】core/tick（三维度）对 `zx.gyr_st=1..` 的玩家每刻一次
# 【为什么重写：用户要"有过程"】旧版把三段弧在**同一刻**连做三次 tp ——
#   观感是"啪一下瞬移到背后"，完全看不到绕行。现在拆开，每刻只做一件事：
#     st=1 走段1 → 2 只出拖尾 → 3 走段2 → 4 拖尾 → 5 走段3 → 6 拖尾 → 7 收尾(24 点)
#   总长 7 刻 ≈ 0.35 秒，肉眼能看清"侧移 → 斜后 → 背后"三段弧。
#
# 【★ 2026-10-17 第二次修：状态 0 必须不再被 tick 选中 ★】
#   用户报"一 reload 就有疯狂的挥剑声，身边也一直有蓝色粒子出来"。原因：
#   上一版用 0 表示"第 0 刻"，arc_done 收尾时又置 0，而 tick 的筛选是 `zx.gyr_st=0..99`
#   ⇒ 收尾 → 0 → 下一克又被选中 → 落点 marker 已被 arc_done 清掉 → 走 ⓪"兜底收尾"
#   → 又置 0 …… **每刻无限循环**：arc_done 里的 `player.attack.sweep` 每刻响一次
#   （听着就是疯狂挥剑），arc/arc_done 的蓝色 dust + bubble 每刻各来一遍。
#   只要分数停在 0 就停不下来；存档实测残留 80 也会掉进同一循环。reload 重开 tick
#   后立刻复现，而且**不碰任何装备**也一直在响 —— 正是用户描述的现象。
#   ⇒ 现在编号整体 +1：0 = 未激活（tick 选择器用 `1..`，0 天然停摆），
#     1..6 = 过程刻，7 = 收尾，99 = 撞墙。
#
# 【★ 为什么落点要用 marker 预先算好 ★】
#   角度必须相对**命中那一刻**的方位。旧写法每段都用 `at <目标> facing entity @s feet`
#   现场算 —— 玩家一旦移动，基准方向跟着转，第二、三段就会歪掉（绕圈而不是到背后）。
#   所以 hit 里一次性把三个落点 summon 成 marker（zx.gyr_w1/w2/w3），
#   过程里只做"tp 到那个 marker"，方位恒定。
#
# 【状态机】zx.gyr_st
#   0     = 未激活（或被收尾清过）—— tick 不选它，这是停摆的唯一出口
#   1..6  = 过程中的刻数（奇数刻走一段，偶数刻只出拖尾）
#   7     = 走完 → arc_done
#   99    = 中途撞墙 → 立刻 arc_done（24 点照打，文案说"遇到障碍即停"只限制移动）
#   其它  = 历史脏值（旧版本可能留下 0/80 这类数）→ **静默归零**，不播音效、不打人
#
# 【★ 24 点伤害无条件 ★】即使一步都没走成，收尾那条伤害照打（效果与过程并列）。
# ============================================================

# ⓪ 状态合法性：只认 1..7 与 99；0 与任何脏值一律静默归零并退出
#   ★ 这一条是"reload 后立刻安静下来"的关键 —— 脏值不许走到 arc_done 去响音效 ★
execute unless score @s zx.gyr_st matches 1..7 unless score @s zx.gyr_st matches 99 run scoreboard players set @s zx.gyr_st 0
execute unless score @s zx.gyr_st matches 1..7 unless score @s zx.gyr_st matches 99 run return 0

# ① 兜底：落点 marker 没了（玩家中途退出 / 被 /kill 清过）→ 直接收尾，别每刻空转
#   ★ 收尾会把 st 置 0，下一克就不再有资格进本函数，所以这条不会自激 ★
execute unless entity @e[tag=zx.gyr_way,distance=..32,limit=1] run function sweetdream:equipment/armor/gyre/arc_done
execute unless entity @e[tag=zx.gyr_way,distance=..32,limit=1] run return 0

# ② 撞墙 / 走完 → 收尾
execute if score @s zx.gyr_st matches 99 run function sweetdream:equipment/armor/gyre/arc_done
execute if score @s zx.gyr_st matches 99 run return 0
execute if score @s zx.gyr_st matches 7 run function sweetdream:equipment/armor/gyre/arc_done
execute if score @s zx.gyr_st matches 7 run return 0

# ③ 奇数刻：走一段（执行位置 = 该段落点 marker）
execute if score @s zx.gyr_st matches 1 at @e[tag=zx.gyr_w1,limit=1,distance=..32] run function sweetdream:equipment/armor/gyre/try_move
execute if score @s zx.gyr_st matches 3 at @e[tag=zx.gyr_w2,limit=1,distance=..32] run function sweetdream:equipment/armor/gyre/try_move
execute if score @s zx.gyr_st matches 5 at @e[tag=zx.gyr_w3,limit=1,distance=..32] run function sweetdream:equipment/armor/gyre/try_move

# ④ 每刻拖尾（奇偶都出，让弧线看得见）
execute at @s run particle minecraft:dust{color:[0.25,0.7,0.85],scale:1.2} ~ ~0.6 ~ 0.35 0.35 0.35 0.01 5 normal
execute at @s run particle minecraft:bubble ~ ~0.4 ~ 0.25 0.2 0.25 0.01 2 normal

# ⑤ 推进到下一刻（6 → 7 时下一克走 ② 收尾）
scoreboard players add @s zx.gyr_st 1
