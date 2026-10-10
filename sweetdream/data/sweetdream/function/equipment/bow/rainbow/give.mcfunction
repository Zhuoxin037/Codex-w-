# ============================================================
# sweetdream:equipment/bow/rainbow/give —— 给一件「虹彩」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "rainbow" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["rainbow"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【名字是两色】"虹"(light_purple) + "彩"(aqua) —— 用户 2026-10-06 要"两种不同颜色搭配"。
#   生成器里由 color2 / split 两个字段控制(见 build 的 item_name 段):
#   color2 = 第二段颜色, split = 从第几个字开始换色(这里是 1)。
# 【底材为什么是弩】和「寒鸦 / 幽匿残响」同理: 靠 minecraft:shot_crossbow
#   拿到"每次射击"这个事件; 弓做不到。
# 【注意别和「异彩」(iridescent, 头盔)搞混】两件是不同的东西, id 也不同。
# 【弩上的附魔】sweetdream:rainbow(见 enchantment/rainbow.json),
#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。
# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,
#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。
#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s crossbow[item_model="sweetdream:crossbow_rainbow",item_name={text:"虹",bold:true,color:light_purple,extra:[{text:"彩",color:aqua}]},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"580","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击若射击到了生物，则使附着 10","color":"gray","italic":false},{"text":"秒「漫彩」。期间若其有「流火」、","color":"gray","italic":false},{"text":"「夜火」、「渊海」、「白昼梦」、","color":"gray","italic":false},{"text":"「噬心」中任意一个效果则消耗该效果并","color":"gray","italic":false},{"text":"使其受到相当于自身最大生命值 ×0.1 的","color":"gray","italic":false},{"text":"伤害，之后使「漫彩」效果 -1 秒。若","color":"gray","italic":false},{"text":"「漫彩」效果在 5 秒内结束则对其 2 格","color":"gray","italic":false},{"text":"内的生物造成一次相当于其最大生命值","color":"gray","italic":false},{"text":"×0.2 的伤害。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:rainbow":1},enchantment_glint_override=false,custom_data={zx:["rainbow","bow"],tags:["liuhuo","yehuo","yuanhai","dream","shixin","max_hp","consume"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
