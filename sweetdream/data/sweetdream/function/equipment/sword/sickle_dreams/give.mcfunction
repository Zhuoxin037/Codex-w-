# ============================================================
# sweetdream:equipment/sword/sickle_dreams/give —— 给一把「引梦镰」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace"   -> 通用回手线认它(右键才触发、用完还手)
#   "sickle_dreams" -> 武器 id
#   "sword"         -> 分类标记(剑类)
#   skill           -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
# 【底材】下界合金剑(和「烈火，残躯」同档)。已绑定低面数引梦镰模型 dreamscythe:sickle。
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文; 正文按文字宽度硬切。
# 【做技能时的提醒】
#   ① 「噬心」是**通用标签**之一 -> 用 sweetdream:tag/mark 贴, 会自动长出图标;
#   ② "时停 2 秒" 原版没有真正的时停: 可行做法是给周围生物挂长时间的反胃/缓慢 +
#      把它们的 AI 冻住(Mob 的 NoAI 不行), 或者只做"表现上的时停"(粒子+音效);
#   ③ "8 秒内不可再次触发强化" 用计分项当冷却, 不用走技能冷却系统。
# ============================================================

give @s netherite_sword[item_model="dreamscythe:sickle",item_name={text:"引梦镰",bold:true,color:"dark_purple"},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"5 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"横扫命中时对前方 2×3 范围内的生物造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.05 的伤害","color":"gray","italic":false},{"text":"并附加「噬心」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 强化","color":"gold","bold":true,"italic":false},{"text":"若对有「噬心」的生物造成伤害则本次伤","color":"gray","italic":false},{"text":"害强化为对自身前方 3×5 范围内的生物造","color":"gray","italic":false},{"text":"成相当于自身最大魔力值 ×0.2 的伤害并","color":"gray","italic":false},{"text":"时停 2 秒，之后移除「噬心」。触发强化","color":"gray","italic":false},{"text":"攻击后则在 8 秒内不可再次触发强化攻击。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["sickle_dreams","sword","itemreplace"],skill:"sweetdream:sickle_dreams"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
