# ============================================================
# sweetdream:equipment/sword/hush/give —— 给一件「无息」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "hush" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["hush"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】魔力 200 / 冷却 30 秒 / 突击最多 8 格(16 步 × 0.5) /
#   撞生物不停、只被终点/障碍物拦下; 途中碰到生物 -> 对身边 3 格内全部生物 ×0.1
#   (同一只每次施法至多一次); 归位约 0.2 秒(每刻 2 格, 见 back_move), 落地再对路径生物 ×0.2。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_sword[item_name={text:"无息",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向前突击最多 8 格，途中无视生物、","color":"gray","italic":false},{"text":"径直穿身而过，只有抵达终点或撞上障碍","color":"gray","italic":false},{"text":"物才会停下。突击途中每碰到一个生物，","color":"gray","italic":false},{"text":"都会立刻对身边 3 格内的全部生物造成一","color":"gray","italic":false},{"text":"次相当于自身最大魔力值 ×0.1 的伤害（","color":"gray","italic":false},{"text":"每个生物只会被触发一次）；停下后会在","color":"gray","italic":false},{"text":"约 0.2 秒内极速闪回原点，并再次对路径","color":"gray","italic":false},{"text":"上的全部生物造成一次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["hush","sword","itemreplace"],skill:"sweetdream:hush"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
