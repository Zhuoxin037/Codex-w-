# ============================================================
# sweetdream:equipment/axe/thunderclap/give —— 给一件「威霆」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "thunderclap" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["thunderclap"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【没有主动技能】全被动, 不开右键 -> 不加 consumable/skill。
# 【专属点数「天煌」】手持未攻击时每刻 +1（上限 2000）。攻击后全清并等量扣魔, 落点开半径 6 术阵
#   + 半径 6 格领域（真闪电实体, 带 zx.th_seen 防雷鸣连锁）。
#   领域内每被攻击一次 -> X 道闪电(每道 最大魔力值 ×0.1); 每 10 次雷击扣 10% 最大生命; 持续 X×2 秒
#   （X =「天煌」×0.005）。魔力不足则本次攻击"视消耗的魔力总数为「天煌」点数" ——
#   也就是 X 按**实际消耗的魔力**算（2026-10-08 用户定稿口径 a）。
# 【同时只能有一个术阵】下一个术阵结束前不能再开。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_axe[item_model="sweetdream:thunderclap",item_name={text:"威霆",bold:true,color:aqua},lore=[{"text":"✦ 天煌","color":"gold","bold":true,"italic":false},{"text":"自身手持该武器且未攻击生物时，每刻积","color":"gray","italic":false},{"text":"攒一点「天煌」（上限 2000 点）。自身","color":"gray","italic":false},{"text":"攻击生物后立即消耗全部「天煌」并消耗","color":"gray","italic":false},{"text":"等量的魔力，在目标位置召唤 1 个术阵并","color":"gray","italic":false},{"text":"生成半径 6 格的领域；该术阵结束前不能","color":"gray","italic":false},{"text":"再次召唤术阵。领域内的生物每受到一次","color":"gray","italic":false},{"text":"攻击则立即有 X 道闪电对其造成伤害，每","color":"gray","italic":false},{"text":"道闪电的伤害为自身最大魔力值 ×0.1。生","color":"gray","italic":false},{"text":"物每受到 10 次雷击则损失自身 10% 最大","color":"gray","italic":false},{"text":"生命值，共持续 X×2 秒（X 为「天煌」","color":"gray","italic":false},{"text":"×0.005）。若魔力值不足则本次攻击视消","color":"gray","italic":false},{"text":"耗的魔力总数为「天煌」点数。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["thunderclap","axe","itemreplace"],tags:["lightning","max_mana","cur_mana","max_hp","formation","field","debuff"]},tooltip_display={hidden_components:["unbreakable"]}]
