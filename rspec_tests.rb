require 'rails_helper'

RSpec.describe Api::V2::Clients::FilterClients do
  let(:store) { create(:store) }
  let(:params) { {} }
  let(:client1) { crate :client, first_name: 'Andrew', last_name: 'Ballack', store: store }
  let(:client2) { crate :client, first_name: 'Brandon', last_name: 'Wilsher', store: store }
  let(:service) { described_class.new(store, params) }

  describe '#call' do
    subject { service.call }

    context 'without any filters' do
      it 'returns all clients' do
        expect(subject).to match_array([client1, client2])
      end
    end

    context 'with created date filter' do
      let(:params) do
        {
          created_start_date: '2023-01-01',
          created_end_date: '2023-12-31'
        }
      end

      before do
        client1.update(profile_created_at: '2023-05-01')
        client2.update(profile_created_at: '2024-01-01')
      end

      it 'returns clients created within the date range' do
        expect(subject).to match_array([client1])
      end
    end

    context 'with lead type filter' do
      let(:params) { { lead_types: 'type1,type2' } }

      before do
        client1.update(client_lead_type: 'type1')
        client2.update(client_lead_type: 'type3')
      end

      it 'returns clients with specified lead types' do
        expect(subject).to match_array([client1])
      end
    end

    context 'with membership type filter' do
      let(:params) { { membership_types: 'gold,platinum' } }

      before do
        client1.update(membership_type: 'gold')
        client2.update(membership_type: 'silver')
      end

      it 'returns clients with specified membership types' do
        expect(subject).to match_array([client1])
      end
    end

    context 'with first visit date filter' do
      let(:params) do
        {
          first_visit_start_date: '2023-01-01',
          first_visit_end_date: '2023-12-31'
        }
      end

      before do
        client1.update(first_visit_date: '2023-05-01')
        client2.update(first_visit_date: '2024-01-01')
      end

      it 'returns clients with first visit dates within the range' do
        expect(subject).to match_array([client1])
      end
    end

    context 'with multiple filters' do
      let(:params) do
        {
          created_start_date: '2023-01-01',
          created_end_date: '2023-12-31',
          lead_types: 'type1',
          membership_types: 'gold',
          first_visit_start_date: '2023-01-01',
          first_visit_end_date: '2023-12-31'
        }
      end

      before do
        client1.update(profile_created_at: '2023-05-01', client_lead_type: 'type1', membership_type: 'gold', first_visit_date: '2023-05-01')
        client2.update(profile_created_at: '2023-05-01', client_lead_type: 'type2', membership_type: 'gold', first_visit_date: '2023-05-01')
      end

      it 'returns clients that match all filters' do
        expect(subject).to match_array([client1])
      end
    end
  end
end
