#!/usr/bin/env python
import FWCore.ParameterSet.Config as cms
from IOMC.RandomEngine.RandomServiceHelper import RandomNumberServiceHelper

def customise_random(process):
    if not hasattr(process, 'RandomNumberGeneratorService'): return process

    randSvc = RandomNumberServiceHelper(process.RandomNumberGeneratorService)
    randSvc.populate()
    return process

def customise_nEventsInLumi(process):
    if not hasattr(process, 'source'): return process

    setattr(process.source, 'numberEventsInLuminosityBlock', cms.untracked.uint32(100))
    return process

def customise_messageLogger(process):
    if not hasattr(process, 'MessageLogger'): return process

    process.MessageLogger.cerr.FwkReport.reportEvery = 1000
    return process

