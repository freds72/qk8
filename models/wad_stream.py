import io
from abstract_stream import Stream

class WADStream(Stream):
  def __init__(self, file, lumps):
    self.file = file
    self.lumps = lumps

  def read(self, name):
    # read from WAD
    entry = self.lumps.get(name,None)
    if not entry:
      raise Exception("Unknown WAD resource: {}".format(name))

    self.file.seek(entry.lump_ofs)
    return self.file.read(entry.lump_size)

  def directory(self) -> []:
    return self.lumps