# ============================================================
# sweetdream:equipment/armor/lethe_shore/set_bonus —— 套装: 记「最大魔力技能 +20%」
# ------------------------------------------------------------
# 【执行者】玩家本人   【无宏参数】
# 【存哪】玩家自己的计分项 zx.mm_add(百分点)
#   —— 这是**全包通用**的「最大魔力值技能倍率」加成槽(风行「风声」/ 无效 也用它),
#   由 lib/mm_add/hook_calc 在每次 api/damage/calc 时统一折进加算池的 mm 通道,
#   由下一次以最大魔力值结算的技能打出伤害时清零(见 lib/mm_add/take)。★ 2026-10-07 用户定稿: 原来那个
#   zx:data wg_bonus."<uuid>" + lib/max_mana_bonus 的一次性槽位整体去掉 ——
#   它和面板上的「最大魔力值技能倍率」在功能上完全重复。
# 【★ 本文件不再是宏函数 ★】加成从"按 uuid 拼 storage 路径"改成"玩家身上的计分项",
#   一条 `$` 都不需要 —— 调用方(end_lethe ⑧)也不再传 with storage zx:work lt。
# 【"不可叠加"怎么落】只在"当前没有加成"时才写(和原来 unless data ... 同义):
#   已有 mm_add 时不动它, 也不会把自己的 20 叠上去 ⇒ 连按两次套装不会变 +40%。
# 【20 = +20%】计分项存的是**百分点整数**, 与 lib/skill_mul/scan_mul 的写法一致。
# 【什么时候失效】2026-10-08 用户定稿: **没有倒计时** —— 拿了就一直挂着,
#   直到自身打出一次最大魔力值技能为止(回到文案"下一次"的原义)。
# ============================================================

# ① "当前有没有加成"记成 0/1(计分板"没分数"不等于 0, 所以先 add 0 把它建出来)
scoreboard players add @s zx.mm_add 0
scoreboard players set #lt_free zx.meta 0
execute unless score @s zx.mm_add matches 1.. run scoreboard players set #lt_free zx.meta 1

# ② 没有旧加成 -> 写 20 点、顶 20 秒
execute if score #lt_free zx.meta matches 1 run scoreboard players set @s zx.mm_add 20
