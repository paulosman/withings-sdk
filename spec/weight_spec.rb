describe Activite::Measure::Weight do

  let (:subject) { Activite::Measure::Weight.new(value: 87893, unit: -3) }

  it 'should normalize the value based on the value and the unit' do
    expect(subject.value).to eq(87.893)
  end

  it 'should return the value in kilograms' do
    expect(subject.in_kg).to eq(87.893)
  end

  it 'should return the value in pounds' do
    expect(subject.in_lb).to eq(193.771)
  end
    
end
