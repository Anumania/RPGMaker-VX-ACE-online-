class NetStuff
  @char_name = "ppl3"
  @char_index = 0
  @char_direction = 2;
  @@eks = 0
  @@why = 0
  @@map = 0
  @@socket = 0
  @@netNpc = nil;
  def self.char_name()
    return @char_name
  end
  def self.char_index()
    return @char_index
  end
  def self.char_direction()
    return @char_direction
  end
  def self.init(*message)
    net = Win32API.new("System/net_test.dll","a_net_setup","p","l")
    @@socket = net.call("")
    send = Win32API.new("System/net_test.dll","a_net_send", "lpl","l")
    send.call(@@socket,"init", "init".length)
  end
  def self.send(message)
    send = Win32API.new("System/net_test.dll","a_net_send", "lpl","l")
    send.call(@@socket, message, message.length)
  end
  def self.receive(strig)
    send = Win32API.new("System/net_test.dll","a_net_receive","lp","p")
    content = send.call(@@socket,strig)
    #msgbox(testy)
    return content
  end
  def self.update()  
      shitter = "                                                         "
      self.receive(shitter)
      bruh = shitter;
      i = 0
      length = 0
      name = ""
      bruh.bytes.each do |item, obj|
          case i
          when 0
            @@eks = item.to_i
          when 1
            @@why = item.to_i
          when 2
            @@map = item.to_i
          when 3
            length = item.to_i
            name = bruh.to_s[i+1..i+length]
          when 4
            @char_name = name
          when length+5
            @char_direction = item.to_i
          when length+6
            @char_index = item.to_i
          end
          
          i+=1
        end
    end
    
    def self.GetX()
      return @@eks
    end
    def self.GetY()
      return @@why
    end
    def self.GetMap()
      return @@map
    end
    def self.GetNpc()
        return @setNpc
      end
      def self.test(ev)
        ev.x = 30
        end
    def self.create_ev2(x, y)
      ev = RPG::Event.new(x, y) 
      ev.pages = [RPG::Event::Page.new()]
      ev.pages[0].graphic.character_name = ''    
      ev.pages[0].graphic.character_index = 0 
      ev.pages[0].direction_fix = false
      ev.pages[0].move_route.repeat = false
      ev.pages[0].move_speed = 5
      ev.pages[0].move_type = 0
      ev.pages[0].trigger = 4
      strg = "
      $game_map.events[event_id].x = NetStuff.GetX()
      $game_map.events[event_id].y = NetStuff.GetY()
      $game_map.need_refresh = true
      $game_map.events[event_id].refresh
      $game_map.events[event_id].set_graphic(NetStuff.char_name,NetStuff.char_index) rescue print('graphic does not exist')
      $game_map.events[event_id].set_direction(NetStuff.char_direction)
      if(($game_map.events[event_id].real_x - $game_map.events[event_id].x).abs > 5) then
        $game_map.events[event_id].real_x = $game_map.events[event_id].x
      end
      if(($game_map.events[event_id].real_y - $game_map.events[event_id].y).abs > 5) then
        $game_map.events[event_id].real_y = $game_map.events[event_id].y
      end
      if(($game_map.map_id%256).to_s == (NetStuff.GetMap()).to_s)then
        $game_map.events[event_id].opacity = 255
      else
        $game_map.events[event_id].opacity = 0
      end
      
      "
      ev.pages[0].list[0] = RPG::EventCommand.new(355, 0, [strg, ""])
      ev.pages[0].list[1] = RPG::EventCommand.new()
      #ev.pages[0].list[0].parameters = [strg]
      #$ev.pages
      Game_Event.new(@map_id, ev)
      $game_map.need_refresh = true
      game_ev = Game_Event.new($game_map.map_id, ev)    
      $game_map.events[ev.id] = game_ev
      $game_map.refresh()
      return ev
    end
    def self.GetBytes(num,numOfBytes)
      out = []
      for i in 1..numOfBytes
        out << (num.to_i/(256*i)).floor
      end
      return out
    end
  end
  
class Window_TitleCommand < Window_Command
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command(Vocab::shutdown, :shutdown)
    add_command("Connect", :connect) #add the connect button
  end
end
class Scene_Title < Scene_Base
  def create_command_window
    @command_window = Window_TitleCommand.new
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
    @command_window.set_handler(:connect,method(:command_network))
  end
  def command_network
    NetStuff.init('test')
    close_command_window()
    create_command_window()
  end
end

class Game_Player < Game_Character
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input
    super
    update_scroll(last_real_x, last_real_y)
    update_vehicle
    update_nonmoving(last_moving) unless moving?
    @followers.update
    #pospacket = @x.to_s+","+@y.to_s + "," + $game_map.map_id.to_s
    #animpacket = character_name.length.to_s + ',' +character_name + "," + character_index.to_s + "," + direction.to_s
    #pospacket = "aaaaaaaaaaaaaaass"
    #pospacket = [29797].pack('n*')
    pospacket = [1, @x,@y].pack('n*');
    NetStuff.send(pospacket);
    mappacket = [2,$game_map.map_id].pack('n*');
    NetStuff.send(mappacket);
    animpacket = [3,character_name.length].pack('n*')
    animpacket += character_name
    animpacket += [character_index, direction].pack('n*')
    NetStuff.send(animpacket);
    #NetStuff.send("bruhuhrurhurh");
    #NetStuff.send("pos"+pospacket.length.to_s+"," + pospacket + ',' + animpacket)
    NetStuff.update()
  end
end

class Game_Map
  alias NetStuff_GameMap_Setup setup 
  def setup(map_id)
    NetStuff_GameMap_Setup(map_id)
    NetStuff.create_ev2($game_player.x,$game_player.y)
  end  
end


#need to be able to edit these
class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor   :id                       # ID
  attr_accessor   :x                        # map X coordinate (logical)
  attr_accessor   :y                        # map Y coordinate (logical)
  attr_accessor   :real_x                   # map X coordinate (real)
  attr_accessor   :real_y 
  attr_accessor   :opacity
end

class Scene_Menu < Scene_MenuBase
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:skill,     method(:command_personal))
    @command_window.set_handler(:equip,     method(:command_personal))
    @command_window.set_handler(:status,    method(:command_personal))
    @command_window.set_handler(:formation, method(:command_formation))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
    @command_window.set_handler(:connect,   method(:command_connect))
  end 
  def close_command_window
    @command_window.close
    update until @command_window.close?
  end
  def command_connect
    NetStuff.init('test')
    close_command_window()
    create_command_window()
  end
end

class Window_MenuCommand < Window_Command
  def add_main_commands
    add_command(Vocab::item,   :item,   main_commands_enabled)
    add_command(Vocab::skill,  :skill,  main_commands_enabled)
    add_command(Vocab::equip,  :equip,  main_commands_enabled)
    add_command(Vocab::status, :status, main_commands_enabled)
    add_command("Connect",     :connect,main_commands_enabled)
  end
end



