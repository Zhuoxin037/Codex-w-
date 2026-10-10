# ============================================================
# sweetdream:visual/armor_icon_held —— 穿戴扫描: 给还没上外观的盔甲补组件
# ------------------------------------------------------------
# 【谁调用它】visual/armor_icon_sync(每秒一次, 挂 manacore:event/second)
# 【执行者】每个玩家(as @a 后逐个; 与 sword/axe/staff/crossbow 四个图标扫描同构)
#
# 【只做一件事】按 custom_data.zx[0] 认出是哪一件, 一次把两个组件写全:
#   · item_model = sweetdream:armor_<id>            (背包/手里的 16×16 图标)
#   · equippable = {slot, asset_id, equip_sound}    (穿在身上的穿戴层贴图)
#   lore / 技能数据 / 升级与超限 / 附魔 / 耐久 一律不碰。
#
# 【★ 两道门, 缺一不可】
#   ① `if items … *[minecraft:custom_data~{zx:["<id>"]}]` —— 认人。只看 zx[0],
#      不看底物: 铁/钻石/下界合金的四种部位是全包 25 件共用的底物, 拿底物当
#      身份必然误伤(比如"焚舟"和"沉溺忘川彼岸"都是下界合金靴)。
#   ② `unless items … *[minecraft:item_model="sweetdream:armor_<id>"]` ——
#      已经是它了就不写。item modify 只要执行就会重写组件, 哪怕值没变;
#      客户端把"组件变了"当成"换了一件物品"。
#
# 【★ 一件盔甲只扫它自己的槽位】部位互斥(头盔在 armor.head、护腿在 armor.legs…)
#   ⇒ 总行数 = 25, 不是 25×4。**背包/箱子里的存量盔甲这里看不到** ——
#   那些请重新 give(give 里已直接写了这两个组件)。
# ============================================================
# 脑髓蛭
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["brain_leech"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_brain_leech"] run item modify entity @s armor.head sweetdream:armor_icons/brain_leech
# 狄俄尼索斯之桂冠
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["dionysus_helmet"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_dionysus_helmet"] run item modify entity @s armor.head sweetdream:armor_icons/dionysus_helmet
# 异彩
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["iridescent"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_iridescent"] run item modify entity @s armor.head sweetdream:armor_icons/iridescent
# 聚魔头盔
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["mana_helm"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_mana_helm"] run item modify entity @s armor.head sweetdream:armor_icons/mana_helm
# 灵视
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["spirit_sight"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_spirit_sight"] run item modify entity @s armor.head sweetdream:armor_icons/spirit_sight
# 漫步冥河之上
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] unless items entity @s armor.head *[minecraft:item_model="sweetdream:armor_styx_walk"] run item modify entity @s armor.head sweetdream:armor_icons/styx_walk
# 焱
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["blaze_armor"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_blaze_armor"] run item modify entity @s armor.chest sweetdream:armor_icons/blaze_armor
# 永恒
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["eternity"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_eternity"] run item modify entity @s armor.chest sweetdream:armor_icons/eternity
# 炉心
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_furnace_core"] run item modify entity @s armor.chest sweetdream:armor_icons/furnace_core
# 静脉泵
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["intravenous_pump"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_intravenous_pump"] run item modify entity @s armor.chest sweetdream:armor_icons/intravenous_pump
# 聚魔胸甲
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["mana_plate"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_mana_plate"] run item modify entity @s armor.chest sweetdream:armor_icons/mana_plate
# 共振
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_resonance"] run item modify entity @s armor.chest sweetdream:armor_icons/resonance
# 脊骨共生
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["spine_symbiote"]}] unless items entity @s armor.chest *[minecraft:item_model="sweetdream:armor_spine_symbiote"] run item modify entity @s armor.chest sweetdream:armor_icons/spine_symbiote
# 余烬
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["ember"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_ember"] run item modify entity @s armor.legs sweetdream:armor_icons/ember
# 体外供能装置
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["external_power"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_external_power"] run item modify entity @s armor.legs sweetdream:armor_icons/external_power
# 息影
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_fade"] run item modify entity @s armor.legs sweetdream:armor_icons/fade
# 魔化腰带
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["hex_belt"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_hex_belt"] run item modify entity @s armor.legs sweetdream:armor_icons/hex_belt
# 幻昼
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mirage"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_mirage"] run item modify entity @s armor.legs sweetdream:armor_icons/mirage
# 群星坠落之挽歌
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["stellar_elegy"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_stellar_elegy"] run item modify entity @s armor.legs sweetdream:armor_icons/stellar_elegy
# 枯枝园
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["withered_garden"]}] unless items entity @s armor.legs *[minecraft:item_model="sweetdream:armor_withered_garden"] run item modify entity @s armor.legs sweetdream:armor_icons/withered_garden
# 黄昏黎明之交界
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["dusk_dawn"]}] unless items entity @s armor.feet *[minecraft:item_model="sweetdream:armor_dusk_dawn"] run item modify entity @s armor.feet sweetdream:armor_icons/dusk_dawn
# 血肉磨坊
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] unless items entity @s armor.feet *[minecraft:item_model="sweetdream:armor_flesh_mill"] run item modify entity @s armor.feet sweetdream:armor_icons/flesh_mill
# 焚舟
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["immolate"]}] unless items entity @s armor.feet *[minecraft:item_model="sweetdream:armor_immolate"] run item modify entity @s armor.feet sweetdream:armor_icons/immolate
# 沉溺忘川彼岸
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lethe_shore"]}] unless items entity @s armor.feet *[minecraft:item_model="sweetdream:armor_lethe_shore"] run item modify entity @s armor.feet sweetdream:armor_icons/lethe_shore
# 无光海
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lightless_sea"]}] unless items entity @s armor.feet *[minecraft:item_model="sweetdream:armor_lightless_sea"] run item modify entity @s armor.feet sweetdream:armor_icons/lightless_sea
