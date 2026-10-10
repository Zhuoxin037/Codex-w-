#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""_scan_ent.py —— 离线扫描存档 entities/*.mca, 列出带指定标签的实体 NBT 摘要。

用法:
    python _scan_ent.py <存档目录> [关键词...]
关键词默认 = zx.pal_col / zx.bg_vtx / zx.sl_vtx

用途: 排查"实体到底存了什么 NBT"(比如 item_display 的 data 标签有没有落盘)。
"""
import sys, os, zlib, struct

# ---------------- 最小 NBT 解析 ----------------
TAG_END, TAG_BYTE, TAG_SHORT, TAG_INT, TAG_LONG, TAG_FLOAT, TAG_DOUBLE = 0, 1, 2, 3, 4, 5, 6
TAG_BYTE_ARRAY, TAG_STRING, TAG_LIST, TAG_COMPOUND, TAG_INT_ARRAY, TAG_LONG_ARRAY = 7, 8, 9, 10, 11, 12


class R:
    def __init__(s, b):
        s.b = b
        s.i = 0

    def u1(s):
        v = s.b[s.i]; s.i += 1; return v

    def i1(s):
        v = s.b[s.i]; s.i += 1
        return v - 256 if v > 127 else v

    def i2(s):
        v = struct.unpack_from('>h', s.b, s.i)[0]; s.i += 2; return v

    def i4(s):
        v = struct.unpack_from('>i', s.b, s.i)[0]; s.i += 4; return v

    def i8(s):
        v = struct.unpack_from('>q', s.b, s.i)[0]; s.i += 8; return v

    def f4(s):
        v = struct.unpack_from('>f', s.b, s.i)[0]; s.i += 4; return v

    def f8(s):
        v = struct.unpack_from('>d', s.b, s.i)[0]; s.i += 8; return v

    def s(s_):
        n = struct.unpack_from('>H', s_.b, s_.i)[0]; s_.i += 2
        v = s_.b[s_.i:s_.i + n].decode('utf-8', 'replace'); s_.i += n
        return v


def rd_payload(r, t):
    if t == TAG_BYTE:   return r.i1()
    if t == TAG_SHORT:  return r.i2()
    if t == TAG_INT:    return r.i4()
    if t == TAG_LONG:   return r.i8()
    if t == TAG_FLOAT:  return r.f4()
    if t == TAG_DOUBLE: return r.f8()
    if t == TAG_BYTE_ARRAY:
        n = r.i4(); v = r.b[r.i:r.i + n]; r.i += n; return list(v)
    if t == TAG_STRING: return r.s()
    if t == TAG_LIST:
        et = r.u1(); n = r.i4()
        return [rd_payload(r, et) for _ in range(n)]
    if t == TAG_COMPOUND:
        d = {}
        while True:
            tt = r.u1()
            if tt == TAG_END: break
            name = r.s()
            d[name] = rd_payload(r, tt)
        return d
    if t == TAG_INT_ARRAY:
        n = r.i4(); return [r.i4() for _ in range(n)]
    if t == TAG_LONG_ARRAY:
        n = r.i4(); return [r.i8() for _ in range(n)]
    raise ValueError('unknown tag %d' % t)


def parse_nbt(b):
    r = R(b)
    t = r.u1()
    if t != TAG_COMPOUND:
        return None
    r.s()  # root name
    return rd_payload(r, TAG_COMPOUND)


# ---------------- region 读取 ----------------
def chunks_of(path):
    data = open(path, 'rb').read()
    if len(data) < 8192:  # 空文件/截断的区域文件(0 字节也常见) —— 直接跳过
        return
    for k in range(1024):
        off, cnt = struct.unpack_from('>IB', data, k * 4)[0] >> 8, struct.unpack_from('>I', data, k * 4)[0] & 0xFF
        if off == 0:
            continue
        start = off * 4096
        ln = struct.unpack_from('>I', data, start)[0]
        comp = data[start + 4]
        raw = data[start + 5:start + 4 + ln]
        try:
            nbt = zlib.decompress(raw) if comp == 2 else raw
        except Exception:
            continue
        yield (k % 32, k // 32), nbt


def walk_entities(nbt):
    """从区块 NBT 里取出 Entities 列表(1.21.5 可能在根或 sections 里)。"""
    out = []
    if not nbt:
        return out
    ents = nbt.get('Entities')
    if isinstance(ents, list):
        out += [e for e in ents if isinstance(e, dict)]
    return out


def brief(e):
    t = e.get('id', '?')
    tags = e.get('Tags', [])
    keys = sorted(e.keys())
    has_data = 'data' in e
    d = e.get('data')
    line = 'type=%s tags=%s keys=%s' % (t, tags, ','.join(keys))
    if has_data:
        line += '  data=%s' % (str(d)[:400])
    return line


def main():
    save = sys.argv[1]
    keys = sys.argv[2:] or ['zx.pal_col', 'zx.bg_vtx', 'zx.sl_vtx']
    ent_dir = os.path.join(save, 'entities')
    if not os.path.isdir(ent_dir):
        print('没有 entities 目录:', ent_dir); return
    hits = 0
    for fn in sorted(os.listdir(ent_dir)):
        if not fn.endswith('.mca'):
            continue
        p = os.path.join(ent_dir, fn)
        for (cx, cz), raw in chunks_of(p):
            for kw in keys:
                if kw.encode() not in raw:
                    continue
                nbt = parse_nbt(raw)
                if not nbt:
                    continue
                for e in walk_entities(nbt):
                    tags = e.get('Tags') or []
                    if kw in tags:
                        hits += 1
                        print('[%s chunk %d,%d] %s' % (fn, cx, cz, brief(e)))
    print('---- 命中 %d 个 ----' % hits)


if __name__ == '__main__':
    main()
