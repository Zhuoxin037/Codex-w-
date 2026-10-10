# ============================================================
# sweetdream:equipment/tool/thunder/give —— 给一件「雷鸣」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"thunder" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["thunder"]}]
# 【数值要和实现对上】6 格内; 雷击后 1 秒原地再劈一道; 额外伤害 最大魔力 ×0.03。
# 【★ 效果已实装(2026-10-06 晚)★】
#   · 挂在 core/tick(每刻, 三维度各一遍):
#       ① 扫到"新出现的闪电" -> thunder/strike -> 6 格内持「雷鸣」的玩家登记
#       ② 到点的 marker -> thunder/pend_go -> 原地再劈一道 + thunder/bolt_dmg 结算额外伤害
#   · 为什么不用 schedule: 两人/两雷同时命中会互相顶掉(默认 replace), 用 marker 一个一记。
#   · "6 格内的生物受到雷击" —— 闪电实体只活几刻, 必须每刻扫(每秒轮询必漏);
#     给闪电打 zx.th_seen 防同一道雷重复触发; 再劈出来的那道也带这个标签, 防无限连锁。
# 【为什么没有 consumable / itemreplace】这两项是"右键被消耗 + 回手"那套机制,
#   本道具是**持于副手时**被动生效, 不需要右键, 所以都不要 —— 带了反而会被吃掉。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
#   要区分得各自给 item_model(资源包侧), 这次没做。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"雷鸣",bold:true,color:yellow},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身 6 格内的生物受到雷击","color":"gray","italic":false},{"text":"后，则在 1 秒后在原地再次释放一道闪电，","color":"gray","italic":false},{"text":"闪电额外造成相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.03 的伤害。","color":"gray","italic":false}],custom_data={zx:["thunder","tool"],tags:["max_mana"]},minecraft:item_model="sweetdream:tool_thunder"]
