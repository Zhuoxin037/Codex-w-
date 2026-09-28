# ============================================================
# sweetdream:equipment/sword/liuguang/give —— 给一把「流光」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace" -> 通用回手线认它(右键才触发、用完还手)
#   "liuguang"    -> 武器 id, 进度 equipment/sword/liuguang 靠它认人。
#                    做新武器就换成新名字, 并在
#                    advancement/equipment/<分类>/<名字>.json 里配套写一份。
#   "sword"       -> 分类标记(剑/斧/弓/法杖/盔甲/道具)
#   skill         -> 【观测镜靠它显示冷却】面板读的是"主手物品的 custom_data.skill",
#                    拿着这把刀就显示 sweetdream:liuguang 那条冷却, 拿着别的就显示 0。
#                    必须和 cast 里 api/skill/check、api/cooldown/start 传的 skill 一致。
#
# 【物品组件】consumable 不能删(删了右键不会触发 consume_item 进度);
#   item_name / lore / unbreakable / tooltip_display 都是外观, 随便改。
#   lore 改完记得和 cast 里的魔力/冷却数值对上 —— 那是两处, 容易忘。
#
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文。
#   正文按"文字宽度"等分硬切(每行约 17.5~18.5 个汉字宽)。
#   想在**同一行**里用多种颜色, 就把几段塞进一个条目的 extra 里(见数值行)。
# ============================================================

give @s iron_sword[item_name={text:"流光",bold:true,color:blue},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"锁定自身 8 格内的一个目标，3 秒后造","color":"gray","italic":false},{"text":"成基础攻击力 ×2 的伤害。（保底 6 点）","color":"gray","italic":false}],unbreakable={},custom_data={zx:["liuguang","sword","itemreplace"],skill:"sweetdream:liuguang"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
