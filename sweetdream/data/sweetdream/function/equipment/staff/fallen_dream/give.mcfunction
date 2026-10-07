# ============================================================
# sweetdream:equipment/staff/fallen_dream/give —— 给一件「堕梦」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "fallen_dream" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["fallen_dream"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】普攻 魔力 50; 技能 魔力 500 / 冷却 100 秒。
# 【真伤】普攻命中带「白昼梦」的目标时本次改真实伤害 —— 和「幻昼」
#   那套「白昼梦」联动, 别自己另起一个效果名。
# 【模型】**故意不写 item_model** —— 写了就会变成「风行于大地之上」
#   (包里只有 naturewind:staff 一个法杖模型)。用户 2026-10-05 定:
#   法杖就长成 recovery_compass 追溯指针的原版样子, 四根一样也没关系,
#   等以后自己画好模型再单独加 item_model 这一项。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"堕梦",bold:true,color:dark_gray},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"50","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.03","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后若其处于「白昼梦」效果","color":"gray","italic":false},{"text":"则本次伤害变为真实伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"100 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后使自身 8 格内","color":"gray","italic":false},{"text":"未处于时停状态的生物时停 3 秒并附加","color":"gray","italic":false},{"text":"「白昼梦」效果。若处于时停状态则时停","color":"gray","italic":false},{"text":"时间 +2 秒。之后使其在接下来的时停时","color":"gray","italic":false},{"text":"间内每秒受到一次相当于使用者当前魔力","color":"gray","italic":false},{"text":"值 ×0.04 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["fallen_dream","staff","itemreplace"],skill:"sweetdream:fallen_dream"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
