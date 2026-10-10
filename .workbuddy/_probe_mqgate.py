# -*- coding: utf-8 -*-
"""反向探针: 验证 check.py 的 mqgate 规则不是假绿

口径(用户 2026-10-08 定稿): 千散那段描述里的"本武器" = **千散** ——
剑魂整套机制只写在千散那段里, 所以清剑魂 / 按剑魂重复 / 进居合三件事都只认千散口径。
真实反馈: "为什么我使用万念后剑魂也会清除"(老实现只判 zx.mq_ol, 放万念把攒的清光)。

探针 A: tail 清剑魂那行删掉 `if score #mq_qs ...`              -> 应报 1 条
探针 B: tail 清剑魂那行删掉 `unless score #mq_pas ...`          -> 应报 1 条
探针 C: tail 末尾删掉复位 `set #mq_qs zx.meta 0`               -> 应报 1 条
探针 D: hit_go 两条"按剑魂重复"都删掉 `#mq_qs` 门控            -> 应报 2 条
探针 E: qiansan/cast 把口径声明从 1 改成 0                      -> 应报 1 条
探针 F: ju_check 进居合那行删掉 `#mq_qs` 门控                  -> 应报 1 条
每次探针后都还原, 全部跑完必须回到 0 条。

★ 注意: 单次 check.py 要约 16 秒, 全跑约 2 分钟 —— 别用默认 120 秒超时跑它,
  否则会被 SIGTERM 打断, 把某个文件留在"被拆过"的状态里(本脚本第一次就是这么
  把 ju_check 的门控留在文件里的, 反而被规则抓到 —— 也算顺带验证了规则会响)。
"""
import io, os, subprocess

ROOT = r'D:\数据包'
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
SW = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment', 'sword')
TAIL = os.path.join(SW, 'myriad', 'tail.mcfunction')
HIT = os.path.join(SW, 'myriad', 'hit_go.mcfunction')
JUC = os.path.join(SW, 'myriad', 'ju_check.mcfunction')
QSC = os.path.join(SW, 'qiansan', 'cast.mcfunction')


def run():
    p = subprocess.run([PY, os.path.join(ROOT, '.workbuddy', 'check.py')],
                       capture_output=True, text=True, encoding='utf-8', errors='ignore')
    n = None
    for line in p.stdout.splitlines():
        if line.startswith('[超限·万念/千散'):
            n = int(line.rsplit(']', 1)[1].strip().split()[0])
    return n


ORIG = {p: io.open(p, encoding='utf-8').read() for p in (TAIL, HIT, JUC, QSC)}


def restore():
    for p, s in ORIG.items():
        io.open(p, 'w', encoding='utf-8', newline='\n').write(s)


def _write(path, text):
    io.open(path, 'w', encoding='utf-8', newline='\n').write(text)


def probe(name, fn, expect=1):
    try:
        fn()
        n = run()
        print('%-38s -> 报 %s 条 (期望 %s) %s' % (name, n, expect, 'OK' if n == expect else 'FAIL'))
    finally:
        restore()


def a():    # 清剑魂丢了"千散口径"那道
    _write(TAIL, ORIG[TAIL].replace(
        'matches 1 if score #mq_qs zx.meta matches 1 unless', 'matches 1 unless'))


def b():    # 清剑魂丢了"非被动"那道
    _write(TAIL, ORIG[TAIL].replace(
        ' if score #mq_qs zx.meta matches 1 unless score #mq_pas zx.meta matches 1 run',
        ' if score #mq_qs zx.meta matches 1 run'))


def c():    # 末尾忘了复位通道标记
    _write(TAIL, ORIG[TAIL].replace(
        'scoreboard players set #mq_qs zx.meta 0\nscoreboard players set #mq_pas',
        'scoreboard players set #mq_pas'))


def d():    # 重复两条都丢了千散口径(应报 2 条)
    t = ORIG[HIT].replace(
        'if score #mq_qs zx.meta matches 1 run scoreboard players operation #mq_rep',
        'run scoreboard players operation #mq_rep')
    t = t.replace(
        'if score #mq_qs zx.meta matches 1 run scoreboard players add #mq_rep',
        'run scoreboard players add #mq_rep')
    _write(HIT, t)


def e():    # 千散那把把口径声明写成 0
    _write(QSC, ORIG[QSC].replace(
        'scoreboard players set #mq_qs zx.meta 1', 'scoreboard players set #mq_qs zx.meta 0'))


def f():    # 进居合丢了千散口径
    _write(JUC, ORIG[JUC].replace(
        'if score #mq_qs zx.meta matches 1 if score @s zx.mq_soul', 'if score @s zx.mq_soul'))


print('基线(未篡改) ->', run(), '条')
probe('探针 A(tail 清剑魂丢 #mq_qs)', a)
probe('探针 B(tail 清剑魂丢 #mq_pas)', b)
probe('探针 C(tail 末尾不复位 #mq_qs)', c)
probe('探针 D(hit_go 重复丢 #mq_qs × 2)', d, expect=2)
probe('探针 E(qiansan/cast 口径写成 0)', e)
probe('探针 F(ju_check 进居合丢 #mq_qs)', f)
restore()
print('还原后 ->', run(), '条')
