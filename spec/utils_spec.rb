require 'spec_helper'

describe Activite::Utils do

  let (:startdateymd) { Hash['startdateymd', '2012-01-01'] }
  let (:startdate)    { Hash['startdate',    1325376000 ] }
  let (:enddateymd)   { Hash['enddateymd',   '2015-05-12'] }
  let (:enddate)      { Hash['enddate',      1431388800 ] }

  describe '.normalize_date_params' do
    context 'when given a startdate in ymd format' do
      let (:opts) { subject.normalize_date_params(startdateymd) }

      it 'preserves startdateymd' do
        expect(opts['startdateymd']).to eq(startdateymd['startdateymd'])
      end

      it 'copies the value to startdate as a timestamp' do
        expect(opts['startdate']).to eq(startdate['startdate'])
      end
    end

    context 'when given an enddate in ymd format' do
      let (:opts) { subject.normalize_date_params(enddateymd) }

      it 'preserves enddateymd' do
        expect(opts['enddateymd']).to eq(enddateymd['enddateymd'])
      end

      it 'copies the value to enddate as a timestamp' do
        expect(opts['enddate']).to eq(enddate['enddate'])
      end
    end

    context 'when given a startdate in unix timestamp format' do
      let (:opts) { subject.normalize_date_params(startdate) }

      it 'preserves startdate' do
        expect(opts['startdate']).to eq(startdate['startdate'])
      end

      it 'copies the value to startdateymd in YYYY-MM-DD format' do
        expect(opts['startdateymd']).to eq('2012-01-01')
      end
    end

    context 'when given a Date instance' do
      context 'as a startdateymd param' do
        let(:startdateymd) { Hash['startdateymd', Date.new(2012, 01, 01)] }
        let(:opts) { subject.normalize_date_params(startdateymd) }

        it 'converts the Date instance into YYYY-MM-DD format' do
          expect(opts['startdateymd']).to eq('2012-01-01')
        end

        it 'converts the Date instance into timestamp format' do
          expect(opts['startdate']).to eq(1325376000)
        end
      end

      context 'as a startdate param' do
        let(:startdate) { Hash['startdate', Date.new(2012, 01, 01)] }
        let(:opts) { subject.normalize_date_params(startdate) }

        it 'converts the Date instance into YYYY-MM-DD format' do
          expect(opts['startdateymd']).to eq('2012-01-01')
        end

        it 'converts the Date instance into timestamp format' do
          expect(opts['startdate']).to eq(1325376000)
        end
      end
    end

    context 'when given a timestamp' do
      context 'as a startdateymd param' do
        let(:startdateymd) { Hash['startdateymd', 1325376000] }
        let(:opts) { subject.normalize_date_params(startdateymd) }

        it 'converts the timestamp into YYYY-MM-DD format' do
          expect(opts['startdateymd']).to eq('2012-01-01')
        end

        it 'copies the timestamp into the startdate param' do
          expect(opts['startdate']).to eq(1325376000)
        end
      end

      context 'as a startdate param' do
        let(:startdate) { Hash['startdate', 1325376000] }
        let(:opts) { subject.normalize_date_params(startdate) }

        it 'converts the timestamp into YYYY-MM-DD format' do
          expect(opts['startdateymd']).to eq('2012-01-01')
        end
      end
    end
  end

end
