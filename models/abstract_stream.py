from abc import ABC, abstractmethod
# abstract class to work with resources (WAD or file based)
class Stream(ABC):
  # read resource 'name'
  # returns a bytearray
  @abstractmethod
  def read(self, name) -> bytearray:
      pass
  
  # returns all files
  @abstractmethod
  def directory(self) -> []:
    pass
  