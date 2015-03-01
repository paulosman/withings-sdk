require 'date'

module Activite
  module Utils

    def self.normalize_date_params(options)
      opts = hash_with_string_date_keys(options)

      convert_epoch_date_params!(opts)
      convert_ymd_date_params!(opts)

      if opts.has_key? 'startdateymd' and !opts.has_key? 'startdate'
        opts['startdate'] = to_epoch(opts['startdateymd'])
      end
      if opts.has_key? 'enddateymd' and !opts.has_key? 'enddate'
        opts['enddate'] = to_epoch(opts['enddateymd'])
      end

      opts['startdateymd'] = to_ymd(opts['startdate'])      if opts.has_key? 'startdate'
      opts['enddateymd']   = to_ymd(opts['enddate'])        if opts.has_key? 'enddate'
      opts
    end

    private

    def self.hash_with_string_date_keys(params)
      p = params.dup
      date_fields = [:startdateymd, :enddateymd, :startdate, :enddate, :lastupdate]
      date_fields.each { |key| p[key.to_s] = p.delete(key) if p.has_key? key }
      p
    end

    def self.convert_ymd_date_params!(params)
      ymd_fields = ['startdateymd', 'enddateymd']
      ymd_fields.each do |key|
        params[key] = to_ymd(params[key]) if params.has_key? key
      end
    end

    def self.convert_epoch_date_params!(params)
      epoch_fields = ['startdate', 'enddate', 'lastdate', 'date']
      epoch_fields.each do |key|
        params[key] = to_epoch(params[key]) if params.has_key? key
      end
    end

    def self.to_epoch(d)
      if d.is_a? Date or d.is_a? DateTime
        d.strftime('%s').to_i
      elsif  d =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/
        DateTime.strptime(d, '%Y-%m-%d').strftime('%s').to_i
      else
        d
      end
    end

    def self.to_ymd(d)
      if d.is_a? Date or d.is_a? DateTime
        d.strftime('%Y-%m-%d')
      elsif (d =~ /[0-9]+/) != 0
        DateTime.strptime(d.to_s, '%s').strftime('%Y-%m-%d')
      else
        d
      end
    end
  end
end
