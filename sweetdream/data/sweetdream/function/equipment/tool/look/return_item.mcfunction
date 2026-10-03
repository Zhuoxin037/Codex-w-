# ============================================================
# sweetdream:equipment/tool/look/return_item —— 延迟 1 tick, 把观测镜还回手里
# ------------------------------------------------------------
# 【谁调用它】look/toggle 里 schedule 出来的, 1 tick 后执行
# 【为什么必须延迟】消耗流程在奖励函数之后还会收尾, 会把那个槽位设成"消耗后的
#   结果"(空)。同 tick 放回去会被它覆盖掉 —— 流光的回手踩过同一个坑。
# 【为什么用标签】schedule 出来的函数没有 @s, 只能靠标签把玩家找回来。
# 【为什么用 item replace 而不是 give】give 可能进别的槽位, 手里就空了,
#   下一次右键就点不到观测镜。
# ------------------------------------------------------------
# 【★ 从哪只手用, 就还回哪只手 ★】本次修复的重点
#   以前写死 weapon.mainhand。观测镜放副手右键时, 主手的装备会被直接覆盖掉
#   (item replace 是覆盖式的, 不会掉在地上, 找不回来)。
#   现在看标签 zx.look_off(toggle 在消耗那一刻判定好):
#       有   = 这一下是副手放的 -> 写回 weapon.offhand
#       没有 = 主手             -> 写回 weapon.mainhand
# 【改道具属性时】这里和 look/toggle、look/give 三处的组件列表要一起改。
# ============================================================

# ① 副手触发 -> 还回副手
execute as @a[tag=test_look_pending,tag=zx.look_off] run item replace entity @s weapon.offhand with recovery_compass[minecraft:item_name={text:"观测镜",bold:true,color:"aqua"},minecraft:lore=[{"text":"右键: 开 / 关 数值面板","color":"gray","italic":false}],minecraft:custom_data={zx:["look"]},minecraft:consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

# ② 主手触发 -> 还回主手
execute as @a[tag=test_look_pending,tag=!zx.look_off] run item replace entity @s weapon.mainhand with recovery_compass[minecraft:item_name={text:"观测镜",bold:true,color:"aqua"},minecraft:lore=[{"text":"右键: 开 / 关 数值面板","color":"gray","italic":false}],minecraft:custom_data={zx:["look"]},minecraft:consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]

# ③ 收尾: 两个标签一起清掉
tag @a[tag=test_look_pending] remove test_look_pending
tag @a[tag=zx.look_off] remove zx.look_off
