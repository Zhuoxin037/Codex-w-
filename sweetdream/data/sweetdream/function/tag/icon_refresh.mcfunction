# ============================================================
# sweetdream:tag/icon_refresh —— 按"现在还剩哪些标签"重算图标
# ------------------------------------------------------------
# 【执行者】被标记的那只生物(位置也在它身上)
# 【优先级】一只生物同时挂多个标签时, 只显示优先级最高的那一个图标:
#   渊海 > 流火 > 夜火 > 噬心 > 白昼梦
#   (以后真需要"多个图标并排"再说 —— 现在没有武器会叠两个。)
# 【图标怎么"换"】先把旧图标杀掉, 下一秒(或这一次)会按新的键重造一个
#   —— 比去比对旧图标文本简单得多, 也不会漏。
# ============================================================

# ① 挑出当前该显示的图标键(从上往下, 先命中先赢)
data modify storage zx:work ic.key set value ""
execute if data entity @s data.zx.status{yuanhai:1b} run data modify storage zx:work ic.key set value "sweetdream.icon.yuanhai"
execute if data storage zx:work ic{key:""} if data entity @s data.zx.status{liuhuo:1b} run data modify storage zx:work ic.key set value "sweetdream.icon.liuhuo"
execute if data storage zx:work ic{key:""} if data entity @s data.zx.status{yehuo:1b} run data modify storage zx:work ic.key set value "sweetdream.icon.yehuo"
execute if data storage zx:work ic{key:""} if data entity @s data.zx.status{shixin:1b} run data modify storage zx:work ic.key set value "sweetdream.icon.shixin"
execute if data storage zx:work ic{key:""} if data entity @s data.zx.status{dream:1b} run data modify storage zx:work ic.key set value "sweetdream.icon.dream"

# ② 把自己的图标编号搬进宏节点(后面拼标签要用)
execute store result storage zx:work ic.id int 1 run scoreboard players get @s zx.icon_id

# ③ 一个标签都不剩 -> 收掉图标 + 摘 zx.tagged + 清编号
execute if data storage zx:work ic{key:""} run tag @s remove zx.tagged
execute if data storage zx:work ic{key:""} run scoreboard players reset @s zx.icon_id
execute if data storage zx:work ic{key:""} run function sweetdream:tag/icon_kill with storage zx:work ic

# ④ 还有标签 -> 认领 + 保证图标在 + 摆到头上
execute unless data storage zx:work ic{key:""} run tag @s add zx.tagged
execute unless data storage zx:work ic{key:""} run function sweetdream:tag/icon_go with storage zx:work ic
