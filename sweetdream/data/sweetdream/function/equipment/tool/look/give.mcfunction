# ============================================================
# sweetdream:equipment/tool/look/give —— 给一个"观测镜"(数值面板开关)
# ------------------------------------------------------------
# 【用法】/function sweetdream:equipment/tool/look/give
# 【它怎么工作】右键 -> 被消耗 -> 触发进度 sweetdream:equipment/tool/look -> 翻转开关 + 立刻还你一个。
#   所以这道具是"无限使用"的, 不用 craft 一堆。
# 【为什么不用 use_remainder】那个只能撑有限次: remainder 里还得再写一层
#   remainder, 写不了无限。(流光的回手机制是另一套: 靠盔甲架备份。)
# 【custom_data 的 zx:["look"] 是身份标记】进度就是靠它认人的, 别改。
# 【外观】item_model="sweetdream:look" -> 黄铜单筒望远镜(2026-10-05 做的模型):
#   资源包 assets/sweetdream/{items/look.json, models/item/look.json, textures/item/look.png}。
#   底材是 recovery_compass, 不加这一项就会显示成追溯指针的原版样子。
#   改造型只动资源包那三个文件, 这里不用变。
# ============================================================

give @s recovery_compass[max_stack_size=1,minecraft:item_model="sweetdream:look",minecraft:item_name={text:"观测镜",bold:true,color:"aqua"},minecraft:lore=[{"text":"右键: 开 / 关 数值面板","color":"gray","italic":false}],minecraft:custom_data={zx:["look"]},minecraft:consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
