# -*- coding: utf-8 -*-

Plugin.create(:notify_hooker) do

  settings("コマンドフック") do
    def self.defnotify(label, kind)
      settings (label) do
        input '実行するコマンド', "notify_hooked_command_#{kind}".to_sym
        boolean 'フォーマット置換', "notify_hooked_command_format_#{kind}".to_sym
      end
    end

    defnotify "フレンドタイムライン", :friend_timeline
    defnotify "リプライ", :mention
    defnotify 'フォローされたとき', :followed
    defnotify 'フォロー解除されたとき', :removed
    defnotify 'リツイートされたとき', :retweeted
    defnotify 'ふぁぼられたとき', :favorited
    defnotify 'ダイレクトメッセージ受信', :direct_message

    boolean "コマンド実行時のエラーをタイムラインに表示する", :notify_hooked_command_does_show_err_in_bot
  end

  onupdate do |post, raw_messages|
    messages = Plugin.filtering(:show_filter, raw_messages.select{ |m| not(m.from_me? or m.to_me?) and m[:created] > DEFINED_TIME }).first
    if (not(messages.empty?) and UserConfig[:notify_hooked_command_friend_timeline])
      messages.each { |msg|
        self.exec_command(UserConfig[:notify_hooked_command_friend_timeline],
                          UserConfig[:notify_hooked_command_format_friend_timeline]?{"\#\<\<user\>\>" => msg[:user].idname, "\#\<\<post\>\>" => msg.body}:{})
      }
    end
  end
  
  onmention do |post, raw_messages|
    messages = Plugin.filtering(:show_filter, raw_messages.select{ |m| not(m.from_me? or m[:retweet]) and m[:created] > DEFINED_TIME }).first
    if (not(messages.empty?) and UserConfig[:notify_hooked_command_mention])
      messages.each { |msg|
        self.exec_command(UserConfig[:notify_hooked_command_mention],
                          UserConfig[:notify_hooked_command_format_mention]?{"\#\<\<user\>\>" => msg[:user].idname, "\#\<\<post\>\>" => msg.body}:{})
      }
    end
  end
  
  on_followers_created do |post, users|
    if (not(users.empty?) and UserConfig[:notify_hooked_command_followed])
      users.each { |user|
        self.exec_command(UserConfig[:notify_hooked_command_followed],
                          UserConfig[:notify_hooked_command_format_followed]?{"\#\<\<user\>\>" => user.idname}:{})
      }
    end
  end

  on_followers_destroy do |post, users|
    if (not(users.empty?) and UserConfig[:notify_hooked_command_removed])
      users.each { |user| 
      self.exec_command(UserConfig[:notify_hooked_command_removed],
                        UserConfig[:notify_hooked_command_format_removed]?{"\#\<\<user\>\>" => user.idname}:{})
      }
    end
  end
  
  on_favorite do |service, by, to|
    if (to.from_me? and UserConfig[:notify_hooked_command_favorited])
      self.exec_command(UserConfig[:notify_hooked_command_favorited],
                        UserConfig[:notify_hooked_command_format_favorited]?{"\#\<\<user\>\>" => by.idname, "\#\<\<post\>\>" => to.body}:{})
    end
  end
  
  onmention do |post, raw_messages|
    messages = Plugin.filtering(:show_filter, raw_messages.select{ |m| m[:retweet] and not m.from_me? }).first
    if (not(messages.empty?) and UserConfig[:notify_hooked_command_retweeted])
      messages.each{ |message|
        self.exec_command(UserConfig[:notify_hooked_command_retweeted],
                          UserConfig[:notify_hooked_command_format_retweeted]?{"\#\<\<by\>\>" => message[:user].idname, "\#\<\<post\>\>" => message.body}:{})
      }
    end
  end

  on_direct_messages do |post, dms|
    newer_dms = dms.select{ |dm| Time.parse(dm[:created_at]) > DEFINED_TIME }
    if (not(newer_dms.empty?) and UserConfig[:notify_hooked_command_direct_message])
      newer_dms.each { |dm|
        self.exec_command(UserConfig[:notify_hooked_command_direct_message],
                          UserConfig[:notify_hooked_command_direct_message]?{"\#\<\<from\>\>" => dm[:sender].idname, "\#\<\<text\>\>" => dm[:text]}:{})
      }
    end
  end

  def self.exec_command(command, replace_table={})
    if !(command == "")
      cmd = command
      begin
        replace_table.each{ |target, val|
          cmd = cmd.gsub(target, val)
        }
        Process.detach(spawn(cmd))
      rescue Errno::ENOENT => e
        if UserConfig[:notify_hooked_command_does_show_err_in_bot]
          ::Plugin.call(:update, nil, [Message.new(message: "Failed to exec hooked command: #{e}", system: true)])
        end
      end
    end
  end
  
end
