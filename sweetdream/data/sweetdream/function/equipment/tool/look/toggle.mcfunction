# ============================================================
# sweetdream:equipment/tool/look/toggle —— 右键观测镜: 开 / 关数值面板
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/tool/look(consume_item) 的 rewards, 以玩家身份执行
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
advancement revoke @s only sweetdream:equipment/tool/look

# ① 把当前状态抄进临时标签
tag @s remove test_look_tmp
execute if entity @s[tag=test_look_on] run tag @s add test_look_tmp

# ② 按旧状态翻转
execute if entity @s[tag=test_look_tmp] run tag @s remove test_look_on
execute unless entity @s[tag=test_look_tmp] run tag @s add test_look_on
tag @s remove test_look_tmp

# ②.5 【N07 修】刚"开启"时立即刷一次缓存
#   【为什么需要】缓存是每秒刷的, 而 panel 每刻就画 —— 开面板后的头一秒里
#   render 读到的是**上一次留下的旧缓存**(以前是别人的, 现在是自己的上一轮):
#   单人开启瞬间可能先闪一段别人的/旧的装备与冷却。这里当场采一次, 消除空窗。
#   【为什么只判"开着"】关掉时不动缓存(留着无害: render 只对开着的人跑)。
execute if entity @s[tag=test_look_on] run function sweetdream:equipment/tool/look/cache

# ③ 关掉的时候顺手清空动作栏(不然最后那行会残留两秒)
execute unless entity @s[tag=test_look_on] run title @s actionbar ""

# ④ 道具是消耗品, 但必须"下一 tick"才还回手里
#   【为什么不能同 tick】消耗流程在奖励函数跑完之后还会收尾 —— 会把那个槽位设成
#     消耗后的结果(空), 同 tick 放进去的东西会被它覆盖掉。
#     这就是流光当初要 schedule 1t 的原因, 同一个坑。
#   【为什么用 give 也不行】give 会塞进随便哪个空槽, 手里就空了, 下一次右键点不到它。
#   【改道具属性时】这里和 look/return_item、look/give 三处的组件列表要一起改。
#
# 【★ 先记下"这一下是用哪只手放的" ★】本次修复的重点
#   以前 return_item 写死塞进 weapon.mainhand。把观测镜放副手右键时,
#   主手的装备会被直接覆盖掉 —— item replace 是覆盖式的, 不会掉在地上。
#   趁此刻消耗还没走完、东西还在手上, 判定槽位存进标签 zx.look_off。
#   判定顺序和通用回手线一致: 原版是"主手物品可用就先用主手", 所以先看主手。
tag @s remove zx.look_off
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["look"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["look"]}] run tag @s add zx.look_off

tag @s add test_look_pending
schedule function sweetdream:equipment/tool/look/return_item 1t
