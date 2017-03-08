require 'uri'

p URI.encode('http://google.com')
p URI.encode_www_form(url: 'http://google.com')