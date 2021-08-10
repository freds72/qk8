import sys
import os
import io
import math
import logging
from antlr4 import *
from MAPINFOLexer import MAPINFOLexer
from MAPINFOParser import MAPINFOParser
from MAPINFOVisitor import MAPINFOVisitor
from MAPINFOListener import MAPINFOListener
from collections import namedtuple
from dotdict import dotdict

class MAPINFO(MAPINFOListener):
  def __init__(self):
    self.maps = {}
    self.gameinfo = dotdict({
      "credits":"gAME eNGINE:,@fsouchu"
    })
    self.rounds = []

  def decodePair(self, pair):
    attribute = pair.keyword().getText().lower()
    value = pair.value(0).getText().strip('"')
    return (attribute, value)
  
  def newRound(self):
    self.round = dotdict({
      'sectors': [],
      'actors': []
    })

  def enterRoundblock(self, ctx):
    self.newRound()

  def exitRoundblock(self, ctx):
    for pair in ctx.pair():
      attribute, value = self.decodePair(pair)
      if attribute in ['duration']:
        value = int(value)
      self.round[attribute] = value
    self.rounds.append(self.round)
    self.newRound()
  
  def exitActorblock(self, ctx):
    actor = dotdict({
      'name': ctx.name().getText().lower()
    })
    for pair in ctx.pair():
      attribute, value = self.decodePair(pair)
      # todo: factor in "header"
      if attribute in ['health','armor','height','radius','amount','maxamount','damage','speed','ammogive','ammouse','icon','hudcolor','attacksound','pickupsound','deathsound','meleerange','maxtargetrange','respawntics']:
        value = int(value)
      elif attribute in ['drag']:
        value = float(value)
      actor[attribute] = value
    self.round.actors.append(actor)

  def exitSectorblock(self, ctx):
    sector = dotdict({
      'id': int(ctx.uid().getText())
    })
    for pair in ctx.pair():
      attribute, value = self.decodePair(pair)
      if attribute in ['floor','ceil']:
        value = float(value)
      elif attribute in ['lightlevel']:
        value = int(value)
      sector[attribute] = value
    self.round.sectors.append(sector)

  def exitMapblock(self, ctx):  
    lump = ctx.maplump().getText()
    label = ctx.label().getText().strip('"')
    logging.info("Found map entry: {} label: {}".format(lump, label))
    properties = {}
    for pair in ctx.pair():
      attribute = pair.keyword().getText().lower()
      value = pair.value(0).getText().strip('"')
      if attribute in ['levelnum','music']:
        value = int(value)
      elif attribute in ['location']:
        value = (int(value), int(pair.value(1).getText().strip('"')))
      
      # else string
      properties[attribute] = value
                
    self.maps[lump] = dotdict({
      'name': lump,
      'group': lump[:2].lower(),
      'label': label,
      # map location (optional)
      'location': properties.get('location', (-1,-1)),
      # background sky (optional)
      'sky': properties.get('sky1',None),
      # need first entry only
      'num': properties.get('levelnum',-1),
      # music (or none)
      'music': properties.get('music',-1),
      'next': properties.get('next','endgame')
    })
  
  def exitInfoblock(self, ctx):
    for pair in ctx.pair():
      attribute, value = self.decodePair(pair)
      self.gameinfo[attribute] = value

# Converts a TEXTURE file definition into a set of unique tiles + map index
class MapinfoReader(MAPINFOListener):
  def __init__(self, stream):
    self.stream = stream
  
  def read(self):    
    # get data
    data = self.stream.read("ZMAPINFO").decode('ascii')

    lexer = MAPINFOLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = MAPINFOParser(stream)
    tree = parser.maps()
    walker = ParseTreeWalker()

    listener = MAPINFO()
    walker.walk(listener, tree)
    
    # find first level
    curmap = next((m for n,m in listener.maps.items() if m.num==1), None)
    if curmap is None:
      raise Exception("ZMAPINFO: Missing starting map (levelnum=1)")
    allmaps = [curmap]
    while curmap is not None:
      if curmap.next == 'endgame':
        break
      if curmap.next not in listener.maps:
        raise Exception("ZMAPINFO: Map {} references unknown next map: {}".format(curmap.name, curmap.next))
      curmap = listener.maps[curmap.next]
      allmaps.append(curmap)

    return allmaps,listener.gameinfo,listener.rounds

