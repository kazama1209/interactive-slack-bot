require "sinatra"
require "slack-ruby-client"
require "json"
require "dotenv"

Dotenv.load

client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])

# POSTメソッドで「/slack/command」にリクエストが来た場合の処理
post "/slack/command" do
  blocks = File.open("./data/questions.json"){ |j| JSON.load(j) }
  
  channel = params["channel_id"] # どのチャンネルから送信されたのかを取得
  user = params["user_id"] # どのユーザーから送信されたのかを取得

  # スラッシュコマンド実行者に対してのみ表示されるメッセージ（ephemeral）を作成
  client.chat_postEphemeral(
    channel: channel,
    user: user,
    blocks: blocks,
    as_user: true
  )

  return
end

# POSTメソッドで「/slack/command/answer」にリクエストが来た場合の処理
post "/slack/command/answer" do
  # Interactiveボタン押下の結果はpayloadという値で渡ってくる
  payload = JSON.parse(params[:payload])

  # case文でどのJSONを返すか分岐
  blocks = case payload["actions"][0]["value"]
    when "dog"
      File.open("./data/dog.json"){ |j| JSON.load(j) }
    when "cat"
      File.open("./data/cat.json"){ |j| JSON.load(j) }
    when "rabbit"
      File.open("./data/rabbit.json"){ |j| JSON.load(j) }
  end
  
  channel = payload["channel"]["id"] # どのチャンネルから送信されたのかを取得
  user = payload["user"]["id"] # どのユーザーから送信されたのかを取得

  # スラッシュコマンド実行者に対してのみ表示されるメッセージ（ephemeral）を作成
  client.chat_postEphemeral(
    channel: channel,
    user: user,
    blocks: blocks,
    as_user: true
  )

  return
end
