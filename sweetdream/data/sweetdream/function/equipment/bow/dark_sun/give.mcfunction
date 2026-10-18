# ============================================================
# sweetdream:equipment/bow/dark_sun/give —— 给一件「黯日」（传说 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "dark_sun" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["dark_sun"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（传说 = netherite）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:crossbow_dark_sun
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 弩的命中结算要靠 sweetdream:dark_sun 附魔的 post_attack 回调（坑 138：回调
#   只读**攻击者主手物品**上的附魔）=> **必须挂 enchantments**；漏了它整把弩
#   会"射得出去、什么都不发生"且零日志。
#   ★ 附魔属于**注册表**内容：第一次加载（或改动它）之后要**退出世界再进**，
#     光 /reload 不够（坑 153）；改动前发出的旧件也要**重新 give**（坑 144）。
#   ★ enchantment_glint_override=false + tooltip 里藏掉 enchantments：
#     让附魔生效但不显示附魔名与紫色光效（与既有 10 把弩同一套写法）。
# ============================================================
give @s crossbow[item_name={text:"黯日",bold:true,color:dark_red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"320","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中生物后，额外造成一次相当","color":"gray","italic":false},{"text":"于自身当前魔力值 ×0.12 的伤害，并使其","color":"gray","italic":false},{"text":"附加「夜火」和「流火」。若其已附有","color":"gray","italic":false},{"text":"「流火」，则上述伤害提高 30%；若该目","color":"gray","italic":false},{"text":"标在命中前已附有「夜火」，则上述伤害","color":"gray","italic":false},{"text":"提高 50%（独立乘区），并向命中位置 6","color":"gray","italic":false},{"text":"格内最近的四个其他生物释放一枚影矢。","color":"gray","italic":false},{"text":"影矢造成一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.08 的伤害，并使其附加「夜火」。该","color":"gray","italic":false},{"text":"效果 20 秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:dark_sun":1},enchantment_glint_override=false,custom_data={zx:["dark_sun","bow"],tags:["liuhuo","yehuo","cur_mana","indep_mul","apply"]},tooltip_display={hidden_components:["unbreakable","enchantments"]},item_model="sweetdream:crossbow_dark_sun"]
