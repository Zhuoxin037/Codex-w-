# ============================================================
# sweetdream:equipment/bow/backstring/give —— 给一件「退弦」（弩 · 过渡）
# ------------------------------------------------------------
# 【custom_data】
#   "backstring" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["backstring"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【弩 = 射击即生效】不加 consumable/itemreplace, 也没有主动技能 -> 不加 skill。
#   每次射击**离弦那一刻**扣 30 蓝(没射中也付钱); 箭矢命中后自身向后位移 2 格
#   + 2 秒迅捷Ⅱ; 每累计 3 次射击, 第 3 发额外造成 12 点固定伤害。
# ★ 本件带附魔 sweetdream:backstring —— 弩的命中结算全靠附魔的 post_attack
#   回调(没有右键/消耗), 所以这行不能删。
#   ⚠️ 附魔是**注册表**内容: 新增后必须**退出世界重进**, /reload 不补。
# ★ 本批**不挂 item_model**(批 12 外观未做; 挂了会引用不存在的模型 -> 紫黑方块)。
# 【手写文件】不是 _gen_batch*.py 的产物, 别被生成器覆盖。
# ============================================================
give @s crossbow[item_name={text:"退弦",bold:true,color:green},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"}]},{"text":" ","italic":false},{"text":"箭矢命中后，自身向后位移 2 格并获得 2","color":"gray","italic":false},{"text":"秒迅捷Ⅱ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 弦满","color":"gold","bold":true,"italic":false},{"text":"每累计 3 次射击，第 3 发额外造成 12","color":"gray","italic":false},{"text":"点伤害。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:backstring":1},enchantment_glint_override=false,custom_data={zx:["backstring","bow"],tags:["dash","buff","flat"]},tooltip_display={hidden_components:["unbreakable","enchantments"]},item_model="sweetdream:crossbow_backstring"]
