# ============================================================
# sweetdream:equipment/sword/hengdao/give —— 给一把「横刀」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace" -> 通用回手线认它(右键才触发、用完还手)
#   "hengdao"     -> 武器 id, 进度 equipment/sword/hengdao 靠它认人
#   "sword"       -> 分类标记(剑/斧/弓/法杖/盔甲/道具)
#   skill         -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
#
# 【数值要和 cast 对上】魔力 15 / 冷却 20 秒 —— 改这里的话, cast 里
#   mana:15.0 和 cooldown_seconds:20.0 两处也要一起改。
#
# 【lore 排版】正文按"文字宽度"等分硬切(每行约 15.5~16.5 个汉字宽)。
#   现在正文总宽只有 47.5 个汉字宽, 硬切成 2 行的话每行 23.75 —— 太宽了
#   (超过 21 就会被客户端自动折行), 所以工具自动加成 3 行。
# ============================================================

give @s iron_sword[item_model="sweetdream:hengdao",item_name={text:"横刀",bold:true,color:blue},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"15","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"向前突进最多 3 格，撞到生物或障碍物立","color":"gray","italic":false},{"text":"刻停下，对落点 2 格内的全部生物造成最","color":"gray","italic":false},{"text":"大魔力 ×0.08 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["hengdao","sword","itemreplace"],skill:"sweetdream:hengdao",tags:["max_mana","dash"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
