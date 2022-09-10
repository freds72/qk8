import os
import io
from abstract_stream import Stream
from pathlib import Path

# filebased resource stream
class FileStream(Stream):
  def __init__(self, root, recursive=False):
    self.root = root
    if recursive:
      all_files = {}
      for root, subFolders, files in os.walk(root):
        for item in files:
          full_path = os.path.join(root,item)
          if os.path.isfile(full_path):
            all_files[Path(item).stem.upper()] = os.path.relpath(full_path, self.root)
      self.dir = all_files
    else:
      self.dir = {Path(f).stem.upper():f for f in os.listdir(root) if os.path.isfile(os.path.join(root, f))}

  # read a file from root directory  
  def read(self, name) -> bytearray:
    # direct file reference (ex: from TEXTURES)?
    filename = os.path.join(self.root, name)
    if not os.path.exists(filename):
      # try to rebase
      if name not in self.dir:
        raise Exception(f"Unknown file: {name}")
      filename = os.path.join(self.root, self.dir[name])
    with open(filename, 'rb') as file:
      return file.read()
  
  # returns all files
  def directory(self) -> []:
    return self.dir.keys()

  def open(self, name):
    return open(os.path.join(self.root, self.dir[name]), 'rb')
  