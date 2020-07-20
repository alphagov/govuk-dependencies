Dir.glob("./lib/{domain,use_cases,gateways,presenters}/**/*.rb").sort.each { |file| require file }
Dir.glob("./helpers/*.rb").sort.each { |file| require file }
