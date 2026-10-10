# -*- coding: utf-8 -*-
"""把 full_00..31 降采样拼成一张总览图（临时工具，看完即弃）。

降采样是必需的：32 帧原尺寸排下来是 2400x3520，光看一张图就吃满了。
取 1/4 分辨率已经足够判断"帧与帧之间顺不顺、有没有跳变"。
"""
import sys, struct, zlib
sys.path.insert(0, r'D:/数据包/.workbuddy')

D = r'D:/数据包/.workbuddy/texlab_out/deepsea'
K = 4
COLS = 8
ROWS = 4


def rows_of(path):
    d = open(path, 'rb').read()
    w, h = struct.unpack('>II', d[16:24])
    off, idat = 8, b''
    while off < len(d):
        ln = struct.unpack('>I', d[off:off + 4])[0]
        if d[off + 4:off + 8] == b'IDAT':
            idat += d[off + 8:off + 8 + ln]
        off += 12 + ln
    raw = zlib.decompress(idat)
    st = 1 + w * 3
    return w, h, [raw[y * st + 1:(y + 1) * st] for y in range(h)]


def ck(t, dd):
    c = t + dd
    return struct.pack('>I', len(dd)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)


def main(prefix, n, out):
    fr = [rows_of(f'{D}/{prefix}_{i:02d}.png') for i in range(n)]
    w, h = fr[0][0], fr[0][1]
    cw, ch = w // K, h // K
    SW, SH = cw * COLS, ch * ROWS
    img = []
    for r in range(ROWS):
        for y in range(ch):
            line = bytearray()
            for c in range(COLS):
                i = r * COLS + c
                if i >= n:
                    line += bytes([16, 18, 26]) * cw
                    continue
                src = fr[i][2]
                sy = y * K
                for x in range(cw):
                    o = x * K * 3
                    line += src[sy][o:o + 3]
            img.append(bytes(line))
    png = (bytes([137, 80, 78, 71, 13, 10, 26, 10])
           + ck(b'IHDR', struct.pack('>IIBBBBB', SW, SH, 8, 2, 0, 0, 0))
           + ck(b'IDAT', zlib.compress(b''.join(bytes([0]) + r for r in img), 6))
           + ck(b'IEND', b''))
    open(out, 'wb').write(png)
    print(f'{out}  {SW}x{SH}')


if __name__ == '__main__':
    main('full', 32, f'{D}/_ov_full.png')
