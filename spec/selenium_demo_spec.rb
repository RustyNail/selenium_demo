# -*- encoding: utf-8 -*-

describe 'Selenium' do
  before { setup }
  after { @driver.quit }

  it 'should show wikipedia page' do
    ### はじめに
    alert 'introduction'
    ### ページのロード
    alert 'load_page'
    @driver.get 'https://google.com'
    ### テキストを入力
    alert 'input_text'
    @driver.find_element(:name, 'q').send_keys 'ピタゴラスイッチ wikipedia'
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

  it 'should execute javascript' do
    alert 'execute_javascript'
    @driver.execute_script("window.confirm('javascriptで出したダイアログ')")
    expect(@driver.switch_to.alert.text).to eq 'javascriptで出したダイアログ'
    sleep 4
    @driver.switch_to.alert.accept
  end

  it 'should save screenshot' do
    alert 'save_screenshot'
    @driver.get 'http://www.yahoo.co.jp/'
    file_name = 'yahoo.png'
    file_path = File.expand_path(file_name)
    @driver.save_screenshot file_name
    sleep 2
    expect(File.exist?(file_path)).to be_truthy
    @driver.get "file://#{file_path}"
    sleep 4 # 撮ったスクリーンショットの表示
    File.delete file_path # スクリーンショットの削除
  end
end
