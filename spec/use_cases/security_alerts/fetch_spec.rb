describe UseCases::SecurityAlerts::Fetch do
  context 'with no applications' do
    it 'does not call the gateway' do
      fetch_gemfiles_use_case = double(execute: [])
      gateway = spy

      described_class.new(
        fetch_gemfiles_use_case: fetch_gemfiles_use_case,
        security_alert_gateway: gateway
      ).execute

      expect(gateway).not_to have_received(:execute)
    end

    it 'returns an empty list' do
      fetch_gemfiles_use_case = double(execute: [])
      gateway = spy

      result = described_class.new(
        fetch_gemfiles_use_case: fetch_gemfiles_use_case,
        security_alert_gateway: gateway
      ).execute

      expect(result).to be_empty
    end
  end

  context 'with one application' do
    it 'calls the gateway with the application name' do
      fetch_gemfiles_use_case = double(execute: [
        {
          application_name: 'foo-app'
        }
      ])
      gateway = spy

      described_class.new(
        fetch_gemfiles_use_case: fetch_gemfiles_use_case,
        security_alert_gateway: gateway
      ).execute

      expect(gateway).to have_received(:execute).with(application_name: 'foo-app')
    end

    context 'with no alerts returned from the gateway' do
      it 'returns an empty list' do
        fetch_gemfiles_use_case = double(execute: [
          {
            application_name: 'foo-app'
          }
        ])

        gateway = double(execute: [])

        result = described_class.new(
          fetch_gemfiles_use_case: fetch_gemfiles_use_case,
          security_alert_gateway: gateway
        ).execute

        expect(result).to eq([])
      end
    end

    context 'with one alert returned from the gateway' do
      it 'returns a list returning the application name and alerts' do
        fetch_gemfiles_use_case = double(execute: [
          {
            application_name: 'foo-app'
          }
        ])

        gateway = double(execute: [
          Domain::SecurityAlert.new(
            gem: 'rubocop',
            criticality: 'high',
            patched_versions: '> 2.3.5'
          )
        ])

        result = described_class.new(
          fetch_gemfiles_use_case: fetch_gemfiles_use_case,
          security_alert_gateway: gateway
        ).execute

        expect(result).to eq([{
          application_name: 'foo-app',
          alerts: [{
            gem: 'rubocop',
            criticality: 'high',
            patched_versions: '> 2.3.5'
          }]
        }])
      end
    end

    context 'with two alerts returned from the gateway' do
      it 'returns a list containing both alerts' do
        fetch_gemfiles_use_case = double(execute: [
          {
            application_name: 'foo-app'
          }
        ])

        gateway = double(execute: [
          Domain::SecurityAlert.new(
            gem: 'rubocop',
            criticality: 'high',
            patched_versions: '> 2.3.5'
          ),
          Domain::SecurityAlert.new(
            gem: 'rails',
            criticality: 'low',
            patched_versions: '>= 1.2.3'
          )
        ])

        result = described_class.new(
          fetch_gemfiles_use_case: fetch_gemfiles_use_case,
          security_alert_gateway: gateway
        ).execute

        expect(result).to eq([{
          application_name: 'foo-app',
          alerts: [
            {
              gem: 'rubocop',
              criticality: 'high',
              patched_versions: '> 2.3.5'
            }, {
              gem: 'rails',
              criticality: 'low',
              patched_versions: '>= 1.2.3'
            }
          ]
        }])
      end
    end
  end

  context 'with two applications' do
    it 'calls the gateway for each application' do
      fetch_gemfiles_use_case = double(execute: [
        {
          application_name: 'foo-app'
        }, {
          application_name: 'bar-app'
        }
      ])

      gateway = spy

      described_class.new(
        fetch_gemfiles_use_case: fetch_gemfiles_use_case,
        security_alert_gateway: gateway
      ).execute

      expect(gateway).to have_received(:execute).with(application_name: 'foo-app')
      expect(gateway).to have_received(:execute).with(application_name: 'bar-app')
    end

    context 'with security alerts for one application' do
      it 'returns a list containing only the application with security alerts' do
        fetch_gemfiles_use_case = double(execute: [
          {
            application_name: 'foo-app'
          }, {
            application_name: 'bar-app'
          }
        ])

        foo_app_alerts = [
          Domain::SecurityAlert.new(
            gem: 'rubocop',
            criticality: 'high',
            patched_versions: '> 2.3.5'
          )
        ]
        gateway = double

        allow(gateway)
          .to receive(:execute)
          .with(application_name: 'foo-app')
          .and_return(foo_app_alerts)

        allow(gateway).to receive(:execute).with(application_name: 'bar-app').and_return([])

        result = described_class.new(
          fetch_gemfiles_use_case: fetch_gemfiles_use_case,
          security_alert_gateway: gateway
        ).execute

        expect(result).to eq([{
          application_name: 'foo-app',
          alerts: [{
            gem: 'rubocop',
            criticality: 'high',
            patched_versions: '> 2.3.5'
          }]
        }])
      end
    end
  end
end
