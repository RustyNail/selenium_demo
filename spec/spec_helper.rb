# -*- encoding: utf-8 -*-
require 'selenium-webdriver'
require 'rspec'
require 'yaml'
require 'uri'

ALERT_TIME = ENV['ALERT_TIME'] || 10
MESSAGES = YAML.load_file(File.expand_path('spec/support/message.yml'))

def setup
  profile = Selenium::WebDriver::Firefox::Profile.new

  # プロキシの設定
  proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
  if proxy
    uri = URI.parse(proxy)
    profile.proxy = Selenium::WebDriver::Proxy.new(
      http: "#{uri.host}:#{uri.port}",
      ssl:  "#{uri.host}:#{uri.port}",
      ftp:  "#{uri.host}:#{uri.port}"
    )
  end

  # ダウンロードするファイルの保存先フォルダを指定
  ### 0: デスクトップ
  ### 1: ダウンロードフォルダ
  ### 2: ダウンロードに指定された最後のフォルダ
  profile['browser.download.dir'] = File.expand_path('.')
  profile['browser.download.folderList'] = 2
  # ダウンロードするファイルの保存先フォルダが指定してあればそれを使用
  profile['browser.download.useDownloadDir'] = true
  # 指定したmimeタイプは有無を言わさずダウンロード
  profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/zip;'

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
  line = "\\n" + '*'*50 + "\\n"
  msg = line + msg.join("\\n") + line
  @driver.execute_script "window.alert('#{msg}');"
  sleep alert_time.to_i
  @driver.switch_to.alert.accept
  sleep 1
end

def assert_title(title)
  expect(@driver.title).to eq title
  alert ['現在表示しているページタイトルは', "#{@driver.title}です"]
end

def wait_until_download_completing(dir, max_wait_time = 30)
  sleep 1 # ダウンロード開始されるまで一応1秒待機を挟む
  max_wait_time.times do
    sleep 1 unless Dir.entries(dir).grep(/.*\.part/).empty?
  end
end
