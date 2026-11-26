"""Check corridor visibility, traversal and the actual held map cache in the staged world."""

from collections import deque
import gzip
from itertools import product
import struct
import time

from architecture import PITCH,RADII,radius
from forest_layout import CENTER,MAP_ID,corridor
from verify_events import configure,command
from verify_geometry import layout
from verify import PLAYER,phase,status,tags,trigger,wait
from verify_dimension import enter,floor_block,map_edges,native


def open_cells(axis,first,second):
    blocks=layout(corridor(axis,first,second))
    last=PITCH-second
    at=lambda a,w,h: (a,h,w) if axis=='east' else (-w,h,a)
    passable={(a,w) for a in range(first,last+1) for w in range(-3,7)
              if all(blocks.get(at(a,w,y))=='air' for y in (1,2))}
    queue=deque([(first,0)])
    visited={(first,0)}
    while queue:
        u,v=queue.popleft()
        for x,z in ((u-1,v),(u+1,v),(u,v-1),(u,v+1)):
            if (x,z) in passable and (x,z) not in visited:
                visited.add((x,z)); queue.append((x,z))
    middle=(first+last)//2
    assert (last,0) in visited
    assert all((middle,w) not in passable for w in range(-3,4))
    assert all((first,w) in passable and (last,w) in passable for w in range(-3,4))


def edges(rooms):
    enabled=map_edges()
    for i,a in rooms.items():
        row,col=divmod(i,5)
        for axis,allowed,index,n in (('east',col<4,row*4+col,i+1),('south',row<4,20+i,i+5)):
            if allowed and enabled[index]=='1':
                yield axis,a,rooms[n]


def read_map():
    p=native.NATIVE/'world/data'/f'map_{MAP_ID}.dat'
    body=gzip.decompress(p.read_bytes())

    def nbt(name,kind,fmt):
        key=bytes((kind,))+struct.pack('>H',len(name))+name.encode('ascii')
        return struct.unpack_from(fmt,body,body.index(key)+len(key))[0]

    assert nbt('scale',1,'>b')==1
    assert nbt('xCenter',3,'>i')==nbt('zCenter',3,'>i')==CENTER
    key=b'\x07\x00\x06colors\x00\x00\x40\x00'
    start=body.index(key)+len(key)
    return body[start:start+16384]


def verify():
    configure()
    for axis,first,second in product(('east','south'),RADII,RADII):
        if first+second < 2*max(RADII):
            open_cells(axis,first,second)
    print('Both axes and all 16 possible room-size pairs pass the geometry checks.',flush=True)
    if PLAYER not in command('list'):
        native.clients()
    time.sleep(1)
    if 'sd.floor_run' in tags(PLAYER):
        trigger(3)
        wait(lambda: phase()==0 and status('#rv_clean','zx.meta')==0,'reset old layout probe')
    rooms=enter()
    assert len(rooms)==16
    checked=0
    for axis,room,target in edges(rooms):
        x,z,kind,_=room
        west=radius(kind); east=PITCH-radius(target[2]); middle=(west+east)//2
        xyz=lambda a,w: (x+a,z+w) if axis=='east' else (x-w,z+a)
        for a,w,expected in ((west,0,'air'),(east,0,'air'),(middle,0,'mossy_cobblestone'),(middle,5,'air')):
            bx,bz=xyz(a,w)
            assert floor_block(bx,81,bz,expected),(axis,room,target,a,w,expected)
        checked+=1
    assert checked>=15
    assert floor_block(0,319,72,'oak_planks')
    print(f'{checked} corridors have clear entrances, a solid screen and an open bypass.',flush=True)

    command('save-all flush')
    colors=read_map()
    entry_x,entry_z=(0-CENTER)//2+64,(72-CENTER)//2+64
    at=lambda x,z: colors[z*128+x]
    assert at(entry_x,entry_z)!=0
    assert at(entry_x,entry_z)!=at(4,4)
    print('The generated scale-1 color map places the entry at the actual (0,72) room.',flush=True)


if __name__=='__main__':
    verify()
