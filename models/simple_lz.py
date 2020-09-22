import time 
import sys 
import array 
from lzs import *

class Flashbits:
  def __init__(self,src):  
    self.src = src
    self.i = 0
    self.mask = 0x01
  
  def get1(self):
    r = (self.src[self.i] & self.mask) !=0 and 1 or 0
    self.mask <<= 1
    if self.mask>0x80:
      self.mask = 1
      self.i += 1
    return r

  def getn(self,n):
    r = 0
    for i in range(n):
      r <<= 1
      r |= self.get1()
    # print("got: {:02x} i: {}".format(r,self.i))
    return r

def decompress(src):
  dst=bytearray()
  history=bytearray()

  BS = Flashbits(src)
  O = BS.getn(4)
  max_offset = 1<<O
  L = BS.getn(4)
  M = BS.getn(2)
  end = BS.getn(32)
  print("max. offset:{} length:{} min. length:{} total length:{}".format(max_offset,L,M,end))
  while len(dst)<end:
    if BS.get1() == 0:
      v = BS.getn(8)
      dst.append(v)
      history.append(v)
      if len(history)>max_offset:
        history=history[1:]
    else:
      offset = -BS.getn(O) - 1
      length = BS.getn(L) + M
      for k in range(length):
        v = history[len(history)+offset]
        # print("offset: {} : {} => {:02x} : {:02x}".format(offset,255+offset,v,history[len(history)+offset]))
        dst.append(v)
        history.append(v)
        if len(history)>max_offset:
          history=history[1:]
    # print("LZ: {}".format(len(dst)))
  return dst

def main(): 
  from optparse import OptionParser 
  parser = OptionParser("%prog [ --lookback O ] [ --length L ] --name NAME inputfile outputfile") 
  parser.add_option("--lookback", type=int, default=8, dest="O", help="lookback field size in bits") 
  parser.add_option("--length", type=int, default=3, dest="L", help="length field size in bits") 
  parser.add_option("--name", type=str, default="data", dest="NAME", help="name for generated C array") 
  parser.add_option("--binary", action="store_true", default=False, dest="binary", help="write a binary file (default is to write a C++ header file)") 
  parser.add_option("--test", action="store_true", default=False, dest="test", help="Compress/decompress validation") 
  options, args = parser.parse_args() 
  if len(args) != 2: 
    parser.error("must specify input and output files"); 
    print(options.O)
    print(options.L)
    print(options.NAME) 
    print(args) 
  (inputfile, outputfile) = args 
  cc = Codec(b_off = options.O, b_len = options.L) 
  uncompressed = open(inputfile, "rb").read()
  if options.test:
    compressed = cc.toarray(uncompressed) 
    print("compressed: {} vs. raw: {}".format(len(compressed), len(uncompressed)))
    uncompressed_test = decompress(compressed)
    print("raw: {} vs. raw(2): {}".format(len(uncompressed), len(uncompressed_test)))
    print("check: {}".format(uncompressed==uncompressed_test))
    print(uncompressed_test)
  elif options.binary: 
    compressed = cc.toarray(uncompressed) 
    open(outputfile, "wb").write(compressed.tobytes()) 
  else: 
    outfile = open(outputfile, "w") 
    cc.to_cfile(outfile, uncompressed, options.NAME) 

if __name__ == "__main__": 
  main()