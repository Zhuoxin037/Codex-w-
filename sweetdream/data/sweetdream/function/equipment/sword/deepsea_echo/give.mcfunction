# 【custom_data】三个标记 + skill, 和流光/横刀一个规格:
#   "itemreplace" -> 通用回手线认它(右键才触发、用完还手)
#   "deepsea_echo" -> 武器 id, 进度 equipment/sword/deepsea_echo 靠它认人
#   skill -> 观测镜靠它显示冷却; 必须和 cast 里 api/skill/check、
#            api/cooldown/start 传的 skill 一致
# 【还差什么】现在只有 give —— 还缺 advancement/equipment/sword/deepsea_echo.json
#   和 equipment/sword/deepsea_echo/cast.mcfunction, 所以右键暂时没反应。
# 【lore 排版】正文沿用你原来的断行(宽度本来就很齐), 只换成新样式:
#   ✦ 小标题金色加粗 / 数值行拼色 / 正文灰色 / 空行用空格。
give @s diamond_sword[item_model="deepseaecho:sword",item_name={text:"深海的回响",bold:true,color:blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"主手持时，自身获得水下呼吸Ⅰ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"350","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后标记12格内离自身最近的一个生物并","color":"gray","italic":false},{"text":"使其附加「渊海」。1秒后对其3格范围内的","color":"gray","italic":false},{"text":"全部生物造成相当于自身当前魔力值*0.15的","color":"gray","italic":false},{"text":"伤害，之后标记受到伤害的生物并重复，但","color":"gray","italic":false},{"text":"每次重复都会消耗自身110魔力值。重复2","color":"gray","italic":false},{"text":"次后结束。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["deepsea_echo","sword","itemreplace"],skill:"sweetdream:deepsea_echo"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
