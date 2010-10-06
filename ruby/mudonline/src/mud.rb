#!/usr/bin/ruby
require "lib/ircbot.rb"
require "lib/database.rb"
require "core.rb"

# = Description
# Classe principale del mud che estende IrcBot e utilizza il singleton Database per la connessione ai dati.
#
# Questa classe si occupa di intercettare e distinguere i comandi degli utenti, e' stata schissa 
# in due con la classe Core che invece ne implementa i comandi (elaborazione dati) e la messaggistica (testo dialoghi).
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

class Mud < IrcBot
  
  # Ottine il singleton dell'istanza Database, ne setta i parametri di
  # connessione, e stabilisce la connessione al database.
  #
  # Istanzia inoltre la classe Core che ha al suo interno
  # tutte le implementazioni dei comandi e la messaggistica del mud.
  def connectDB(*args)
    Database.instance.connect(*args) # singleton
    @core = Core.new # insieme di funzioni x elaborare i comandi
  end
  
  # Invia al singleton il comando di chiusura della connessione al database.
  def closeDB()
    Database.instance.close
  end
  
  # Parsa un messaggio utente per valutarlo tramite il metodo evaluate, 
  # l'esito della valutazione e' un messaggio che viene comunicato all'utente.
  def dispatch(msg)
    # puts Thread.current
    puts msg
    if msg =~ /^:(.+)!(.+@.+)\sPRIVMSG\s(.+)\s:(.+)$/i
      text = evaluate($1, $2, $3, $4)
      unless text.empty?
        message($1, up_case(text))
      else
        message($1, up_case(@core.cmd_not_found))
      end
    end
  end
  
  # Valuta il parsing del messaggio utente ed esegue di conseguenza 
  # l'operazione di riferimento implementata all'interno di Core.
  #
  # Ogni operazione ha un messaggio di ritorno che torna al dispatch.
  def evaluate(nick, extra, target, msg)
    msg = msg.strip # stampa del messaggio grezzo
    # riconoscimento utente
    unless (@core.is_welcome? nick)
      if msg =~ /^(ciao|salve)$/i
        return @core.welcome(nick, $1)
      else
        return @core.need_welcome
      end
    end
    
    @core.update_timestamp(nick) # segnala attivita' utente
    
    # tutti i comandi
    case msg
    when /^mi\s(alzo|sveglio)$/i
      return @core.up(nick)
    when /^mi\s(siedo|addormento|sdraio|riposo|stendo|distendo)$/i
      return @core.down(nick)
    when /^dove.+(sono|siamo|finit.|trov.+)\?$/i
      return @core.place(nick)
    when /^dove.+(recar.+|andar.+|procedere|diriger.+)\?$/i
      return @core.near_place(nick)
    when /^va.*\s(ne|a).{1,3}\s(.+)$/i
      return @core.move(nick, $2)
    when /^chi.+(qu.|zona)\?$/i
      return @core.users_zone(nick)
    when /^(esamin.|guard.|osserv.|scrut.|analizz.)\s(.+)$/i
      return @core.look(nick, $2)
    when /^salva$/i
      return @core.save(nick)
    end
    return ""
  end
  
  private :evaluate
  protected :dispatch
end

# Main

if __FILE__ == $0
  begin
    app = Mud.new("game_master", "Game Master")
    app.connectDB("127.0.0.1", 5432, "mud_db", "postgres", "caliostro")
    app.connectIRC("127.0.0.1", 6667)
    app.main_loop
  rescue Interrupt
  rescue Exception => e
    puts "MainLoop: " + e.message
    print e.backtrace.join("\n")
    #retry # ritenta dal begin
  ensure
    app.closeDB
  end
end