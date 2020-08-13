import os
import io
from abstract_stream import Stream
from pathlib import Path

# filebased resource stream
class FileStream(Stream):
  def __init__(self, root):
    self.root = root
    self.dir = {Path(f).stem.upper():f for f in os.listdir(root) if os.path.isfile(os.path.join(root, f))}

  # read a file from root directory  
  def read(self, name) -> bytearray:
    # direct file reference (ex: from TEXTURES)?
    filename = os.path.join(self.root, name)
    if not os.path.exists(filename):
      # try to rebase
      filename = os.path.join(self.root, self.dir[name])
    with open(filename, 'rb') as file:
      return file.read()
  
  def directory(self) -> []:
    return self.dir.keys()

  def open(self, name):
    return open(os.path.join(self.root, self.dir[name]), 'rb')
  