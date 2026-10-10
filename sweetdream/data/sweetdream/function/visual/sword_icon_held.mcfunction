# ============================================================
# sweetdream:visual/sword_icon_held —— 手持扫描: 把还没有图标的剑补上 item_model
# ------------------------------------------------------------
# 【谁调用它】visual/sword_icon_sync(每秒一次, 挂 event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 staff/crossbow 两个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一把剑, 把它的 item_model 写成
#   sweetdream:<id>。lore / 升级与超限数据 / 技能数据 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只认 zx[0]，
#      不认底物: iron_sword / diamond_sword / netherite_sword 是全包几十把武器
#      共用的底物, 拿底物当身份必然误伤。
#   ② `unless items … *[minecraft:item_model="sweetdream:<id>"]` —— 已经是它了就**不写**。
#      item modify 只要执行就会重写组件, 哪怕值没变; 客户端把"组件变了"当成
#      "换了一件物品" ⇒ 每刻播一次举手动画 ⇒ **在手上一直抽搐**。
#      (资源包 13 份定义都带 hand_animation_on_swap:false 兜底, 但先判一次才是根治。)
#
# 【新 give 出来的剑本来就有 item_model】这里主要是给**存量**补课 ——
#   玩家背包里在本次改动之前就发出去的那些剑, 拿到手 1 秒内会被修好。
#
# no-equip-check-ok: 每一处 item_modify 都由"武器 id + 当前 item_model"双重门控,
#   不依赖穿着/手持判定, 漏判也不会影响别人。
# ============================================================
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["everfrost"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:everfrost"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/everfrost
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["everfrost"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:everfrost"] run item modify entity @s weapon.offhand sweetdream:sword_icons/everfrost
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["hengdao"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:hengdao"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/hengdao
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["hengdao"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:hengdao"] run item modify entity @s weapon.offhand sweetdream:sword_icons/hengdao
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["hush"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:hush"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/hush
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["hush"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:hush"] run item modify entity @s weapon.offhand sweetdream:sword_icons/hush
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["liaoyuan"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:liaoyuan"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/liaoyuan
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["liaoyuan"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:liaoyuan"] run item modify entity @s weapon.offhand sweetdream:sword_icons/liaoyuan
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["liuguang"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:liuguang"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/liuguang
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["liuguang"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:liuguang"] run item modify entity @s weapon.offhand sweetdream:sword_icons/liuguang
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["myriad"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:myriad"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/myriad
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["myriad"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:myriad"] run item modify entity @s weapon.offhand sweetdream:sword_icons/myriad
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["qiansan"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:qiansan"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/qiansan
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["qiansan"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:qiansan"] run item modify entity @s weapon.offhand sweetdream:sword_icons/qiansan
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["rebound"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:rebound"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/rebound
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["rebound"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:rebound"] run item modify entity @s weapon.offhand sweetdream:sword_icons/rebound
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["remelt"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:remelt"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/remelt
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["remelt"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:remelt"] run item modify entity @s weapon.offhand sweetdream:sword_icons/remelt
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["rogue_star"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:rogue_star"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/rogue_star
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["rogue_star"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:rogue_star"] run item modify entity @s weapon.offhand sweetdream:sword_icons/rogue_star
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["shadow_blade"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:shadow_blade"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/shadow_blade
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["shadow_blade"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:shadow_blade"] run item modify entity @s weapon.offhand sweetdream:sword_icons/shadow_blade
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["verdict"]}] unless items entity @s weapon.mainhand *[minecraft:item_model="sweetdream:verdict"] run item modify entity @s weapon.mainhand sweetdream:sword_icons/verdict
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["verdict"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:verdict"] run item modify entity @s weapon.offhand sweetdream:sword_icons/verdict
