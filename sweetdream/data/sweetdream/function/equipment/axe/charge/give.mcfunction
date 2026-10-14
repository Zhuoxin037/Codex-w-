# ============================================================
# sweetdream:equipment/axe/charge/give —— 给一把「超•负•荷」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace" -> 通用回手线认它(右键才触发、用完还手)
#   "charge"      -> 武器 id, 进度 equipment/axe/charge 靠它认人
#   "axe"         -> 分类标记(剑/斧/弓/法杖/盔甲)
#   skill         -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
#
# 【lore 排版】正文**按你的原文一字不改**, 只按"文字宽度"等分硬切,
#   每行约 18~19.5 个汉字宽。原来那份也是硬切, 但切点偏了几格,
#   结果行宽在 17~20 之间来回跳; 这次是严格等分。
#   (切点若正好落在数字/英文中间会往后挪一格, 免得把 x0.05 切碎。)
# ============================================================

give @s diamond_axe[item_model="sweetdream:charge",item_name={text:"超•负•荷",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"主手持时，自身获得迅捷Ⅰ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"100 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后自身获得迅捷","color":"gray","italic":false},{"text":"Ⅱ效果。每秒都会对自身 8 格内 2 格外","color":"gray","italic":false},{"text":"的随机 1 个生物释放闪电，当自身攻击到","color":"gray","italic":false},{"text":"生物后立即对其释放一次闪电并对其 1 格","color":"gray","italic":false},{"text":"内的全部生物造成相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.05 的伤害，之后使该武器技能冷却时","color":"gray","italic":false},{"text":"间 -3 秒。该状态持续 10 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["charge","axe","itemreplace"],skill:"sweetdream:charge",tags:["lightning","cur_mana","formation","buff","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
