# ============================================================
# sweetdream:equipment/staff/fate_thread/ball_hit —— 命缕普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步(球的 data.hit)
# 【执行者】法球本身   【位置】命中点   【入参】entity @s data = 球的数据(含 u0..u3)
# 【技能原文】"每次普攻命中后都会在其身上留下持续 5 秒的血色丝线。期间若普攻命中了其
#   5 格内的另一个生物，则对二者分别造成一次相当于自身最大魔力值 ×0.05 的伤害，
#   并使最初的生物附加「噬心」，之后丝线消失。该效果 8 秒内不可再次触发。"
# 【★ 顺序不能换: 先结算旧丝线, 再挂新丝线 ★】
#   如果先挂新丝线, 这一发刚打出的丝线就会被当成"旧丝线"立刻结算掉。
#
# 【★★ 2026-10-17 修复(玩家报"命缕失效")：血丝从来没结算过 ★★】
#   原文是"命中了**其** 5 格内的另一个生物" —— 语义是:
#     先打 A 留下丝线; 之后打 B, 只要 B 落在 A 的 5 格内, 就结算 A、B。
#   旧版 ① 只在"**本次命中者里**找带丝线的": 而一次法球通常只命中 B 一只, A 根本
#   不在本次命中名单里 ⇒ **永远找不到 src** ⇒ 血丝一次都没结算过(零日志、不报错)。
#   现在两种都认:
#     甲 本次命中者**自己**带有效血丝(连续打同一只 A、A 附近又刚好有别的命中者)
#     乙 本次命中者 5 格内有带有效血丝的另一只(原文那种: 打 B 结算 A)
#
# 【★★ 主动连丝的结算不在这里(2026-10-17 改口径) ★★】
#   玩家复测指出: 连丝反伤"是全部伤害", 不是只有法球打的才算。于是改成
#   **core/tick 每刻比主目标血量**(见 fate_thread/watch), 任何来源(近战/别的武器/
#   别的玩家/环境/持续伤害)都会触发。原来的 player_hurt_entity 进度链
#   (fate_thread_hit) 与法球回调链(link_from_ball/link_go)都已删除 ——
#   它们各只覆盖一部分来源, 留着只会和轮询重复结算。
# ============================================================

# ① 先算出"血丝还有效"的候选(选择器不能判分, 只能先打一层临时标签)
#   ★ 半径 6: 本次命中者最多落在球那个 2.2 盒子里, src 又要在它 5 格内 ⇒ 6 够。
#   ★ 过期血丝只用这个标签过滤, 不主动摘 zx.ft_ln(清理归 settle)。
tag @e[tag=zx.ft_lnok,distance=0..] remove zx.ft_lnok
execute as @e[tag=zx.ft_ln,distance=0..6] if score @s zx.ft_ln_end > #now manacore.meta run tag @s add zx.ft_lnok

# ② 找"最初的生物"(两种情况都认)
tag @e[tag=zx.ft_src,distance=0..] remove zx.ft_src
#   甲: 本次命中者自己就带有效血丝(最近的一只)
execute as @e[tag=zx.ball_hit,tag=zx.ft_lnok,distance=0..,sort=nearest,limit=1] run tag @s add zx.ft_src
#   乙: 甲没找到 -> 以最近的那个命中者为圆心, 5 格内挑一只带有效血丝的其他生物
#       (distance=0.01.. 天然排除它自己: 不会拿"自己和自己"结算)
execute unless entity @e[tag=zx.ft_src,distance=0..,limit=1] as @e[tag=zx.ball_hit,distance=0..,sort=nearest,limit=1] at @s run tag @e[tag=zx.ft_lnok,distance=0.01..5,sort=nearest,limit=1] add zx.ft_src

# ③ 找"另一个": src 5 格内、本次也命中、且不是它自己
#   ★ 必须带"src 存在"的门控: 否则 execute at 会退回世界原点执行, 可能在 0,0,0 附近
#     误标一只当 other(虽然 ④ 还会拦一次, 但临时标签乱跑没必要)。
tag @e[tag=zx.ft_other,distance=0..] remove zx.ft_other
execute if entity @e[tag=zx.ft_src,distance=0..,limit=1] at @e[tag=zx.ft_src,distance=0..,limit=1] run tag @e[tag=zx.ball_hit,distance=0.01..5,tag=!zx.ft_src,sort=nearest,limit=1] add zx.ft_other

# ④ 两者都在才结算; 结算要以**发射者身份**做(算伤要面板、击杀归属要玩家)
execute if entity @e[tag=zx.ft_src,distance=0..,limit=1] if entity @e[tag=zx.ft_other,distance=0..,limit=1] run function sweetdream:equipment/staff/fate_thread/settle_from_ball

# ⑤ 挂新丝线(本次命中的每一只都留 5 秒血丝; 重复命中 = 刷新到期刻)
execute as @e[tag=zx.ball_hit,distance=0..] at @s run function sweetdream:equipment/staff/fate_thread/line_mark

# ⑥ 收尾(本刻现打的临时标签一律摘掉)
tag @e[tag=zx.ft_src,distance=0..] remove zx.ft_src
tag @e[tag=zx.ft_other,distance=0..] remove zx.ft_other
tag @e[tag=zx.ft_lnok,distance=0..] remove zx.ft_lnok
