# ============================================================
# sweetdream:equipment/sword/myriad/swap —— 延迟换手: 万念 <-> 千散
# ------------------------------------------------------------
# 【谁调用它】core/tick(只对带 zx.mq_swap 标签的玩家, 每刻一次)
# 【为什么必须"延迟"而不能在 cast 里直接换】
#   右键消耗那一刻, 通用回手线 internal/itembackup 会预约一个 **1 tick 后** 的
#   schedule, 把盔甲架上备份的那把剑塞回手里。如果 cast 里当场 item replace,
#   换完的新剑会在下一 tick 被那份旧备份整个覆盖 —— 现象就是"用了但没换"。
#   所以 cast 只负责预约(zx.mq_wait = 3), 由这里在几 tick 之后动刀。
#   【为什么是 3】回手在 +1 tick; 多留 2 tick 是给"这一刻命令特别多"的情况留余量。
#     换手本身是幂等的(只认预约时那把), 多等几 tick 没有副作用。
# 【方向】zx.mq_dir: 1 = 万念 -> 千散; 2 = 千散 -> 万念。
#   ★ 只认"预约时那把" ★ 这 3 tick 里玩家如果把剑丢出去 / 换了手, 下面两条
#     if items 都匹配不上, 就安静地什么都不做 —— 绝不凭空塞一把剑进他手里。
# 【为什么不用 schedule】同名 schedule 是全局一个槽, 两个玩家同时放会互相顶掉
#   (见 RULES: 深海连锁吃过这个亏)。用"标签 + 自己的计分项"逐人倒计时没有这问题。
# ------------------------------------------------------------
# 【★★ 换手之后为什么还要"中转一趟" ★★】(2026-10-08 改)
#   put_qian / put_my 是 `item replace ... with <生成器那份原始组件串>`,
#   那份串里没有 custom_data.up, 也没有 ol / 超限的名字和描述。
#   老做法是换完之后用 `data modify entity @s SelectedItem.components...` 补 ——
#   **补不上**: 玩家的 SelectedItem 是只读的虚拟路径(见 is_ol 顶部注释),
#   写进去不报错、也不生效。现象就是"放了一次技能, 刀是换成千散了,
#   但超限效果全没了; 再放一次回到普通万念"。
#   【中转用什么】一个用完即杀的临时盔甲架(summon → 物品挪过去 → 改 → 挪回来 → kill)。
#     实体的槽位 NBT 是可以写的, 而且不依赖世界里有没有某个方块。
#     ⚠️ 别再抄 station/api/apply_go 那套"箱子工作台": 那是给"敲石头"这种
#        低频、人在主世界的操作用的; 换手是每次放技能都跑的战斗路径。
# ============================================================

# ⓪ 倒计时: 还没到点就只减一次, 直接收工
scoreboard players remove @s zx.mq_wait 1
execute if score @s zx.mq_wait matches 1.. run return 0

# ① 收工: 不管最后换没换成, 预约都到此为止(不摘的话会每刻重跑一次)
tag @s remove zx.mq_swap

# ② 换手参数(宏参数只能从 storage 传, 所以先拼一份 mqk)
#      v = 换完之后手里是哪一把(决定取 oldef."<v>" 那份名字/描述)
#      h = 动哪只手(给 item replace 用的槽位名)
#      p = 同一只手的 **NBT 路径**(读物品用: 主手 SelectedItem / 副手 equipment.offhand)
data modify storage zx:work mqk set value {v:"",h:"weapon.mainhand",p:"SelectedItem"}

execute if score @s zx.mq_dir matches 1 run data modify storage zx:work mqk.v set value "qiansan"
execute if score @s zx.mq_dir matches 2 run data modify storage zx:work mqk.v set value "myriad"

#    【判据和 put_qian / put_my 完全一致】主手是"换之前那一把"就动主手,
#    否则动副手 —— 两边判歪一个就会把另一只手的东西覆盖掉。
execute if score @s zx.mq_dir matches 1 unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["myriad"]}] run data modify storage zx:work mqk.h set value "weapon.offhand"
execute if score @s zx.mq_dir matches 2 unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["qiansan"]}] run data modify storage zx:work mqk.h set value "weapon.offhand"
execute if data storage zx:work mqk{h:"weapon.offhand"} run data modify storage zx:work mqk.p set value "equipment.offhand"

# ③ 【超限快照】换手前现判一次, 不依赖 cast 留下的那个分数
function sweetdream:equipment/sword/myriad/is_ol
scoreboard players operation @s zx.mq_ol = #mq_ol zx.meta

# ④ 【升级石】换手前先把 up 列表读出来(replace 会把它整个覆盖掉, 不可逆)
function sweetdream:equipment/sword/myriad/swap_pre with storage zx:work mqk

# ⑤ 换手
execute if score @s zx.mq_dir matches 1 run function sweetdream:equipment/sword/myriad/put_qian
execute if score @s zx.mq_dir matches 2 run function sweetdream:equipment/sword/qiansan/put_my
#   (换手成功时的那声轻响在 put_qian / put_my 里, 跟着 replace 一起判 ——
#    放这里无条件响的话, 玩家中途丢刀就会"没换手却响一声")

# ⑥ 【升级石 + 超限】走工作台把 up / ol / 名字 / 描述一起补回物品上
function sweetdream:equipment/sword/myriad/swap_post with storage zx:work mqk
