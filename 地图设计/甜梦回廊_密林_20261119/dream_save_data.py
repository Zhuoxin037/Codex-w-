"""Rename stored pack references without relocating existing world dimensions."""

import gzip
from io import BytesIO
import re
import struct
import zlib

DIMENSIONS=("floor_1_forest","floor_2_trial","rogue_preview","training","tutorial")
NAMES=re.compile(r"sweetdream:(?:"+"|".join(DIMENSIONS)+r")(?![\w/])|sweetdream_floor|sweetdream",re.I)


def renamed(value):
    def replace(match):
        original=match[0]
        if len(original)>10:
            return original
        if original.isupper():
            return "FALLENDREAM"
        if original[0].isupper():
            return "Fallendream"
        return "fallendream"
    return NAMES.sub(replace,value).replace("甜梦", "坠梦")


def nbt(raw):
    source=BytesIO(raw)
    dest=BytesIO()
    fixed={1:1,2:2,3:4,4:8,5:4,6:8}
    array={7:1,11:4,12:8}

    def take(amount):
        value=source.read(amount)
        if amount<0 or len(value)!=amount:
            raise ValueError("Incomplete NBT payload")
        return value

    def string():
        size=struct.unpack(">H",take(2))[0]
        encoded=take(size)
        # Java NBT uses modified UTF-8. Namespace tokens and these Chinese
        # characters are byte-identical in both encodings.
        decoded=encoded.decode("utf-8",errors="surrogateescape")
        value=renamed(decoded).encode("utf-8",errors="surrogateescape")
        dest.write(struct.pack(">H",len(value)))
        dest.write(value)

    def payload(kind):
        if kind in fixed:
            dest.write(take(fixed[kind]))
        elif kind in array:
            length=take(4)
            dest.write(length)
            dest.write(take(array[kind]*struct.unpack(">i",length)[0]))
        elif kind==8:
            string()
        elif kind==9:
            code=take(1)
            length=take(4)
            dest.write(code+length)
            for _ in range(struct.unpack(">i",length)[0]):
                payload(code[0])
        elif kind==10:
            while named():
                pass
        else:
            raise ValueError(f"Unknown NBT tag {kind}")

    def named():
        code=take(1)
        dest.write(code)
        if code==b"\0":
            return False
        string()
        payload(code[0])
        return True

    named()
    if source.read(1):
        raise ValueError("Trailing bytes after NBT root")
    return dest.getvalue()


def dat(raw):
    data=gzip.decompress(raw)
    updated=nbt(data)
    return raw if updated==data else gzip.compress(updated,mtime=0)


def region(raw):
    if len(raw)<8192:
        return raw
    table=bytearray(raw[:8192])
    chunks=[]
    dirty=False
    for slot in range(1024):
        start=int.from_bytes(table[slot*4:slot*4+3],"big")*4096
        if not start:
            continue
        length=int.from_bytes(raw[start:start+4],"big")
        code=raw[start+4]
        if code not in (1,2,3):
            raise ValueError(f"Unsupported region compression {code}, slot {slot}")
        original=raw[start+5:start+4+length]
        uncompressed={1:gzip.decompress,2:zlib.decompress,3:bytes}[code](original)
        # Chunks with no matching text can retain their exact compressed bytes.
        if b"sweetdream" in uncompressed.lower() or "甜梦".encode() in uncompressed:
            updated=nbt(uncompressed)
            if updated!=uncompressed:
                original={1:gzip.compress,2:zlib.compress,3:bytes}[code](updated)
                dirty=True
        chunks.append((slot,struct.pack(">I",len(original)+1)+bytes([code])+original))
    if not dirty:
        return raw
    parts=[]
    offset=2
    for slot,current in chunks:
        sectors=(len(current)+4095)//4096
        if sectors>255:
            raise ValueError("Migrated chunk exceeds the region sector limit")
        table[slot*4:slot*4+4]=offset.to_bytes(3,"big")+bytes((sectors,))
        parts.append(current.ljust(sectors*4096,b"\0"))
        offset+=sectors
    return bytes(table)+b"".join(parts)
