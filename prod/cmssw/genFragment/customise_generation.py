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

def customise_pruneGenParticles(process):
    process.load("PhysicsTools.PatAlgos.slimming.genParticles_cff")
    process.generation_step += process.prunedGenParticlesWithStatusOne
    process.generation_step += process.prunedGenParticles
    process.generation_step += process.packedGenParticles

    if hasattr(process, 'GENoutput'):
        process.GENoutput.outputCommands = [
            'drop *',
            #'keep edmHepMCProduct_source_*_*',
            'keep LHERunInfoProduct_*_*_*',
            'keep LHEEventProduct_*_*_*',
            'keep GenRunInfoProduct_generator_*_*',
            'keep GenLumiInfoProduct_generator_*_*',
            'keep GenEventInfoProduct_generator_*_*',
            #'keep edmHepMCProduct_generatorSmeared_*_*',
            'keep GenFilterInfo_*_*_*',
            #'keep *_genParticles_*_*',
            #'keep recoGenJets_ak*_*_*',
            #'keep *_ak4GenJets_*_*',
            #'keep *_ak8GenJets_*_*',
            #'keep *_ak4GenJetsNoNu_*_*',
            #'keep *_ak8GenJetsNoNu_*_*',
            #'keep *_genParticle_*_*',
            #'keep recoGenMETs_*_*_*',
            'keep *_randomEngineStateProducer_*_*',
        ]
        process.GENoutput.outputCommands.extend([
            'keep *_externalLHEProducer_LHEScriptOutput_*',
            'keep *_prunedGenParticles_*_*',
            'keep *_packedGenParticles_*_*',
        ])

    return process
