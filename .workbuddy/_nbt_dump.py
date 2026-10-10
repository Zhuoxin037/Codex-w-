# -*- coding: utf-8 -*-
"""
_nbt_dump.py —— 读 Minecraft 的 NBT 文件(gzip 或裸), 按路径打印。
用法:
    python _nbt_dump.py <文件>                # 打印根那一层的键
    python _nbt_dump.py <文件> Data.Player    # 打印某个子节点(点分路径, 数组用下标)
    python _nbt_dump.py <文件> Data.Player --json   # 以 JSON 输出(便于再加工)

为什么要它: 排查"游戏里没反应"时, 存档里那几份文件(scoreboard / command_storage /
playerdata)是**唯一的事实来源** —— 计分板账本、玩家的 stats、物品上的自定义字段
到底写进去没有, 一眼就能看出来, 不用靠猜。
存档里的文件在游戏"暂停/保存"之后是完整的; 游戏在跑也照样能读(只读不写)。
"""
import gzip, json, struct, sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')


class Cursor:
    def __init__(self, buf):
        self.b = buf
        self.i = 0

    def u(self, fmt, n):
        v = struct.unpack_from(fmt, self.b, self.i)[0]
        self.i += n
        return v

    def u8(self):
        return self.u('>B', 1)

    def i16(self):
        return self.u('>h', 2)

    def i32(self):
        return self.u('>i', 4)

    def i64(self):
        return self.u('>q', 8)

    def f32(self):
        return self.u('>f', 4)

    def f64(self):
        return self.u('>d', 8)

    def s(self):
        n = self.u('>H', 2)
        v = self.b[self.i:self.i + n]
        self.i += n
        return v.decode('utf-8', 'replace')

    def payload(self, t):
        if t == 1:
            return self.u8()
        if t == 2:
            return self.i16()
        if t == 3:
            return self.i32()
        if t == 4:
            return self.i64()
        if t == 5:
            return self.f32()
        if t == 6:
            return self.f64()
        if t == 7:
            n = self.i32()
            v = self.b[self.i:self.i + n]
            self.i += n
            return list(v)
        if t == 8:
            return self.s()
        if t == 9:
            et = self.u8()
            n = self.i32()
            return [self.payload(et) for _ in range(n)]
        if t == 10:
            d = {}
            while True:
                tt = self.u8()
                if tt == 0:
                    return d
                name = self.s()
                d[name] = self.payload(tt)
        if t == 11:
            n = self.i32()
            return [self.i32() for _ in range(n)]
        if t == 12:
            n = self.i32()
            return [self.i64() for _ in range(n)]
        raise ValueError('unknown tag %d at %d' % (t, self.i))


def load(path):
    raw = open(path, 'rb').read()
    if raw[:2] == b'\x1f\x8b':
        raw = gzip.decompress(raw)
    c = Cursor(raw)
    t = c.u8()
    _name = c.s()
    return c.payload(t)


def walk(root, path):
    cur = root
    for seg in path.split('.'):
        if seg == '':
            continue
        if isinstance(cur, list):
            cur = cur[int(seg)]
        elif isinstance(cur, dict):
            cur = cur[seg]
        else:
            raise KeyError('无法在 %r 上取 %r' % (type(cur), seg))
    return cur


def describe(v):
    if isinstance(v, dict):
        return 'compound(%d 键) %s' % (len(v), list(v.keys())[:12])
    if isinstance(v, list):
        if v and not isinstance(v[0], (dict, list)):
            return 'list(%d) %r' % (len(v), v[:8])
        return 'list(%d) 首元素: %s' % (len(v), describe(v[0]) if v else '-')
    return repr(v)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    f = sys.argv[1]
    path = ''
    want_json = False
    for a in sys.argv[2:]:
        if a == '--json':
            want_json = True
        else:
            path = a
    root = load(f)
    node = walk(root, path) if path else root
    if want_json:
        print(json.dumps(node, ensure_ascii=False, indent=1, default=str))
    else:
        if isinstance(node, dict):
            print('路径 %r 下有 %d 个键:' % (path or '<root>', len(node)))
            for k, v in node.items():
                print('  %-24s %s' % (k, describe(v)))
        else:
            print(describe(node))
    return 0


if __name__ == '__main__':
    sys.exit(main())
