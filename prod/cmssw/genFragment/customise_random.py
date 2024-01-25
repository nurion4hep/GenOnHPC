#!/usr/bin/env python
#import FWCore.ParameterSet.Config as cms
from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper

def customise_random(process):
    if not hasattr(process, 'RandomNumberGeneratorService'): return process

    randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)
    randSvc.populate()
    return process
