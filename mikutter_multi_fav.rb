Plugin.create :mikutter_multi_fav do
  def service_select_dialog
    dialog = Gtk::Dialog.new(
      nil,
      nil,
      Gtk::Dialog::DESTROY_WITH_PARENT,
      ['Favorite', Gtk::Dialog::RESPONSE_OK],
      ['Favorite', Gtk::Dialog::RESPONSE_CANCEL]
    )

    service_buttons = Service.services.map do |svc|
      button = Gtk::CheckButton.new("#{svc.idname}")
      dialog.vbox.pack_start(button, false, false, 5)
      { service: svc, button: button }
    end

    dialog.show_all

    dialog.run {|res_id|
      services = if res_id == Gtk::Dialog::RESPONSE_OK
         service_buttons.map{|svc_btn| svc_btn[:button].active? ? svc_btn[:service] : nil }.compact
      else [] end

      dialog.destroy
      return services
    }
  end

  command(:multi_fav,
    name: 'マルチふぁぼ',
    condition: Plugin::Command[:HasMessage],
    visible: true,
    role: :timeline
  ) do |opt|
      services = service_select_dialog

      services.each do |svc| opt.messages.each do |msg|
          svc.favorite(msg, true)
      end end
  end

end
