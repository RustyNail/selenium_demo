# -*- encoding: utf-8 -*-
require 'selenium-webdriver'
require 'rspec'
require 'yaml'
require 'uri'

ALERT_TIME = ENV['ALERT_TIME'] || 10
MESSAGES = YAML.load_file(File.expand_path('spec/support/message.yml'))

def setup
  proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
  profile = nil
  if proxy
    uri = URI.parse(proxy)
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.proxy = Selenium::WebDriver::Proxy.new(
      http: "#{uri.host}:#{uri.port}",
      ssl:  "#{uri.host}:#{uri.port}",
      ftp:  "#{uri.host}:#{uri.port}"
    )
  end
  @driver = Selenium::WebDriver.for :firefox, profile: profile
  @driver.manage.window.maximize # ウィンドウサイズを最大化
end

def alert(key, alert_time = ALERT_TIME)
  msg = case key
  when String
    MESSAGES[key]
  when Array
    key
  end
  # 「このページによる追加のダイアログ表示を抑止する」
  # が出るときが見にくいので改行を挟む
  msg = msg.join("\\n") + "\\n\\n\\n"
  @driver.execute_script "window.alert('#{msg}');"
  sleep alert_time
  @driver.switch_to.alert.accept
  sleep 1
end

def assert_title(title)
  expect(@driver.title).to eq title
  alert ['現在表示しているページタイトルは', "#{@driver.title}です"]
end
