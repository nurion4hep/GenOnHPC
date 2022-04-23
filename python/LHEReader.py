#!/usr/bin/env python
#import xml.etree.ElementTree as ET
import lxml.etree as ET
import gzip
import numpy as np

class LHEInit:
    ## HEPRUP block, Contains process information
    ##   common /HEPRUP/ IDBMUP(2), EBMUP(2), PDFGUP(2), PDFSUP(2),
    ##                   IDWTUP, NPRUP, XSECUP(MAXPUP), XERRUP(MAXPUP),
    ##                   XMAXUP(MAXPUP), LPRUP(MAXPUP)
    def __init__(self, text):
        self.__text = str(text).strip()
        lines = self.__text.split('\n')

        ## Beam information and process informations
        items = lines[0].strip().split()
        self.id1, self.id2 = [int(x) for x in items[0:2]]
        self.energy1, self.energy2 = [float(x) for x in items[2:4]]
        self.pdfgrp1, self.pdfgrp2, self.pdfId1, self.pdfId2 = [int(x) for x in items[4:8]]
        self.weightStrategy = int(items[8])
        self.nProc = int(items[9])

        ## Per-process information
        self.__procInfo = {}
        for i in range(1, self.nProc+1):
            items = lines[i].strip().split()
            xsec, xsecErr, maxWeight = [float(x) for x in items[:3]]
            procId = int(items[3])
            self.__procInfo[procId] = (xsec, xsecErr, maxWeight)

    @property
    def procInfo(self, procId):
        return self.__procInfo[procId]

    @property
    def text(self):
        return self.__text

class LHEParticle:
    def __init__(self, text):
        items = text.strip().split()
        self.pid, self.status = [int(x) for x in items[0:2]]
        self.mother1, self.mother2, self.color1, self.color2 = [int(x) for x in items[2:6]]
        self.px, self.py, self.pz, self.energy, self.mass = [float(x) for x in items[6:11]]
        self.time, self.spin = [float(x) for x in items[11:13]]

    def __str__(self):
        #s = ["id=%d status=%d mother=(%d,%d) color=(%d,%d)" % (self.pid, self.status, self.mother1, self.mother2, self.color1, self.color2),
        #     "p4=(%f,%f,%f,%f) m=%f t=%f spin=%f" % (self.px, self.py, self.pz, self.energy, self.mass, self.time, self.spin)]
        #return '\n'.join(s)
        s = ["id=%d st=%d mo=(%d,%d)" % (self.pid, self.status, self.mother1, self.mother2),
             "pt=%f eta=%f phi=%f m=%f" % (self.pt, self.eta, self.phi, self.mass)]
        return ' '.join(s)

    @property
    def pt(self):
        return np.hypot(self.px, self.py)

    @property
    def p(self):
        return np.sqrt(self.px*self.px + self.py*self.py + self.pz*self.pz)

    @property
    def eta(self):
        if self.p == 0: return 0
        return 0.5*np.atanh(self.pz/self.p)

    @property
    def phi(self):
        return np.atan2(self.py, self.px)

    @property
    def rapidity(self):
        return 0.5*(np.log(self.energy+self.pz)-np.log(self.energy-self.pz))

class LHEEvent:
    def __init__(self, text):
        ## HEPEUP block, Contains event information and particles
        ##   common /HEPEUP/ NUP, IDPRUP, XWGTUP, SCALUP, AQEDUP, AQCDUP,
        ##   + IDUP(MAXNUP), ISTUP(MAXNUP), MOTHUP(2,MAXNUP),
        ##   + ICOLUP(2,MAXNUP), PUP(5,MAXNUP), VTIMUP(MAXNUP),
        ##   + SPINUP(MAXNUP)
        self.__text = str(text).strip()
        lines = self.__text.split('\n')

        ## Event information
        items = lines[0].strip().split()
        self.n, self.procId = [int(x) for x in items[0:2]]
        self.weight, self.scale, self.aQED, self.aQCD = [float(x) for x in items[2:6]]

        ## Particles
        self.particles = []
        for i in range(1, self.n+1):
            self.particles.append(LHEParticle(lines[i]))

        ## Additional information below the particle block
        self.comments = []
        for i in range(self.n+1, len(lines)):
            self.comments.append(lines[i])

    @property
    def text(self):
        return self.__text

    def __str__(self):
        s = ["Event information:",
             "  N=%d ProcId=%d Weight=%f Scale=%f aQED=%f aQCD=%f" % (self.n, self.procId, self.weight, self.scale, self.aQED, self.aQCD),
             "Particles:",]
        for p in self.particles:
            s.append("  "+str(p))

        return "\n".join(s)

    def to_array(self):
        attrs = ['pid', 'status', 'mother1', 'mother2', 'color1', 'color2', 'px', 'py', 'pz', 'energy', 'mass', 'time', 'spin']
        data = np.zeros((self.n, len(attrs)))
        for i in range(self.n):
            data[i] = [getattr(self.particles[i], attr) for attr in attrs]
        return data

class LHEReader:
    def __init__(self, fileName, debug=False):
        self.fileName = fileName
        self.debug = debug

        content = ""
        if self.debug: print("@@@ Input file =", self.fileName)
        if self.fileName.endswith(".lhe"):
            content = open(self.fileName).read()
        elif self.fileName.endswith(".gz"):
            content = gzip.open(self.fileName).read()
        if self.debug: print("@@@ Content size=", len(content))

        if self.debug: print("@@@ Parsing xml...")
        tree = ET.fromstring(content)
        if self.debug: print("@@@ done")

        #self.tree = tree
        lheHeader = tree.find('header')
        lheInit = tree.find('init')
        lheEvents = tree.findall('event')

        self.lheInit = LHEInit(lheInit.text)
        self.lheEvents = [LHEEvent(e.text) for e in lheEvents]

if __name__ == '__main__':
    import sys
    reader = LHEReader(sys.argv[1], debug=True)

    print("v"*80)
    print(reader.lheInit.text)
    print("-"*80)
    print(reader.lheEvents[0].to_array())
    print("^"*80)
