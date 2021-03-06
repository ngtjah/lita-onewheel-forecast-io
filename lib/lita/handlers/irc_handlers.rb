module ForecastIo
  module IrcHandlers
    #-# Handlers
    def handle_irc_weathercommands(response)
      help = {'!ansitemp [location]' => 'The 24h temperature scale for [location].',
              '!dailytemp [location]' => '48h temperature scale for [location].',
              '!7day [location]' => '7 day temperature scale, featuring highs and lows.',
              '!weekly [location]' => 'Alias for !7day.',
              '!asciitemp [location]' => 'Like ansitemp, but with less ansi.',
              '!ieeetemp [location]' => 'The 24h temperature scale for [location], kelvin-style.',
              '!forecastallthethings [location]' => 'A huge dump of most available info for [location].',
              '!cond[itions] [location]' => 'A single-line summary of the conditions at [location].',
              '!rain [location]' => 'Magic Eightball response to whether or not it is raining in [location] right now.',
              '!snow [location]' => 'Magic Eightball response to whether or not it is snowing in [location] right now.',
              '!geo [location]' => 'A simple geo-lookup returning GPS coords.',
              '!alerts [location]' => 'NOAA alerts for [location].',
              '!neareststorm [location]' => 'Nearest storm distance for [location].',
              '!set scale [c|f|k]' => 'Set the scale to your chosen degrees.',
              '!set scale' => 'Toggle between C and F scales.',
              '!ansihumidity [location]' => '48h humidity report for [location].',
              '!dailyhumidity [location]' => '7 day humidity report.',
              '!ansirain [location]' => '60m rain chance report for [location].',
              '!ansisnow [location]' => 'Alias for !ansirain.',
              '!dailyrain [location]' => '48h rain chance report for [location].',
              '!dailysnow [location]' => 'Alias for !dailyrain.',
              '!7dayrain [location]' => '7 day rain chance report for [location].',
              '!weeklyrain [location]' => 'Alias for !7dayrain.',
              '!weeklysnow [location]' => 'Alias for !7dayrain.',
              '!ansiintensity [location]' => '60m rain intensity report for [location].',
              '!asciirain [location]' => '60m rain chance report for [location], ascii style!',
              '!ansisun [location]' => '7 day chance-of-sun report for [location].',
              '!asciisun [location]' => '7 day chance-of-sun report for [location].',
              '!ansiwind [location]' => '24h wind speed/direction report for [location].',
              '!asciiwind [location]' => '24h wind speed/direction report for [location], ascii style.',
              '!dailywind [location]' => '7 day wind speed/direction report for [location].',
              '!asciicloud [location]' => '24h cloud cover report for [location].',
              '!ansicloud [location]' => '24h cloud cover report for [location].',
              '!ansiozone [location]' => '24h ozone level report for [location].',
              '!ansipressure [location]' => '48h barometric pressure report for [location].',
              '!ansibarometer [location]' => 'Alias for !ansipressure.',
              '!dailypressure [location]' => '7 day barometric pressure report for [location].',
              '!dailybarometer [location]' => 'Alias for !dailypressure.'}
      help.each do |command, description|
        response.reply "#{command} - #{description}"
      end
    end
    def handle_irc_forecast(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + forecast_text(forecast)
    end

    def handle_irc_ansirain(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_rain_forecast(forecast)
    end

    def handle_irc_ascii_rain(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ascii_rain_forecast(forecast)
    end

    def handle_irc_all_the_things(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + forecast_text(forecast)
      response.reply location.location_name + ' ' + ansi_rain_forecast(forecast)
      response.reply location.location_name + ' ' + ansi_rain_intensity_forecast(forecast)
      response.reply location.location_name + ' ' + ansi_temp_forecast(forecast)
      response.reply location.location_name + ' ' + ansi_wind_direction_forecast(forecast)
      response.reply location.location_name + ' ' + do_the_sun_thing(forecast, ansi_chars)
      response.reply location.location_name + ' ' + do_the_cloud_thing(forecast, ansi_chars)
      response.reply location.location_name + ' ' + do_the_daily_rain_thing(forecast)
    end

    def handle_irc_ansirain_intensity(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_rain_intensity_forecast(forecast)
    end

    def handle_irc_ansitemp(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_temp_forecast(forecast)
    end

    def handle_irc_ieeetemp(response)
      @scale = 'k'
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_temp_forecast(forecast)
    end

    def handle_irc_ascii_temp(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ascii_temp_forecast(forecast)
    end

    def handle_irc_daily_temp(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_temp_forecast(forecast, 48)
    end

    def handle_irc_conditions(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + conditions(forecast)
    end

    def handle_irc_ansiwind(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ansi_wind_direction_forecast(forecast)
    end

    def handle_irc_ascii_wind(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + ascii_wind_direction_forecast(forecast)
    end

    def handle_irc_alerts(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      alerts = get_alerts(forecast)
      response.reply alerts
    end

    def handle_irc_ansisun(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_sun_thing(forecast, ansi_chars)
    end

    def handle_irc_dailysun(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_daily_sun_thing(forecast, ansi_chars)
    end

    def handle_irc_asciisun(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_sun_thing(forecast, ascii_chars)
    end

    def handle_irc_ansicloud(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_cloud_thing(forecast, ansi_chars)
    end

    def handle_irc_asciicloud(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_cloud_thing(forecast, ascii_chars)
    end

    def handle_irc_seven_day(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_seven_day_thing(forecast)
    end

    def handle_irc_daily_rain(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_daily_rain_thing(forecast)
    end

    def handle_irc_seven_day_rain(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_seven_day_rain_thing(forecast)
    end

    def handle_irc_daily_wind(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_daily_wind_thing(forecast)
    end

    def handle_irc_daily_humidity(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_daily_humidity_thing(forecast)
    end

    def handle_irc_ansi_humidity(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' 48hr humidity ' + ansi_humidity_forecast(forecast)
    end

    def handle_irc_ansiozone(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_ozone_thing(forecast)
    end

    def handle_irc_ansi_pressure(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_pressure_thing(forecast)
    end

    def handle_irc_daily_pressure(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' ' + do_the_daily_pressure_thing(forecast)
    end

    def handle_irc_set_scale(response)
      key = response.user.name + '-scale'
      user_requested_scale = response.match_data[1].to_s.downcase
      reply = check_and_set_scale(key, user_requested_scale)
      response.reply reply
    end

    def handle_irc_sunrise(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' sunrise: ' + do_the_sunrise_thing(forecast)
    end

    def handle_irc_sunset(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      response.reply location.location_name + ' sunset: ' + do_the_sunset_thing(forecast)
    end

    def handle_irc_neareststorm(response)
      location = geo_lookup(response.user, response.match_data[1])
      forecast = get_forecast_io_results(response.user, location)
      nearest_storm_distance, nearest_storm_bearing = do_the_nearest_storm_thing(forecast)

      if nearest_storm_distance == 0
        response.reply "You're in it!"
      else
        response.reply "The nearest storm is #{get_distance(nearest_storm_distance, get_scale(response.user))} to the #{get_cardinal_direction_from_bearing(nearest_storm_bearing)} of you."
      end

    end
  end
end
