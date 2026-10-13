# ============================================================
# sweetdream:equipment/staff/gate —— 法杖普攻的**间隔门控**(0.5 秒 = 10 刻)
# ------------------------------------------------------------
# 【执行者】玩家 @s    【调用者】各法杖的 attack.mcfunction(**扣魔力之前**)
# 【用法】两行(各法杖 attack.mcfunction 里):
#     function sweetdream:equipment/staff/gate
#     execute if score #st_gate zx.meta matches 0 run return fail
#   ★ 为什么不用更短的 `execute unless function 本文件 run return fail`:
#     `if/unless function` 是 1.20.2 才加的子命令, 本项目**没有任何一处**用过它,
#     也没有 1.21.5 的实机验证记录 —— 而一旦它不被支持, 写法失效的表现是
#     "整函数作废 + 零日志", 14 个法杖普攻会**全部静默失效**(静默三兄弟的同款死法)。
#     ⇒ 宁可多写一行, 用最普通的"标志位 + 普通调用"。
#   ★ #st_gate 是假玩家, 但不会串号: mcfunction 是**串行**执行的, 一个玩家的
#     attack(含 gate + 紧跟着的判据)整个跑完才轮到下一个玩家。
# 【为什么不用技能冷却】文案里法杖普攻**不进冷却**(只有主动技能才有 80/120 秒那种),
#   走 api/skill/check 会在物品上挂一个 0.5 秒的冷却条、还改物品外观 —— 不是要的效果。
#   这里只做"最短间隔", 不碰冷却系统。
# 【★ 先置零再取值 ★】坑 141 同款: 计分项**从未赋值**时任何 `matches` / 比较都拿不到
#   想要的结果(甚至让门控静默失效)。所以先把假玩家 #st_gcd 归零, 再 store 过去 ——
#   没打过时间戳的玩家取到 0, `0 > #now` 恒假 ⇒ 放行(正是首次攻击该有的行为)。
# 【时间戳为什么要存"到期刻"而不是倒数】#now 是持久化 tick 计数, 跨 /reload 连续;
#   存"到期时刻"就不需要每刻有人去扣它, 也没有"玩家下线期间倒计时不走"的问题。
# ============================================================

# ⓪ 默认放行
scoreboard players set #st_gate zx.meta 1

# ① 取出"下一次允许普攻的时刻"(没打过就是 0)
scoreboard players set #st_gcd zx.meta 0
execute store result score #st_gcd zx.meta run scoreboard players get @s zx.staff_gcd

# ② 还没到点 → 拦下(不扣魔力、不出球)
execute if score #st_gcd zx.meta > #now manacore.meta run scoreboard players set #st_gate zx.meta 0
execute if score #st_gcd zx.meta > #now manacore.meta run return fail

# ③ 放行 → 打上新的到期时刻(现在 + 10 刻 = 0.5 秒)
scoreboard players operation @s zx.staff_gcd = #now manacore.meta
scoreboard players add @s zx.staff_gcd 10
