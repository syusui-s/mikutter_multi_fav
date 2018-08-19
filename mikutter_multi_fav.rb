Plugin.create :mikutter_multi_fav do
  # Worldを選択するダイアログを表示し、
  # 選択されたWorldの配列を Deferred で返す
  def select_worlds_dialog(worlds)
    worlds = worlds
      .map { |w| [ w.slug, w ] }
      .to_h

    dialog('マルチふぁぼ') {
      worlds.each { |world_key, world|
        label = "#{world.title} @ #{world.class.slug}"
        boolean(label, world_key)
      }
    }.next { |res|
      worlds
        .select { |key, _| res[key] }
        .values
    }.trap { |ex|
      case ex
      when Plugin::Gtk::DialogWindow::Response::Cancel
        [] # 空の配列を返す
      else
        raise ex
      end
    }
  end

  command(
    :multi_fav,
    name: 'マルチふぁぼ',
    condition: Plugin::Command[:HasMessage],
    visible: true,
    role: :timeline
  ) do |opt|
    Deferred.new {
      worlds, = Plugin.filtering(:worlds, [])
      selected_worlds = +select_worlds_dialog(worlds)

      selected_worlds.each { |world|
        opt.messages.map { |msg|
          favorite(world, msg) } }
    }
  end
end
