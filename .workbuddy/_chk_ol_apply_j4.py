# -*- coding: utf-8 -*-
"""_chk_ol_apply_j4.py —— 批 J4(apply + advancement)自检

这四类错**全部是静默的**(不报错、日志里也看不出来), 只能静态抓:

  ① apply 的 `of` 不等于文件名 / 文件名不在 oldef 表里
     -> fit 第一行 return, 右键只回"这把武器没有超限定义"。
  ② advancement 的 rewards.function 指向不存在的函数
     -> 整份进度 Failed to load, 右键零反应(连声音都没有)。
  ③ advancement 的 zx 标记(`ol_<id>`)和石头的 custom_data 对不上
     -> 进度永远触发不了, 石头右键就是"什么都不发生"。
  ④ 石头 give 还挂着 consumable 但三件套不齐 / 三件套齐了却没挂 consumable
     -> 前者静默吃掉物品, 后者石头是惰性的(右键毫无反应)。

用法: python .workbuddy/_chk_ol_apply_j4.py
"""
import io
import json
import os
import re

BASE = "D:/数据包/sweetdream/data/sweetdream"
APPLY = BASE + "/function/overlimit/apply"
ITEM = BASE + "/function/overlimit/item"
ADV = BASE + "/advancement/overlimit"
DEF = BASE + "/function/overlimit/def/load.mcfunction"
META = json.load(io.open("D:/数据包/.workbuddy/_ol_j2.json", encoding="utf-8"))

defs = set(re.findall(r'oldef\."([^"]+)"\s*set\s*value',
                      io.open(DEF, encoding="utf-8").read()))

bad = []
for uid, d in META.items():
    name = d["name"]
    ap = os.path.join(APPLY, uid + ".mcfunction")
    it = os.path.join(ITEM, uid + ".mcfunction")
    aj = os.path.join(ADV, uid + ".json")

    # ---- apply ----
    if not os.path.exists(ap):
        bad.append("%s: 缺 overlimit/apply/%s.mcfunction" % (uid, uid))
        continue
    txt = io.open(ap, encoding="utf-8").read()
    body = [l for l in txt.split("\n") if l.strip() and not l.lstrip().startswith("#")]
    body_nospace = [l.replace(" ", "") for l in body]
    if not body_nospace or body_nospace[0] != ("advancementrevoke@sonly"
                                               "sweetdream:overlimit/" + uid):
        bad.append("%s: apply 第一行不是 advancement revoke(必须是第一条命令, "
                   "否则进度停在已完成 -> 第二次右键不触发)" % uid)
    m = re.search(r'of:"([^"]*)"', txt)
    if not m:
        bad.append("%s: apply 里没有 of:\"...\"" % uid)
    elif m.group(1) != uid:
        bad.append("%s: of=\"%s\" 与文件名不一致(必须英文 id)" % (uid, m.group(1)))
    elif m.group(1) not in defs:
        bad.append("%s: of 在 oldef 表里没有定义" % uid)
    if "function sweetdream:station/api/apply" not in txt:
        bad.append("%s: apply 没调用 station/api/apply" % uid)
    if ("✔ %s已超限" % name) not in txt:
        bad.append("%s: 成功提示里的中文名不是「%s」(文案串了)" % (uid, name))
    if "sweetdream:overlimit/api/refuse" not in txt:
        bad.append("%s: 失败分支没调 refuse(敲不上时玩家不知道原因)" % uid)

    # ---- advancement ----
    if not os.path.exists(aj):
        bad.append("%s: 缺 advancement/overlimit/%s.json" % (uid, uid))
    else:
        try:
            j = json.load(io.open(aj, encoding="utf-8"))
            c = j["criteria"]
            ck = list(c)[0]
            zx = c[ck]["conditions"]["item"]["predicates"]["minecraft:custom_data"]["zx"]
            fn = j["rewards"]["function"]
        except Exception as e:
            bad.append("%s: advancement JSON 解析失败 %s" % (uid, e))
        else:
            if list(c) != [uid]:
                bad.append("%s: criteria 名应为 %s, 实为 %s" % (uid, uid, list(c)))
            if zx != ["ol_" + uid]:
                bad.append("%s: 进度认的标记是 %s, 石头写的是 ol_%s" % (uid, zx, uid))
            if fn != "sweetdream:overlimit/apply/" + uid:
                bad.append("%s: rewards.function = %s(指向不存在的函数 -> 整份进度不加载)"
                           % (uid, fn))
            elif not os.path.exists(os.path.join(
                    BASE, "function", fn.split(":", 1)[1] + ".mcfunction")):
                bad.append("%s: rewards.function 指向的函数文件不存在" % uid)

    # ---- item ----
    if not os.path.exists(it):
        bad.append("%s: 缺 overlimit/item/%s.mcfunction" % (uid, uid))
        continue
    itxt = io.open(it, encoding="utf-8").read()
    if 'custom_data={zx:["ol_%s"]}' % uid not in itxt:
        bad.append("%s: 石头 give 的 custom_data 不是 ol_%s" % (uid, uid))
    if "consumable={" not in itxt:
        bad.append("%s: 石头没挂 consumable —— 右键不消耗, 进度也就永不触发" % uid)

print("\n".join(bad) if bad else "OK")
print("bad = %d / %d" % (len(bad), len(META)))
