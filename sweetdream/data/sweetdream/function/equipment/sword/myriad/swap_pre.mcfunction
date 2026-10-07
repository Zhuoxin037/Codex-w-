# ============================================================
# sweetdream:equipment/sword/myriad/swap_pre —— 换手**之前**: 把升级石列表存起来
# ------------------------------------------------------------
# 【宏参数】zx:work mqk {p} —— p = 那只手的 NBT 路径
#     主手 = SelectedItem(只读虚拟路径, 读没问题) / 副手 = equipment.offhand
# 【谁调用它】equipment/sword/myriad/swap(在 put_qian / put_my 之前一行)
# 【为什么要它】换手是 `item replace ... with <生成器给的那份原始组件串>`,
#   那份串的 custom_data 只有 {zx:[...], skill:"..."} —— **没有 up**。
#   给万念/千散敲过任何升级石后, 第一次放技能换手就会把整个 up 列表清空
#   (切回来也一样空, 石头已经消耗且没有旁路恢复)。
#   replace 会整个覆盖物品, 所以只能在**覆盖之前**读出来。
#
# 【★ 没敲过石头时不能凭空造一个 up ★】先 remove 掉 storage 再按 `if data`
#   有条件地拷 —— 否则 storage 里留着上一次的残留, 会给没敲过石头的人
#   凭空塞一份升级(swap_post 那边也就跟着写进去了)。
# ============================================================

data remove storage zx:work mq_up
$execute if data entity @s $(p).components."minecraft:custom_data".up run data modify storage zx:work mq_up set from entity @s $(p).components."minecraft:custom_data".up
