require "thread"
require "lib/database.rb"
require "lib/utils.rb"
require "locate/messages_it.rb"
require "mod/user.rb"
require "mod/npc.rb"
require "mod/place.rb"

# = Description
# Classe che implementa l'elaborazione dei dati dei comandi utente e genera i messaggi di ritorno del Mud.
# = License
# Nemesis - IRC Mud Multiplayer Online totalmente italiano
#
# Copyright (C) 2010 Giovanni Amati
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
# = Authors
# Giovanni Amati

class Core
  include Utils
  include GetText
  
  # Metodo di inizializzazione della classe.
  def initialize()
    @db = Database.instance # singleton
    
    @place_list = {}
    @npc_list = {}
    
    # caricamento dati mondo
    init_data
    # controllo attivita' utente
    #Thread.new do
    #  while true do
    #    @user_list.each_pair do |k, v|
    #      v.save # salva ogni 30 sec
    #      if (Time.new.to_i - User.get_timestamp(nick) >= 60)
    #        @mutex.synchronize { @user_list.delete(k) }
    #      end
    #    end
    #    sleep 30
    #  end
    #end
  end
  
  # Inizializza la mappa del mondo, npc, ecc...
  def init_data()
    User.reset_login
    
    @place_list = {}
    places = @db.read("*", "places")
    places.each { |p| @place_list[Integer(p[0])] = Place.new(p) }
    places.each do |p|
      temp = @db.read("places.id", 
                      "links,places", 
                      "place=#{p[0]} and places.id=near_place")
      @place_list[Integer(p[0])].init_near_place(@place_list, temp)
    end
    
    @npc_list = {}
    npcs = @db.read("name", "npc")
    npcs.each do |n|
      temp = Npc.new(n[0])
      @npc_list[n[0]] = temp
      @place_list[temp.place].add_people(temp)
    end
  end
  
  # Ritorna un booleano che indica se l'utente e' loggato o no nel sistema, 
  # ritorna false anche nel caso non esiste.
  def is_welcome?(nick)
    return User.logged?(nick)
  end
  
  # Aggiorna il timestamp dell'utente, che indica il momento dell'ultimo
  # messaggio inviato.
  def update_timestamp(nick)
    User.update_timestamp(nick)
  end
  
  # Test comunicazione in canale.
  def test(nick)
    return _(:test) % nick
  end
  
  # Ritorna un messaggio random di comando non conosciuto.
  def cmd_not_found()
    return _("cnf_#{rand 3}")
  end
  
  # Ritorna un messaggio che indica la necessita di riconoscersi,
  # di effettuare una sorta di autenticazione/login.
  def need_welcome()
    return _(:r_benv)
  end
  
  # Ritorna un messaggio di benvenuto e il posto in cui e' l'utente,
  # il comando login tenta il login utente e ritorna true/false.
  def welcome(nick, greeting)
    if User.login(nick)
      @place_list[User.get_place(nick)].add_people(nick)
      return _(:benv) % [greeting, bold(nick), place(nick)]
    else
      return _(:no_reg)
    end
  end
  
  # Muove l'utente in un posto vicino, collegato a quello attuale e
  # ritorna un messaggio con nuovo nome del posto e descrizione o
  # un messaggio di fallito spostamento.
  def move(nick, place_name)
    return _("uaresit_#{rand 2}") unless User.stand_up?(nick)
    find = nil
    @place_list[User.get_place(nick)].near_place.each do |p|
      if p.name =~ /#{place_name.strip}/i 
        find = p
        break
      end
    end
    if find
      @place_list[User.get_place(nick)].remove_people(nick)
      User.set_place(nick, find.id) # cambio di place_id
      find.add_people(nick)
      return place(nick)
    else
      return _(:no_pl) % place_name
    end
  end
  
  # Ritorna il posto e descrizione in cui e' l'utente.
  def place(nick)
    p = @place_list[User.get_place(nick)]
    temp = pa_in(a_d(p.attrs, p.name)) + bold(p.name)
    return _(:pl) % [temp, p.descr]
  end
  
  # Ritorna la lista dei posti vicini in cui si puo andare.
  def near_place(nick)
    l = @place_list[User.get_place(nick)].near_place
    temp = l.map { |p| pa_di(a_d(p.attrs, p.name)) + bold(p.name) }
    return _(:np) % conc(temp)
  end
  
  # Fa alzare l'utente e ritorna un messaggio di esito.
  def up(nick)
    return _("up_#{User.up(nick)}")
  end
  
  # Fa abbassare l'utente e ritorna un messaggio di esito.
  def down(nick)
    return _("down_#{User.down(nick)}")
  end
  
  # Ritorna la descrizione di un npc, oggetto o altro.
  def look(nick, name)
    find = nil
    @place_list[User.get_place(nick)].get_people.each do |p|
      if (p.class == Npc and p.name == name.capitalize)
        find = p
        break
      end
    end
    return _(:desc_npc) % [find.name, find.descr] if find
    # se nn e' un npc controlla gli oggetti con quel nome ecc
    # da fare ...
    return _(:nothing) % name
  end
  
  # Ritorna la lista degli npc ed utenti nella zona.
  def users_zone(nick)
    u = []
    @place_list[User.get_place(nick)].get_people.each do |p|
      unless p.class == Npc
        u << bold(p) if (p != nick)
      else
        u << italic(p.name)
      end
    end
    if u.empty?
      c = _(:nobody) + ","
      u = [_(:onlyu)]
    else
      c = _((u.length > 1) ? :ci_sono : :c_e)
    end
    return _(:uz) % [c, conc(u)]
  end
  
  private :init_data
end
