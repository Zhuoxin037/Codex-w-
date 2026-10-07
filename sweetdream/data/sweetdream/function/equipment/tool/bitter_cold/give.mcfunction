# ============================================================
# sweetdream:equipment/tool/bitter_cold/give —— 给一件「苦寒」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"bitter_cold" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["bitter_cold"]}]
# 【数值要和实现对上】8 格内生物**解除冻结状态**的那一刻 -> 5 秒缓慢Ⅲ + 虚弱Ⅲ
#   + 附加「渊海」; 另外 5 格内带「渊海」的生物获得**常态**缓慢Ⅱ(一直续, 不是一次性)。
# 【★ 效果已实装(2026-10-06 晚)★】
#   · "解除冻结的那一刻" -> 挂在 lib/unfreeze_one ④(解冻是**事件**, 不能每秒轮询 ——
#     轮询会锁相漏判, 原因见 unfreeze_dim 里时停那段), 处理在
#     equipment/tool/bitter_cold/{on_thaw,thaw_victim}。
#   · "常态缓慢Ⅱ" -> 挂 manacore:event/second, 处理在
#     equipment/tool/bitter_cold/{second,aura}(每秒续 2 秒, 条件消失后自然结束)。
#   · 「渊海」用的是包里**既有的通用标签**(tag/mark, 20 秒租约 + 头顶图标), 没另造。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"苦寒",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身 8 格内的生物解除冻结","color":"gray","italic":false},{"text":"状态后获得 5 秒缓慢Ⅲ和虚弱Ⅲ，之后使","color":"gray","italic":false},{"text":"其附加「渊海」效果。自身 5 格内有","color":"gray","italic":false},{"text":"「渊海」效果的生物获得常态的缓慢Ⅱ效","color":"gray","italic":false},{"text":"果。","color":"gray","italic":false}],custom_data={zx:["bitter_cold","tool"]}]
