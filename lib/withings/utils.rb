require 'date'

module Withings
  module Utils
    def self.normalize_date_params(options)
      opts = options.dup

      [:startdateymd, :enddateymd, :startdate, :enddate, :lastdate].each do |key|
        if opts.has_key? key
          opts[key.to_s] = opts[key]
          opts.delete(key)
        end
      end

      opts['startdateymd'] = to_ymd(opts['startdateymd'])   if opts.has_key? 'startdateymd'
      opts['enddateymd']   = to_ymd(opts['enddateymd'])     if opts.has_key? 'enddateymd'

      opts['startdate']    = to_epoch(opts['startdate'])    if opts.has_key? 'startdate'
      opts['enddate']      = to_epoch(opts['enddate'])      if opts.has_key? 'enddate'
      opts['lastupdate']   = to_epoch(opts['lastupdate'])   if opts.has_key? 'lastupdate'

      if opts.has_key? 'startdateymd' and !opts.has_key? 'startdate'
        opts['startdate'] = to_epoch(opts['startdateymd'])
      end
      if opts.has_key? 'enddateymd' and !opts.has_key? 'enddate'
        opts['enddate'] = to_epoch(opts['enddateymd'])
      end

      opts['startdateymd'] = to_ymd(opts['startdate'])      if opts.has_key? 'startdate'
      opts['enddateymd']   = to_ymd(opts['enddate'])        if opts.has_key? 'enddate'

      opts['date']         = to_epoch(opts['date'])         if opts.has_key? 'date'
      opts
    end

    private

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
