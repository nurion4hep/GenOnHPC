#!/usr/bin/env cmsRun
import FWCore.ParameterSet.Config as cms

process = cms.Process("Writer")

process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(-1))

process.source = cms.Source("PoolSource",
	fileNames = cms.untracked.vstring(
#    'root://cms-xrd-global.cern.ch//store/mc/RunIIAutumn18MiniAOD/TTTT_TuneCP5_13TeV-amcatnlo-pythia8/MINIAODSIM/102X_upgrade2018_realistic_v15_ext1-v2/80000/9B29ABFA-A026-C343-880B-C89A491A60BD.root',
    'root://cms-xrd-global.cern.ch//store/mc/RunIISummer20UL18MiniAODv2/TTJets_TuneCP5_13TeV-amcatnloFXFX-pythia8/MINIAODSIM/106X_upgrade2018_realistic_v16_L1v1-v2/2500000/42DEC12B-011A-924C-95FA-7216C34C2ADB.root',
  )
)

process.load("FWCore.MessageService.MessageLogger_cfi")
#process.MessageLogger.cerr.threshold = 'INFO'
process.MessageLogger.cerr.FwkReport.reportEvery = 1000

process.writer = cms.EDAnalyzer("LHEWriter",
    fileName = cms.untracked.string("out.lhe"),
)

process.outpath = cms.EndPath(process.writer)
