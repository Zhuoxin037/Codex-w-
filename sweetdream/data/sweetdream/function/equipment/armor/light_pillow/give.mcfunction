# ============================================================
# sweetdream:equipment/armor/light_pillow/give —— 给一件「轻枕」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "light_pillow" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["light_pillow"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】iron_boots（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_light_pillow
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_boots[item_name={text:"轻枕",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +40。受到原本附有","color":"gray","italic":false},{"text":"「白昼梦」的生物造成的近战伤害后，获","color":"gray","italic":false},{"text":"得 2 秒抗性提升Ⅰ。该效果 4 秒内最多","color":"gray","italic":false},{"text":"触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 镜寐","color":"gray","italic":false},{"text":"● 轻枕","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身为原本未附有「白昼梦」的生物成功","color":"gray","italic":false},{"text":"附加「白昼梦」后，获得 4 秒迅捷Ⅰ，并","color":"gray","italic":false},{"text":"在这 4 秒内每秒额外恢复 5 点魔力值。","color":"gray","italic":false},{"text":"该效果 10 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["light_pillow","boots","armor"],tags:["dream","max_mana","buff","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_light_pillow",equippable={slot:"feet",asset_id:"sweetdream:armor_light_pillow",equip_sound:"minecraft:item.armor.equip_iron"}]
