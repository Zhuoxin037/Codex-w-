# ============================================================
# sweetdream:equipment/staff/apocalypse/give —— 给一件「启示录」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "apocalypse" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["apocalypse"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和 cast 对上】普攻 魔力 60; 技能 魔力 450 / 冷却 90 秒。
# 【"启示"是页, 不是层数】最多 3 页, 每页各记一次魔力值 —— 所以存的是
#   一个最多 3 项的列表, 不是"层数 +1"。
# 【两个计时器】"每 4 秒依次消耗一层"和"每 3 秒一次灾示"是两条,
#   别合成一个(描述里是两个独立的节奏)。
# 【模型】2026-10-07: 用户已画好模型, 所以本条目带 `item_model` 字段
#   (其余三根法杖仍不写)。模型见 sweetdream_rp_完整版/assets/sweetdream/
#   items/apocalypse.json —— 按 custom_model_data 分发的完整树。
#   ★ 生成器会给它自动配 custom_model_data={floats:[0.0f]}(成对写)。
#   ★ 历史坑: 2026-10-05 那版 note 写着"故意不写 item_model", 后来模型
#     做好了却只改了磁盘上的 give ⇒ 每次重跑生成器都把 item_model 打掉。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[item_model="sweetdream:apocalypse",custom_model_data={floats:[0.0f]},max_stack_size=1,item_name={text:"启示录",bold:true,color:gold},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.03","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 启示","color":"gold","bold":true,"italic":false},{"text":"该武器位于快捷栏时，自身每次释放主动","color":"gray","italic":false},{"text":"技能时若该技能消耗了至少 100 魔力，则","color":"gray","italic":false},{"text":"「启示录」记录该技能消耗的魔力值并获","color":"gray","italic":false},{"text":"得一页「启示」，最多记录 3 页。每个技","color":"gray","italic":false},{"text":"能单次最多产生一页。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"450","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"90 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵，并每隔 4 秒就依次","color":"gray","italic":false},{"text":"消耗一层「启示」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 灾示","color":"gold","bold":true,"italic":false},{"text":"每消耗一页，每隔 3 秒发生一次「灾示」：","color":"gray","italic":false},{"text":"对自身 8 格内全部生物造成相当于该页记","color":"gray","italic":false},{"text":"录魔力值 ×0.5 的伤害。若该页记录的技","color":"gray","italic":false},{"text":"能消耗魔力超过 500，则本次「灾示」额","color":"gray","italic":false},{"text":"外使目标获得 5 秒发光与虚弱Ⅱ。若三页","color":"gray","italic":false},{"text":"启示全部被消耗，则最后一次「灾示」伤","color":"gray","italic":false},{"text":"害提高 50%。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["apocalypse","staff","itemreplace"],skill:"sweetdream:apocalypse",tags:["max_mana","cur_mana","formation","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
