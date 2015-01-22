# -*- encoding: utf-8 -*-
require 'selenium-webdriver'
require 'rspec'
require 'yaml'
require 'uri'

DEFAULT_MESSAGE_SHOW_TIME = 5
MESSAGES = YAML.load_file('message.yml')

describe 'Selenium' do
  before do
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

  after { @driver.quit }

  it 'should show wikipedia page' do
    ### はじめに
    alert 'introduction'
    ### ページのロード
    alert 'load_page'
    @driver.get 'https://google.com'
    ### テキストを入力
    alert 'input_text'
    @driver.find_element(:css, '#lst-ib').send_keys 'ピタゴラスイッチ wikipedia'
    ### 検索ボタンをクリック
    alert 'click_submit_button'
    @driver.find_element(:css, "input[name='btnK']").submit
    ### リンクのクリック
    alert 'click_link'
    @driver.find_element(:link, 'ピタゴラスイッチ - Wikipedia').click
    alert('find_element', 5)
    ### ページタイトルの検証
    alert 'assert_title'
    expect(@driver.title).to eq 'ピタゴラスイッチ - Wikipedia'
  end

  it 'should accept alert' do
    ### アラート表示
    alert 'accept_alert'
    alert_text = 'サンプルアラート(OKを選択します)'
    @driver.execute_script "window.alert('#{alert_text}');"
    ### アラートのテキスト検証
    expect(@driver.switch_to.alert.text).to eq alert_text
    sleep 4 # 確認ダイアログを4秒表示
    ### アラートのOKを選択
    @driver.switch_to.alert.accept
  end

  it 'should reload page' do
    ### http://ja.wikipedia.org/wiki/ピタゴラスイッチを表示
    @driver.get 'http://ja.wikipedia.org/wiki/ピタゴラスイッチ'
    sleep 2 # 再読み込みしていることがわかるように2秒待機
    ### 再読み込みしてページ検証
    alert 'reload_page'
    @driver.navigate.refresh
    expect(@driver.title).to eq 'ピタゴラスイッチ - Wikipedia'
  end

  it 'should move to another window' do
    ### https://www.facebook.com/を表示
    alert 'move_to_another_window'
    @driver.get 'https://www.facebook.com/wikipedia' # ウィンドウA
    @driver.find_element(:link, 'http://www.wikipedia.org/').click # ウィンドウB
    assert_title 'Wikipedia | Facebook'
    ### ウィンドウをA => Bに切り替え
    wids = @driver.window_handles
    @driver.switch_to.window wids.last
    assert_title 'Wikipedia'
    ### ウィンドウBを閉じる
    alert 'close_window'
    @driver.close
    @driver.switch_to.window wids.first
    assert_title 'Wikipedia | Facebook'
  end

#  it 'should execute javascript ' do
#    @driver.execute_script
#  end

  private

  def alert(key, show_time = DEFAULT_MESSAGE_SHOW_TIME)
    msg = case key
    when String
      MESSAGES[key].join("\\n")
    when Array
      key.join("\\n")
    end
    @driver.execute_script "window.alert('#{msg}');"
    sleep show_time
    @driver.switch_to.alert.accept
    sleep 1
  end

  def assert_title(title)
    expect(@driver.title).to eq title
    alert ['現在表示しているページタイトルは', "#{@driver.title}です"]
  end
end
