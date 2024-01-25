#!/usr/bin/env python
import FWCore.ParameterSet.Config as cms

def customise_nEventsInLumi(process):
    if not hasattr(process, 'source'): return process
    setattr(process.source, 'numberEventsInLuminosityBlock', cms.untracked.uint32(100))
    return process
