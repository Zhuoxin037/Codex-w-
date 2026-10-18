# ============================================================
# sweetdream:visual/axe_icon_held —— 手持扫描: 把还没有图标的斧补上 item_model
# ------------------------------------------------------------
# 【谁调用它】visual/axe_icon_sync(每秒一次, 挂 event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 sword/staff/crossbow 三个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一把斧, 把它的 item_model 写成
#   sweetdream:<模型键>。lore / 升级与超限数据 / 技能数据 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只认 zx[0]，
#      不认底物: iron_axe / diamond_axe / netherite_axe 是全包几十把武器
#      共用的底物, 拿底物当身份必然误伤。
#   ② `unless items … *[minecraft:item_model="sweetdream:<模型键>"]` —— 已经是它了就**不写**。
#      item modify 只要执行就会重写组件, 哪怕值没变; 客户端把"组件变了"当成
#      "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。
#      (资源包 14 份定义都带 hand_animation_on_swap:false 兜底, 但先判一次才是根治。)
#
# 【★ 崩裂的模型键是 sweetdream:fissure_axe, 不是 sweetdream:fissure】
#   后者在老包里已经是「地面裂缝」平面模型(fissure/field 用 item_display 召唤),
#   斧叫同一个名字会显示成一块贴地的裂缝。
#
# 【新 give 出来的斧本来就有 item_model】这里主要是给**存量**补课 ——
#   玩家背包里在本次改动之前就发出去的那些斧, 拿到手 1 秒内会被修好。
#
# no-equip-check-ok: 每一处 item_modify 都由"武器 id + 当前 item_model"双重门控,
#   不依赖穿着/手持判定, 漏判也不会影响别人。
# ============================================================
# 苦痛
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["agony"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:agony"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/agony
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["agony"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:agony"] run item modify entity @s weapon.offhand sweetdream:axe_icons/agony
# 负离子
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["anion"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:anion"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/anion
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["anion"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:anion"] run item modify entity @s weapon.offhand sweetdream:axe_icons/anion
# 苍蓝星
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["azure_star"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:azure_star"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/azure_star
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["azure_star"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:azure_star"] run item modify entity @s weapon.offhand sweetdream:axe_icons/azure_star
# 歌谣
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["ballad"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:ballad"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/ballad
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["ballad"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:ballad"] run item modify entity @s weapon.offhand sweetdream:axe_icons/ballad
# 超•负•荷
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["charge"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:charge"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/charge
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["charge"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:charge"] run item modify entity @s weapon.offhand sweetdream:axe_icons/charge
# 沉渊
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chenyuan"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:chenyuan"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/chenyuan
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["chenyuan"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:chenyuan"] run item modify entity @s weapon.offhand sweetdream:axe_icons/chenyuan
# 饮鸩
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["draught"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:draught"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/draught
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["draught"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:draught"] run item modify entity @s weapon.offhand sweetdream:axe_icons/draught
# 释梦
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["dream_reader"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:dream_reader"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/dream_reader
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["dream_reader"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:dream_reader"] run item modify entity @s weapon.offhand sweetdream:axe_icons/dream_reader
# 崩裂
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["fissure"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:fissure_axe"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/fissure
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["fissure"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:fissure_axe"] run item modify entity @s weapon.offhand sweetdream:axe_icons/fissure
# 陨星
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["meteor"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:meteor"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/meteor
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["meteor"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:meteor"] run item modify entity @s weapon.offhand sweetdream:axe_icons/meteor
# 葬火
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["pyre"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:pyre"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/pyre
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["pyre"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:pyre"] run item modify entity @s weapon.offhand sweetdream:axe_icons/pyre
# 红莲
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["red_lotus"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:red_lotus"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/red_lotus
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["red_lotus"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:red_lotus"] run item modify entity @s weapon.offhand sweetdream:axe_icons/red_lotus
# 天穹
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["skyvault"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:skyvault"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/skyvault
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["skyvault"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:skyvault"] run item modify entity @s weapon.offhand sweetdream:axe_icons/skyvault
# 威霆
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["thunderclap"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:thunderclap"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/thunderclap
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunderclap"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:thunderclap"] run item modify entity @s weapon.offhand sweetdream:axe_icons/thunderclap
# 焦骨
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["scorch_bone"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:scorch_bone"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/scorch_bone
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["scorch_bone"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:scorch_bone"] run item modify entity @s weapon.offhand sweetdream:axe_icons/scorch_bone
# 沉锚
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["anchor"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:anchor"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/anchor
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["anchor"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:anchor"] run item modify entity @s weapon.offhand sweetdream:axe_icons/anchor
# 断页
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["broken_page"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:broken_page"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/broken_page
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["broken_page"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:broken_page"] run item modify entity @s weapon.offhand sweetdream:axe_icons/broken_page
# 丧铃
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["death_bell"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:death_bell"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/death_bell
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["death_bell"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:death_bell"] run item modify entity @s weapon.offhand sweetdream:axe_icons/death_bell
# 重溟
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deep_brine"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:deep_brine"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/deep_brine
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deep_brine"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:deep_brine"] run item modify entity @s weapon.offhand sweetdream:axe_icons/deep_brine
# 剜霜
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["frost_carve"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:frost_carve"] run item modify entity @s weapon.mainhand sweetdream:axe_icons/frost_carve
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["frost_carve"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:frost_carve"] run item modify entity @s weapon.offhand sweetdream:axe_icons/frost_carve
