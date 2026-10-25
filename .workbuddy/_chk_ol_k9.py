# -*- coding: utf-8 -*-
"""
_chk_ol_k9.py —— 批 K9（法杖 5 件：五世恶咒 / 倾囊 / 决堤 / 启示录 / 命缕
                        + 补做的 堕梦 / 引雷针 / 折径）的定点自检

只查"改错了不会报错、只会静默跑歪"的那几处：
  1. 回锋口径纠正：倍率必须是"每段 ×2"，不是整轮统一 ×32
  2. 五世恶咒：三档参数表、终世百分比记在目标身上、破甲按百分比实算
  3. 堕梦：系数/次数记在目标身上、20% 时停走 lib/timestop
  4. 引雷针：三道雷必须错开（无敌帧）、附伤走 max_mana_mul
  5. 折径：pick_mul 表要覆盖到 m8、层数上限、结束段排在清标签之前
"""
import io, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
FUNC = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function")

bad = []


def path(rel):
    return os.path.join(FUNC, rel.replace("/", os.sep))


def lines(rel):
    p = path(rel)
    if not os.path.exists(p):
        bad.append("缺文件: " + rel)
        return []
    return io.open(p, encoding="utf-8").read().splitlines()


def where(rel, needle):
    for i, l in enumerate(lines(rel)):
        if needle in l:
            return i
    return -1


def exist(rel, needles, tag):
    ls = lines(rel)
    for n in needles:
        if not any(n in l for l in ls):
            bad.append("%s: %s 里缺 %r" % (tag, rel, n))


def absent(rel, needles, tag):
    ls = lines(rel)
    for n in needles:
        if any(n in l for l in ls):
            bad.append("%s: %s 里不该再有 %r" % (tag, rel, n))


# ============ 0. 回锋：倍率"每段翻倍" ============
exist("equipment/sword/rebound/cast.mcfunction",
      ["scoreboard players set @s zx.rb_omul 2000", "zx.rb_ol"], "回锋·cast")
exist("equipment/sword/rebound/tick_step.mcfunction",
      ["zx.rb_ol matches 1 run scoreboard players operation @s zx.rb_omul *= #2 zx.meta"],
      "回锋·tick_step")
# cast 里不能再有"按层数一次性给倍率"的旧写法
absent("equipment/sword/rebound/cast.mcfunction",
       ["if score @s zx.rb_blade matches 4 run scoreboard players set @s zx.rb_omul 32000"],
       "回锋·cast(旧口径残留)")
# omul 翻倍必须排在 recalc 之前（否则这一段用的还是上一段的倍率）
i_mul = where("equipment/sword/rebound/tick_step.mcfunction", "zx.rb_omul *= #2 zx.meta")
i_calc = where("equipment/sword/rebound/tick_step.mcfunction", "rebound/recalc")
if i_mul < 0 or i_calc < 0 or i_mul > i_calc:
    bad.append("回锋·tick_step: omul ×= #2 必须排在 recalc 之前")

# ============ 1. 五世恶咒 ============
exist("equipment/staff/five_curses/ol_tier.mcfunction",
      ["#fcv_t1", "#fcv_sl2", "#fcv_v3", "#fcv_apct", "#fcv_t5", "#fcv_fin"], "五世·ol_tier")
exist("equipment/staff/five_curses/curse_step.mcfunction",
      ["function sweetdream:equipment/staff/five_curses/ol_tier",
       "scoreboard players operation @s zx.fcv_pct = #fcv_fin zx.meta"], "五世·curse_step")
# 终世百分比必须由 final 自己从目标身上读，调用方不再 set 全局假名
exist("equipment/staff/five_curses/final.mcfunction",
      ["execute if score @s zx.fcv_pct matches 1.. run scoreboard players operation #fcv_pct zx.meta = @s zx.fcv_pct"],
      "五世·final")
absent("equipment/staff/five_curses/curse_step.mcfunction",
       ["scoreboard players set #fcv_pct zx.meta 30"], "五世·curse_step(旧全局假名)")
# 破甲按百分比实算（不再是写死的 ÷2）
exist("equipment/staff/five_curses/armor_cut.mcfunction",
      ["*= #fcv_apct zx.meta", "/= #100 zx.meta"], "五世·armor_cut")
# 三世易伤读目标身上的千分比
exist("internal/damage/vuln_fcv3.mcfunction",
      ["zx.fcv_3v matches 1..", "*= #v3m zx.meta", "/= #100 zx.meta"], "五世·vuln_fcv3")
if where("internal/damage/vuln_fcv3.mcfunction", "/= #1000 zx.meta") >= 0:
    bad.append("五世·vuln_fcv3: 单位换算写成了 ÷1000（会变成 ×0.12），必须是 ÷100")
# 主动：650 蓝 / 100 秒 / 返还 60
exist("equipment/staff/five_curses/skill.mcfunction",
      ["mana set value 650.0", "cooldown_seconds set value 100.0", "#fcv_km zx.meta 120"],
      "五世·skill")

# ============ 2. 堕梦 ============
exist("equipment/staff/fallen_dream/skill.mcfunction",
      ["mana set value 600.0", "fz.ticks set value 80", "zx.ts_end 20"], "堕梦·skill")
exist("equipment/staff/fallen_dream/one.mcfunction",
      ["#fd_k zx.meta 5", "#fd_k zx.meta 8", "zx.fd_n matches 7..", "zx.fd_n 1"], "堕梦·one")
# 系数必须先按"当前次数"判档、再 +1（否则第 7 次就吃不到 ×0.08）
o = "equipment/staff/fallen_dream/one.mcfunction"
i_pick = where(o, "#fd_k zx.meta 8")
i_add = where(o, "scoreboard players add @s zx.fd_n 1")
if i_pick < 0 or i_add < 0 or i_pick > i_add:
    bad.append("堕梦·one: 判档(×0.08)必须排在 zx.fd_n +1 之前")
exist("equipment/staff/fallen_dream/ol_stop.mcfunction",
      ["%= #5 zx.meta", "lib/timestop", 'ticks:20'], "堕梦·ol_stop")
exist("equipment/staff/fallen_dream/attack.mcfunction", ["ball.ol set value 1b"], "堕梦·attack")

# ============ 3. 引雷针 ============
exist("equipment/staff/thunderrod/skill.mcfunction",
      ["mana set value 240.0", "limit=7", "zx.tr_bonus matches 1 run function"], "引雷针·skill")
exist("equipment/staff/thunderrod/ol_volley.mcfunction",
      ["#tr_d zx.meta 10", "#tr_d zx.meta 20"], "引雷针·ol_volley")
exist("equipment/staff/thunderrod/ol_bolt.mcfunction", ["max_mana_mul:0.1"], "引雷针·ol_bolt")
exist("equipment/staff/thunderrod/pend_go_sk.mcfunction",
      ["zx.tr_ol $(ol)", "bolt_skill"], "引雷针·pend_go_sk")
# 宏函数：每一行 $ 都必须含 $(变量)
for f in ["equipment/staff/thunderrod/pend_go_sk.mcfunction",
          "equipment/staff/thunderrod/skill_q.mcfunction"]:
    for l in lines(f):
        if l.startswith("$") and "$(" not in l:
            bad.append("引雷针·%s: $ 宏行不含 $(变量) ⇒ 整函数作废" % f)
# 排队雷必须有 tick 驱动
exist("core/tick.mcfunction", ["tag=zx.tr_sk"], "引雷针·core/tick")

# ============ 4. 折径 ============
exist("equipment/staff/bent_ray/pick_mul.mcfunction",
      ["m7:3.5831808", "m8:4.29981696", "matches 8.."], "折径·pick_mul")
exist("equipment/staff/bent_ray/chain.mcfunction",
      ["#br_max zx.meta 8", "distance=0.01..8", "ol_side_n", "fixed_add set value 18.0",
       "max_mana_mul set value 0.05"], "折径·chain")
exist("equipment/staff/bent_ray/ol_end.mcfunction", ["max_mana_mul:0.08", "zx.br_used"], "折径·ol_end")
exist("equipment/staff/bent_ray/mark_zg.mcfunction", ["#br_cap zx.meta 3", "zx.br_gn"], "折径·mark_zg")
# 结束段必须排在**收尾那次**清 zx.br_used 之前
#   (⑥ 开头也有一行清残值的, 所以不能用"第一次出现"来比 —— 要比 ol_end 之后还有没有)
s = "equipment/staff/bent_ray/skill.mcfunction"
i_end = where(s, "bent_ray/ol_end")
ls = lines(s)
if i_end < 0:
    bad.append("折径·skill: 没有调 ol_end")
elif not any("remove zx.br_used" in l for l in ls[i_end + 1:]):
    bad.append("折径·skill: ol_end 必须排在收尾清 zx.br_used 之前")

# ============ 5. 记在生物身上的临时分数要有收尸 ============
exist("equipment/staff/fallen_dream/one.mcfunction",
      ["execute unless entity @s[tag=zx.fd_t] run scoreboard players set @s zx.fd_n 0"],
      "堕梦·收尸")
exist("equipment/staff/bent_ray/take_zg.mcfunction", ["reset @s zx.br_gn"], "折径·收尸")

print("---- K9 自检: %d 处问题" % len(bad))
for b in bad:
    print("  ! " + b)
sys.exit(1 if bad else 0)
