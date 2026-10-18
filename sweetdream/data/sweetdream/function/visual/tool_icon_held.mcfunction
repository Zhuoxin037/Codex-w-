# ============================================================
# sweetdream:visual/tool_icon_held —— 副手扫描: 给还没上外观的副手道具补 item_model
# ------------------------------------------------------------
# 【谁调用它】visual/tool_icon_sync(每秒一次, 挂 manacore:event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 sword/axe/staff/crossbow/armor 五个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一件, 写 item_model:
#   · item_model = sweetdream:tool_<id>   (背包/手里的 16×16 图标)
#   lore / 技能数据 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只看 zx[0],
#      不看底物: 这 7 件的底物**全都是 recovery_compass**(外加观测镜 look 也是),
#      拿底物当身份必然互相误伤。
#   ② `unless items … *[minecraft:item_model="sweetdream:tool_<id>"]` ——
#      已经是它了就不写。item modify 只要执行就会重写组件, 哪怕值没变;
#      客户端把"组件变了"当成"换了一件物品"⇒ 副手会一直抽搐。
#
# 【★ 判定槽位 = weapon.offhand】这 7 件都是"持于副手时"生效的被动道具。
#   **背包/箱子里的存量道具这里看不到** —— 那些请重新 give
#   (give 里已直接写了这个组件)。
# ============================================================
# 苦寒
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bitter_cold"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_bitter_cold"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/bitter_cold
# 炽翎
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["blaze_plume"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_blaze_plume"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/blaze_plume
# 体外魔力泵
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["mana_pump"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_mana_pump"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/mana_pump
# 无效
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["nullify"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_nullify"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/nullify
# 炽天使之翼
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["seraph_wing"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_seraph_wing"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/seraph_wing
# 雷鸣
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_thunder"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/thunder
# 愠怒
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_wrath"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/wrath
# 殓丝
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["coffin_silk"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_coffin_silk"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/coffin_silk
# 冰鉴
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["frostmirror"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_frostmirror"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/frostmirror
# 回潮扣
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] unless items entity @s weapon.offhand *[minecraft:item_model="sweetdream:tool_tide_buckle"] run item modify entity @s weapon.offhand sweetdream:offhand_icons/tide_buckle
