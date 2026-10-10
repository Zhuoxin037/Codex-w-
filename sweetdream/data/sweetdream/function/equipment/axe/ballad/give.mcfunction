# ============================================================
# sweetdream:equipment/axe/ballad/give —— 给一件「歌谣」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "ballad" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["ballad"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【专属层数「曲调」】每击杀一个生物 +1（最高 8 层）。
#   主动 240 / 30 秒: 下次攻击对 X 格内 X 个生物造成基础攻击力 ×（9-X）真伤 + 时停 X 秒, 之后清「曲调」。
# 【X = 曲调层数】代入值直接读层数; 用户稿里"X 格内的 X 生物"按"X 个生物"理解。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_axe[item_model="sweetdream:ballad",item_name={text:"歌谣",bold:true,color:yellow},lore=[{"text":"✦ 曲调","color":"gold","bold":true,"italic":false},{"text":"自身使用「歌谣」时每击杀一个生物则积","color":"gray","italic":false},{"text":"攒一点「曲调」。（最高 8 层）","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"240","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后自身下一次攻击额外对自身 X 格内","color":"gray","italic":false},{"text":"的 X 个生物造成一次相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×（9-X）的真实伤害并时停 X 秒。之","color":"gray","italic":false},{"text":"后清除全部「曲调」。（X 为「曲调」层","color":"gray","italic":false},{"text":"数）","color":"gray","italic":false}],unbreakable={},custom_data={zx:["ballad","axe","itemreplace"],skill:"sweetdream:ballad",tags:["base_atk","true_dmg","timestop"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
