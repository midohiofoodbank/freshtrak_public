# frozen_string_literal: true

describe Api::AgenciesController, type: :controller do
  let(:zip_code) { create(:zip_code) }
  let(:date) { (Date.today + 5).to_s }

  before do
    other_zip = create(:zip_code)
    other_date = (Date.today + 2).to_s.delete('-')

    foodbank = create(:foodbank, county_ids: zip_code.county.id)
    other_foodbank = create(:foodbank, county_ids: other_zip.county.id)

    @agency = create(:agency, foodbank: foodbank)
    other_agency = create(:agency, foodbank: other_foodbank)

    @event = create(:event, agency: @agency)
    other_event = create(:event, agency: other_agency)

    @event_date = create(:event_date, event: @event, date: date.delete('-'),
                                      start_time_key: 930, end_time_key: 2200)
    create(:event_date, event: other_event, date: other_date)
  end

  it 'should respond with no agencies without filter params' do
    get '/api/agencies'
    expect(response.status).to eq 200
    response_body = JSON.parse(response.body)
    expect(response_body['agencies']).to be_empty
  end

  it 'is indexable by zip_code' do
    get '/api/agencies', zip_code: zip_code.zip_code
    expect(response.status).to eq 200
    response_body = JSON.parse(response.body).deep_symbolize_keys
    expect(response_body).to eq(expected_response)
  end

  it 'should be indexable by event_date' do
    get '/api/agencies', event_date: date
    expect(response.status).to eq 200
    response_body = JSON.parse(response.body).deep_symbolize_keys
    expect(response_body).to eq(expected_response)
  end

  it 'should be indexable by zip_code and event_date' do
    get '/api/agencies', zip_code: zip_code.zip_code, event_date: date
    expect(response.status).to eq 200
    response_body = JSON.parse(response.body).deep_symbolize_keys
    expect(response_body).to eq(expected_response)
  end

  def expected_response
    {
      agencies: [
        {
          id: @agency.id,
          address: "#{@agency.address1} #{@agency.address2}",
          city: @agency.city,
          state: @agency.state,
          zip: @agency.zip,
          phone: @agency.phone,
          name: @agency.loc_name,
          nickname: @agency.loc_nickname,
          event_dates: [
            {
              id: @event_date.id,
              service: @event.service_description,
              start_time: '09:30 AM',
              end_time: '10:00 PM',
              date: date
            }
          ]
        }
      ]
    }
  end
end
