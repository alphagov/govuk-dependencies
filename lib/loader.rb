Dir.glob('./lib/{domain,use_cases,gateways,presenters}/**/*.rb').each { |file| require file }
Dir.glob('./helpers/*.rb').each { |file| require file }
