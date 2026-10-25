# -*- coding: utf-8 -*-
"""批 J4 · 32 块新超限石的**第三件套**: overlimit/apply/<id> + advancement/overlimit/<id>.json
(2026-10-23)

【这一轮补完什么】
  批 J2 只出了石头本体(give+图标), 批 J3 出了 oldef(名字/整段 lore/三个乘区 = 0)。
  现在 fit 的三道门都能过(oldef 有条目 / 副手 zx 含该 id / 还没敲过), 所以可以
  把"右键石头 -> 进度 consume_item -> apply -> station/api/apply(kind=overlimit)"
  这条链接上。接上之后 `_gen_ol_give_j2.py` 的 CONSUMABLE 才能改 True。

【★ 一个都不能少 ★】三件套缺任何一件都是**静默死**:
  · 缺 item/      -> 石头给不出来;
  · 缺 advancement -> 右键有声音、物品不减、什么都不发生(最像"没做");
  · 缺 apply/     -> 进度真的触发, 但 rewards 指向的函数不存在 ⇒ 整份进度
                     Failed to load, 右键同样零反应;
  · of 写中文名   -> fit 第一行 no_def(check.py 规则 80 专门守这条)。

【为什么 apply 逐字照抄老模板】这 28 个是线上验过的写法。唯一的变量是
  id 与中文名; 谁都能手抄, 但抄错一个字符就是整件废掉, 所以统一生成。

用法: python .workbuddy/_gen_ol_apply_j4.py [--dry]
"""
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = "D:/数据包/sweetdream/data/sweetdream"
APPLY = BASE + "/function/overlimit/apply"
ADV = BASE + "/advancement/overlimit"
J2 = HERE + "/_ol_j2.json"

DRY = "--dry" in sys.argv


def apply_txt(uid, name, cat):
    return """# ============================================================
# sweetdream:overlimit/apply/{uid} —— 右键用掉超限石去敲副手那件「{name}」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:overlimit/{uid}(consume_item), 以玩家身份
# 【流程】①撤销进度 ②交给 station/api/apply(kind=overlimit, of={uid})
#         ③成功 = 消耗成立; 失败 = 退材料 + 说明原因
# 【of 是什么】这块石头"属于哪件装备" —— overlimit/api/fit 会拿它去比对
#   副手的 zx(必须含 {uid}), 并且确认这件还没敲过 ol。
# 【批 J4 / 2026-10-23】{cat} 类。定义(名字 + 整段 lore)见
#   overlimit/def/load 的批 J3 段; 三个乘区目前全 0 —— 超限是"换机制",
#   数值不从这里加。机制本体(各件自己的 ol 钩子)另起一批。
# ============================================================

advancement revoke @s only sweetdream:overlimit/{uid}

data modify storage zx:work st set value {{kind:"overlimit",id:"",cat:"",cat2:"",of:"{uid}"}}
function sweetdream:station/api/apply

execute if data storage zx:out r{{ok:1b}} run tellraw @s [{{"text":"✔ {name}已超限","color":"green"}}]
execute if data storage zx:out r{{ok:1b}} run playsound minecraft:block.smithing_table.use player @s ~ ~ ~ 0.8 1.2
execute if data storage zx:out r{{ok:0b}} run function sweetdream:overlimit/item/{uid}
execute if data storage zx:out r{{ok:0b}} run function sweetdream:overlimit/api/refuse
""".format(uid=uid, name=name, cat=cat)


def adv_json(uid):
    j = {
        "criteria": {
            uid: {
                "trigger": "consume_item",
                "conditions": {
                    "item": {
                        "predicates": {
                            "minecraft:custom_data": {
                                "zx": ["ol_" + uid]
                            }
                        }
                    }
                }
            }
        },
        "rewards": {"function": "sweetdream:overlimit/apply/" + uid}
    }
    return json.dumps(j, ensure_ascii=False, indent=4) + "\n"


def main():
    meta = json.load(io.open(J2, encoding="utf-8"))
    os.makedirs(APPLY, exist_ok=True)
    os.makedirs(ADV, exist_ok=True)
    n_new = n_old = 0
    for uid, d in meta.items():
        ap = os.path.join(APPLY, uid + ".mcfunction")
        if os.path.exists(ap):
            n_old += 1
            print("skip %-16s apply 已存在(不覆盖)" % uid)
            continue
        if not DRY:
            io.open(ap, "w", encoding="utf-8", newline="\n").write(
                apply_txt(uid, d["name"], d["cat"]))
            io.open(os.path.join(ADV, uid + ".json"), "w",
                    encoding="utf-8", newline="\n").write(adv_json(uid))
        n_new += 1
        print("ok   %-16s %-3s %-6s -> apply + advancement" % (uid, d["no"], d["name"]))
    print("新增 %d, 跳过 %d, 合计 %d" % (n_new, n_old, len(meta)))


if __name__ == "__main__":
    main()
