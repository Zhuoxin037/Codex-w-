# ============================================================
# sweetdream:equipment/tool/look/return_item —— 延迟 1 tick, 把观测镜放回主手
# ------------------------------------------------------------
# 【谁调用它】look/toggle 里 schedule 出来的, 1 tick 后执行
# 【为什么必须延迟】消耗流程在奖励函数之后还会收尾, 会把主手设成"消耗后的
#   结果"(空)。同 tick 放回去会被它覆盖掉 —— 流光的回手踩过同一个坑。
# 【为什么用标签】schedule 出来的函数没有 @s, 只能靠标签把玩家找回来。
# 【为什么用 item replace 而不是 give】give 可能进别的槽位, 手里就空了,
#   下一次右键就点不到观测镜。
# ============================================================

execute as @a[tag=test_look_pending] run item replace entity @s weapon.mainhand with recovery_compass[minecraft:item_name={text:"观测镜",bold:true,color:"aqua"},minecraft:lore=[{text:"右键: 开 / 关 数值面板",color:"gray",italic:false}],minecraft:custom_data={zx:["look"]},minecraft:consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
tag @a[tag=test_look_pending] remove test_look_pending
