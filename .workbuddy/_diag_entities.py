# -*- coding: utf-8 -*-
"""统计存档 entities/*.mca 里的实体类型与数量（1.21.2+ 独立实体存储）。"""
import os, sys, zlib, struct, io, collections, glob

SAVE = r"D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\saves\测试包体"

def parse_nbt(data):
    f = io.BytesIO(data)
    def rd(n):
        return f.read(n)
    def rd_short():
        return struct.unpack(">h", rd(2))[0]
    def rd_int():
        return struct.unpack(">i", rd(4))[0]
    def rd_long():
        return struct.unpack(">q", rd(8))[0]
    def rd_str():
        n = struct.unpack(">H", rd(2))[0]
        return rd(n).decode("utf-8", "replace")
    def rd_payload(t):
        if t == 1: return struct.unpack(">b", rd(1))[0]
        if t == 2: return rd_short()
        if t == 3: return rd_int()
        if t == 4: return rd_long()
        if t == 5: return struct.unpack(">f", rd(4))[0]
        if t == 6: return struct.unpack(">d", rd(8))[0]
        if t == 7:
            n = rd_int(); return rd(n)
        if t == 8: return rd_str()
        if t == 9:
            et = struct.unpack(">b", rd(1))[0]; n = rd_int()
            return [rd_payload(et) for _ in range(n)]
        if t == 10:
            d = {}
            while True:
                tt = struct.unpack(">b", rd(1))[0]
                if tt == 0: return d
                name = rd_str()
                d[name] = rd_payload(tt)
        if t == 11:
            n = rd_int(); return [rd_int() for _ in range(n)]
        if t == 12:
            n = rd_int(); return [rd_long() for _ in range(n)]
        raise ValueError("bad tag %s" % t)
    t = struct.unpack(">b", rd(1))[0]
    if t == 0: return None
    rd_str()
    return rd_payload(t)

def iter_chunks(path):
    with open(path, "rb") as fh:
        raw = fh.read()
    if len(raw) < 8192:
        return
    for i in range(1024):
        off = struct.unpack(">I", b"\x00" + raw[i*4:i*4+3])[0]
        cnt = raw[i*4+3]
        if off == 0 or cnt == 0:
            continue
        start = off * 4096
        try:
            ln = struct.unpack(">I", raw[start:start+4])[0]
            ctype = raw[start+4]
            body = raw[start+5:start+4+ln]
            if ctype == 1:
                data = zlib.decompress(body)
            elif ctype == 2:
                data = zlib.decompress(body)
            elif ctype == 3:
                continue
            else:
                continue
        except Exception:
            continue
        try:
            yield parse_nbt(data)
        except Exception:
            continue

def main():
    counter = collections.Counter()
    tagcounter = collections.Counter()
    total = 0
    per_file = {}
    for p in sorted(glob.glob(os.path.join(SAVE, "entities", "*.mca"))):
        n = 0
        for ch in iter_chunks(p):
            for e in (ch.get("Entities") or []):
                total += 1; n += 1
                eid = e.get("id", "?")
                counter[str(eid)] += 1
                tags = e.get("Tags") or []
                for t in tags:
                    tagcounter[str(t)] += 1
        per_file[os.path.basename(p)] = n
    print("=== 每个文件实体数 ===")
    for k, v in per_file.items():
        print("  %-16s %d" % (k, v))
    print("=== 实体总数: %d ===" % total)
    print("=== 按类型 ===")
    for k, v in counter.most_common(40):
        print("  %-40s %d" % (k, v))
    print("=== 按标签 ===")
    for k, v in tagcounter.most_common(30):
        print("  %-40s %d" % (k, v))

main()
