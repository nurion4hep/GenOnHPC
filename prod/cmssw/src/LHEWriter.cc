#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/Run.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "FWCore/Utilities/interface/InputTag.h"

#include "SimDataFormats/GeneratorProducts/interface/LHERunInfoProduct.h"
#include "SimDataFormats/GeneratorProducts/interface/LHEEventProduct.h"

#include <algorithm>
#include <sstream>
#include <fstream>
#include <string>

class LHEWriter : public edm::EDAnalyzer {
public:
  explicit LHEWriter(const edm::ParameterSet &params);
  ~LHEWriter() override = default;

protected:
  void beginRun(const edm::Run &run, const edm::EventSetup &es) override {};
  void endRun(const edm::Run &run, const edm::EventSetup &es) override;
  void analyze(const edm::Event &event, const edm::EventSetup &es) override;

private:
  const std::string fileName_;
  std::stringstream buffer_;

  edm::EDGetTokenT<LHERunInfoProduct> tokenLHERunInfo_;
  edm::EDGetTokenT<LHEEventProduct> tokenLHEEvent_;
};

LHEWriter::LHEWriter(const edm::ParameterSet &params):
  fileName_(params.getUntrackedParameter<std::string>("fileName"))
{
  auto label = params.getUntrackedParameter<edm::InputTag>("moduleLabel", std::string("externalLHEProducer"));
  tokenLHERunInfo_ = consumes<LHERunInfoProduct,edm::InRun>(label);
  tokenLHEEvent_ = consumes<LHEEventProduct>(label);
}

void LHEWriter::endRun(const edm::Run &run, const edm::EventSetup &es)
{
  edm::Handle<LHERunInfoProduct> product;
  run.getByToken(tokenLHERunInfo_, product);

  std::ofstream outFile(fileName_, std::ios_base::out);

  std::copy(product->begin(), product->end(),
      std::ostream_iterator<std::string>(outFile));
  outFile << buffer_.rdbuf() << "</LesHouchesEvents>";

  outFile.close();
}

void LHEWriter::analyze(const edm::Event &event, const edm::EventSetup &es)
{
  edm::Handle<LHEEventProduct> product;
  event.getByToken(tokenLHEEvent_, product);

  std::copy(product->begin(), product->end(),
            std::ostream_iterator<std::string>(buffer_));
}

DEFINE_FWK_MODULE(LHEWriter);
