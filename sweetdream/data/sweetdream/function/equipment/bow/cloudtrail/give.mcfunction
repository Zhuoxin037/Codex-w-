# ============================================================
# sweetdream:equipment/bow/cloudtrail/give —— 给一件「云迹」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "cloudtrail" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["cloudtrail"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。
#   没射中 -> 箭停留处生成半径 3 的领域 5 秒; 射领域内生物时同步对领域内全体 基础攻击力 ×2。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 批 11(2026-10-12)已接上技能: 本件带附魔 sweetdream:cloudtrail —— 弩的命中结算
#   全靠附魔的 post_attack 回调(没有右键/消耗), 所以这行不能删。外观仍待做。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:crossbow_cloudtrail" + items/*.json + models/ + 贴图。
# ============================================================
give @s crossbow[item_name={text:"云迹",bold:true,color:white},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"}]},{"text":" ","italic":false},{"text":"射击后若未射中生物，则在箭停留位置生","color":"gray","italic":false},{"text":"成一个持续 5 秒的半径 3 格的领域。当","color":"gray","italic":false},{"text":"自身射击在领域内的生物时会同步对领域","color":"gray","italic":false},{"text":"内的全部生物造成一次相当于自身基础攻","color":"gray","italic":false},{"text":"击力 ×2 的伤害。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:cloudtrail":1},enchantment_glint_override=false,custom_data={zx:["cloudtrail","bow"],tags:["base_atk","field"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
