require './app'

username = ENV['USERNAME']
password = ENV['PASSWORD']

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://linkedin.com"

# log in!
element = driver.find_element(:id, 'login-email')
element.send_keys username
element = driver.find_element(:id, 'login-password')
element.send_keys password
element.submit

connections_url = 'https://www.linkedin.com/people/pymk/hub?ref=global-nav&trk=nav_utilities_invites_header'

if driver.title.match /Sign-In Verification/
  puts "Sign in verification necessary. Enter proper response inside of driver."
  binding.pry
end

# Handle the captcha dialgoue if it pops up.
if driver.title.match /Security Verification/
  puts "CAPTCHA robot stuff... enter in proper response inside of driver."
  binding.pry
end


5000.times do |i|
  puts "Refreshing and clicking 'See more' six times...  "

  driver.navigate.to connections_url
  # invitations_remaining = driver.find_element(:css => '.pending-total.hidden')['innerHTML']
  # puts "Invitations remaining: #{invitations_remaining}"
  
  begin
    10.times do
      driver.find_element(:css => ".see-more").click
    end
  rescue Selenium::WebDriver::Error::ElementNotVisibleError, Selenium::WebDriver::Error::NoSuchElementError
    puts 'No remaining "See more" links to click'
  end

  # let's let the page fully repaint
  sleep 5
  to_accept, to_ignore = driver.find_elements(:css => ".invite.card.animated").partition do |el| 
    profile_url = el.find_element(:css => '.avatar')['href']
    user_id = CGI.parse(URI.parse(profile_url).query)['id'].first.to_i 
    User.where(user_id: user_id).empty?
  end
  
  
  puts "Unaccepted users on page: #{to_accept.size}"
  puts "Accepted users on page: #{to_ignore.size}"
  
  to_accept.each do |invite_card|
    begin 
      next unless invite_card.displayed?
      driver.mouse.move_to invite_card
      request_message = invite_card.find_element(:css => '.invite-message-content-wrapper textarea')['innerHTML']
      profile_link = invite_card.find_element(:css => '.avatar')['href']
      user_id = CGI.parse(URI.parse(profile_link).query)['id'].first.to_i

      begin
        avatar = invite_card.find_element(:css => '.avatar img')
        avatar_url = avatar['src']
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts "No avatar for id: #{user_id}"
        avatar_url = nil
      end
  
      number_of_connections = invite_card.find_element(:css => '.bt-incommon .screen-reader-text')['innerHTML'].to_i rescue 0
  
      accept_button = invite_card.find_element(:css => 'button.bt-invite-accept')
      name = accept_button.find_element(:css => '.hidden.message a')['innerHTML']
      headline = invite_card.find_element(:css => '.headline')['innerHTML']
  
      user = User.where(user_id: user_id).first
      attributes = {
        request_message: request_message, 
        profile_link: profile_link, 
        avatar_url: avatar_url, 
        headline: headline,
        name: name,
        number_of_connections: number_of_connections,
        number_of_requests_accepted: 1
      }
  
      if(user.present?) 
        puts "User already accepted. Updating."
        user.update_attributes(attributes)
      else 
        puts "Accepting #{name}"
        driver.mouse.move_to invite_card
        accept_button.click
        user = User.create(attributes.merge(user_id: user_id))
      end
    rescue Selenium::WebDriver::Error::ElementNotVisibleError => e
      error_message = "Errored out trying to do stuff. #{e.message}."
      puts error_message
      ActiveRecord::Base.logger.error(error_message)
      ActiveRecord::Base.logger.error(e.backtrace)
    end
  end
  
  to_ignore.each do |invite_card|
    begin 
      next unless invite_card.displayed?

      profile_link = invite_card.find_element(:css => '.avatar')['href']
      user_id = CGI.parse(URI.parse(profile_link).query)['id'].first.to_i
      user = User.where(user_id: user_id).first
      current_num_of_requests = user.number_of_requests_accepted || 1
      incremented_num_of_requests = current_num_of_requests += 1
      user.update_attributes(number_of_requests_accepted: incremented_num_of_requests)
      puts "Previously seen, request #{incremented_num_of_requests} for user #{user_id}."

      driver.mouse.move_to invite_card
      sleep 1
      # accept_button = invite_card.find_element(:css => 'button.bt-invite-accept').click
      decline_button = invite_card.find_element(:css => 'button.bt-invite-decline').click
    rescue Selenium::WebDriver::Error::ElementNotVisibleError => e
      error_message = "Errored out trying to do stuff. #{e.message}."
      puts error_message
      ActiveRecord::Base.logger.error(error_message)
      ActiveRecord::Base.logger.error(e.backtrace)
    end
  end
end

driver.quit
