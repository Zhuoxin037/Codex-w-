# ============================================================
# sweetdream:equipment/look/toggle —— 右键观测镜: 开 / 关数值面板
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/look(consume_item) 的 rewards, 以玩家身份执行
# 【状态存在哪】玩家身上的标签 test_look_on。
#   用标签而不是 storage 的好处: 每刻刷新时可以直接 @a[tag=...] 筛人,
#   不用先查 UUID; 而且标签存在玩家数据里, 退出重进不会丢。
# 【为什么要一个临时标签】"翻转"必须先记住旧状态再改, 否则改完再判断
#   就永远得到同一个结果。
# ============================================================
# ⓪ 先撤销进度
#   【为什么必须有这一行】进度一旦授予, 就不会再"授予一次"了 —— 不撤销的话
#   这个 reward 只会跑一次, 第二次右键根本不会调用本函数。
#   所以所有"进度奖励函数"的第一件事都是把自己那条进度撤掉;
#   下一次达成条件时才会重新授予、重新触发。
advancement revoke @s only sweetdream:equipment/look

# ① 把当前状态抄进临时标签
tag @s remove test_look_tmp
execute if entity @s[tag=test_look_on] run tag @s add test_look_tmp

# ② 按旧状态翻转
execute if entity @s[tag=test_look_tmp] run tag @s remove test_look_on
execute unless entity @s[tag=test_look_tmp] run tag @s add test_look_on
tag @s remove test_look_tmp

# ③ 关掉的时候顺手清空动作栏(不然最后那行会残留两秒)
execute unless entity @s[tag=test_look_on] run title @s actionbar ""

# ④ 道具是消耗品, 但必须"下一 tick"才还回主手
#   【为什么不能同 tick】消耗流程在奖励函数跑完之后还会收尾 —— 会把主手设成
#     消耗后的结果(空), 同 tick 放进去的东西会被它覆盖掉。
#     这就是流光当初要 schedule 1t 的原因, 同一个坑。
#   【为什么不用 give】give 会塞进随便哪个空槽, 手里就空了, 下一次右键点不到它。
#   【改道具属性时】这里和 look/return_item、look/give 三处的组件列表要一起改。
tag @s add test_look_pending
schedule function sweetdream:equipment/look/return_item 1t
