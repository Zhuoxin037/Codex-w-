# ============================================================
# sweetdream:equipment/sword/liaoyuan/give —— 给一把「燎原」
# ------------------------------------------------------------
# 【位置】按你给的文案: 消耗 250 / 冷却 50 秒 / 使用后 18 秒光环, 每 2 秒灼烧一次,
#   每 2 次之后的下一 次(第 3、6、9 次)额外附加「流火」。
# 【custom_data 三段 + skill】
#   "itemreplace" -> 通用回手线认它(右键触发、用完还手)
#   "liaoyuan"    -> 武器 id
#   "sword"       -> 分类标记(剑类)
#   skill         -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
# 【底材】下界合金剑(和引梦镰同档)。造型等你用 Blockbench 套模型。
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文; 正文按文字宽度硬切。
# ============================================================

give @s netherite_sword[item_name={text:"燎原",bold:true,color:"gold"},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"250","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"50 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后自身获得「燎原」效果：18秒","color":"gray","italic":false},{"text":"内每2秒对自身5格内的生物造成一次","color":"gray","italic":false},{"text":"相当于自身最大魔力值*0.04的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 燎原","color":"gold","bold":true,"italic":false},{"text":"伤害每进行3次，其中第3次会额外使","color":"gray","italic":false},{"text":"受到伤害的生物附加「流火」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["liaoyuan","sword","itemreplace"],skill:"sweetdream:liaoyuan"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
